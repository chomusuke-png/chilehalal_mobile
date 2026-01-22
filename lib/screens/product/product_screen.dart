import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/product_service.dart';

class ProductScreen extends StatefulWidget {
  final String? barcode;
  final Map<String, dynamic>? productData;

  const ProductScreen({
    super.key,
    this.barcode,
    this.productData,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _product;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // CASO 1: Venimos del Catálogo (Ya tenemos los datos)
    if (widget.productData != null) {
      setState(() {
        _product = widget.productData;
        _isLoading = false;
      });
      return; // No necesitamos buscar en la API
    }

    // CASO 2: Venimos del Escáner (Solo tenemos el código, hay que buscar)
    if (widget.barcode != null) {
      _fetchProduct(widget.barcode!);
    } else {
      // Caso de error raro: no se pasó nada
      setState(() {
        _isLoading = false;
        _notFound = true;
      });
    }
  }

  Future<void> _fetchProduct(String code) async {
    final data = await _productService.getProductByBarcode(code);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) {
          _product = data;
        } else {
          _notFound = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Producto no encontrado',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            Text('Código: ${widget.barcode}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a Escanear'),
            )
          ],
        ),
      );
    }

    // Datos del producto
    final name = _product?['name'] ?? 'Sin Nombre';
    final brand = _product?['brand'] ?? 'Marca desconocida';
    final description = _product?['description'] ?? '';
    final isHalal = _product?['is_halal'] == true;
    final imageUrl = _product?['image_url'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Imagen del Producto
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: imageUrl != null 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  )
                : const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
          ),
          
          const SizedBox(height: 30),

          // 2. Estado Halal (Badge gigante)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: isHalal ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isHalal ? Colors.green : Colors.red, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isHalal ? Icons.check_circle : Icons.cancel,
                  color: isHalal ? Colors.green[800] : Colors.red[800],
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  isHalal ? 'CERTIFICADO HALAL' : 'NO CERTIFICADO / HARAM',
                  style: TextStyle(
                    color: isHalal ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. Textos
          Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(brand, style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          
          const Text("Descripción / Ingredientes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Text(description.isNotEmpty ? description : 'No hay descripción disponible.', style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}