import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chilehalal_mobile/services/product_service.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';

class CreateProductScreen extends StatefulWidget {
  final String? scannedBarcode;

  const CreateProductScreen({super.key, this.scannedBarcode});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _brandCtrl = TextEditingController();
  final TextEditingController _barcodeCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  
  String _selectedStatus = 'doubt';
  bool _isLoading = false;
  bool _isPartner = false;
  String? _userRole;
  List<String> _myBrands = [];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _availableCategories = [];
  final List<int> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.scannedBarcode != null) {
      _barcodeCtrl.text = widget.scannedBarcode!;
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final results = await Future.wait([
      _authService.getLocalUser(),
      _productService.getCategories(),
    ]);

    final user = results[0] as Map<String, dynamic>?;
    final categories = results[1] as List<Map<String, dynamic>>;

    if (mounted) {
      setState(() {
        _availableCategories = categories;
        
        final role = user?['role'];
        _userRole = role;
        
        if (role == 'partner') {
          _isPartner = true;
          final brandsRaw = user?['brands'] as List<dynamic>? ?? [];
          _myBrands = brandsRaw.map((e) => e.toString()).toList();
        }
      });
      
      if (_isPartner && _myBrands.isNotEmpty) {
        _brandCtrl.text = _myBrands[0];
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final result = await _productService.createProduct(
      name: _nameCtrl.text,
      brand: _brandCtrl.text,
      barcode: _barcodeCtrl.text,
      isHalal: _selectedStatus,
      description: _descriptionCtrl.text,
      imageBase64: base64Image,
      categories: _selectedCategoryIds,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _userRole == 'user' 
                ? 'Solicitud enviada a revisión' 
                : 'Producto creado'
            ), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error al guardar'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegularUser = _userRole == 'user';
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRegularUser ? 'Solicitar Producto' : 'Nuevo Producto'),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isRegularUser 
                          ? 'Ingresa los datos del producto. Nuestro equipo verificará la información antes de publicarlo.'
                          : 'Agrega un nuevo producto al catálogo oficial.',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[400]!),
                      image: _selectedImage != null
                          ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text('Añadir Foto', style: TextStyle(color: Colors.grey[600])),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Producto', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              if (_isPartner && _myBrands.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _myBrands.contains(_brandCtrl.text) ? _brandCtrl.text : _myBrands.first,
                  decoration: InputDecoration(
                    labelText: 'Marca / Empresa', 
                    border: const OutlineInputBorder(),
                    helperText: 'Selecciona una de tus marcas autorizadas.',
                    helperStyle: TextStyle(color: primaryColor),
                  ),
                  items: _myBrands.map((brand) {
                    return DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _brandCtrl.text = val;
                      });
                    }
                  },
                  validator: (v) => v == null || v.isEmpty ? 'Selecciona una marca' : null,
                )
              else
                TextFormField(
                  controller: _brandCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Marca / Empresa', 
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                ),
              
              const SizedBox(height: 16),

              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras', 
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Estado de Certificación', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'yes', child: Text('✅ Certificado Halal')),
                  DropdownMenuItem(value: 'no', child: Text('❌ Haram / No Apto')),
                  DropdownMenuItem(value: 'doubt', child: Text('⚠️ Dudoso / En revisión')),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Ingredientes (Opcional)', 
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              const Text('Categorías', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (_availableCategories.isEmpty)
                const Text('Cargando categorías...', style: TextStyle(fontStyle: FontStyle.italic))
              else
                Wrap(
                  spacing: 8.0,
                  children: _availableCategories.map((cat) {
                    final isSelected = _selectedCategoryIds.contains(cat['id']);
                    return FilterChip(
                      label: Text(cat['name']),
                      selected: isSelected,
                      selectedColor: primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: primaryColor,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryIds.add(cat['id']);
                          } else {
                            _selectedCategoryIds.remove(cat['id']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      isRegularUser ? 'ENVIAR SOLICITUD' : 'GUARDAR PRODUCTO', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}