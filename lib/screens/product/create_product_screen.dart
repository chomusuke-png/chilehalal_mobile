import 'package:flutter/material.dart';
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
  
  String _selectedStatus = 'doubt';
  bool _isLoading = false;
  bool _isPartner = false;
  List<dynamic> _myBrands = [];

  @override
  void initState() {
    super.initState();
    if (widget.scannedBarcode != null) {
      _barcodeCtrl.text = widget.scannedBarcode!;
    }
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final user = await _authService.getLocalUser();
    final role = user?['role'];
    
    if (role == 'partner') {
      setState(() {
        _isPartner = true;
        _myBrands = user?['brands'] ?? []; 
      });
      
      if (_myBrands.length == 1) {
        _brandCtrl.text = _myBrands[0];
      }
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _productService.createProduct(
      name: _nameCtrl.text,
      brand: _brandCtrl.text,
      barcode: _barcodeCtrl.text,
      isHalal: _selectedStatus,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Producto creado exitosamente'), backgroundColor: Colors.green),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NOMBRE
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Producto', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _brandCtrl,
                decoration: InputDecoration(
                  labelText: 'Marca / Empresa', 
                  border: const OutlineInputBorder(),
                  helperText: _isPartner ? 'Tu cuenta está asociada a esta marca.' : null,
                ),
                readOnly: _isPartner && _myBrands.isNotEmpty,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras', 
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Estado de Certificación', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'yes', child: Text('✅ Certificado Halal')),
                  DropdownMenuItem(value: 'no', child: Text('❌ Haram / No Apto')),
                  DropdownMenuItem(value: 'doubt', child: Text('⚠️ Dudoso / En revisión')),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('GUARDAR PRODUCTO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}