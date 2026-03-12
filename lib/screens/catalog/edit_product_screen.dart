import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chilehalal_mobile/services/product_service.dart';
import 'package:chilehalal_mobile/utils/image_picker_helper.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const EditProductScreen({super.key, required this.productData});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _barcodeCtrl;
  late TextEditingController _descCtrl;

  String _selectedStatus = 'doubt';
  bool _isLoading = false;
  bool _isImageDeleted = false;
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.productData['name'] ?? '');
    _brandCtrl = TextEditingController(text: widget.productData['brand'] ?? '');
    _barcodeCtrl = TextEditingController(text: widget.productData['barcode'] ?? '');
    _descCtrl = TextEditingController(text: widget.productData['description'] ?? '');

    final rawStatus = widget.productData['is_halal'];
    if (rawStatus == true || rawStatus == 'yes') _selectedStatus = 'yes';
    else if (rawStatus == false || rawStatus == 'no') _selectedStatus = 'no';
    else _selectedStatus = 'doubt';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _barcodeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isImageDeleted = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al acceder a la cámara o galería')),
        );
      }
    }
  }

  Future<void> _handleImageSelection() async {
    final currentImage = widget.productData['image_url'];
    final bool hasExistingImage = (currentImage != null && currentImage.toString().isNotEmpty);
    final bool hasImageToShow = _selectedImage != null || (hasExistingImage && !_isImageDeleted);

    final action = await ImagePickerHelper.showActionSheet(
      context, 
      hasExistingImage: hasImageToShow,
    );

    if (action == null) return;

    switch (action) {
      case ImagePickerAction.camera:
        _pickImage(ImageSource.camera);
        break;
      case ImagePickerAction.gallery:
        _pickImage(ImageSource.gallery);
        break;
      case ImagePickerAction.delete:
        setState(() {
          _selectedImage = null;
          _isImageDeleted = true;
        });
        break;
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    } else if (_isImageDeleted) {
      base64Image = 'DELETE';
    }

    final productId = widget.productData['id'] as int;

    final result = await _productService.updateProduct(
      productId: productId,
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      barcode: _barcodeCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isHalal: _selectedStatus,
      imageBase64: base64Image,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentImage = widget.productData['image_url'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _handleImageSelection,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _isImageDeleted 
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: colorScheme.primary),
                                  const SizedBox(height: 8),
                                  const Text('Añadir Foto', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )
                            : _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : (currentImage != null && currentImage.toString().isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: currentImage,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, size: 40, color: colorScheme.primary),
                                          const SizedBox(height: 8),
                                          const Text('Añadir Foto', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Producto', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _brandCtrl,
                decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'La marca es requerida' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(labelText: 'Código de Barras (Opcional)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Estado Halal', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'yes', child: Text('✅ Certificado Halal / Apto')),
                  DropdownMenuItem(value: 'no', child: Text('❌ Haram / No Apto')),
                  DropdownMenuItem(value: 'doubt', child: Text('⚠️ Dudoso (Mashbooh)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descripción / Ingredientes', border: OutlineInputBorder()),
              ),
              
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}