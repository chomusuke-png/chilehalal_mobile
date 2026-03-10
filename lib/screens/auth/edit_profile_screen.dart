import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';
import 'package:chilehalal_mobile/utils/image_picker_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  bool _isLoading = false;
  bool _isImageDeleted = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userData['name'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.userData['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
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
    final currentImage = widget.userData['profile_image'];
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    } else if (_isImageDeleted) {
      base64Image = 'DELETE';
    }

    final newName = _nameCtrl.text != widget.userData['name'] ? _nameCtrl.text : null;
    final newPhone = _phoneCtrl.text != widget.userData['phone'] ? _phoneCtrl.text : null;

    if (newName == null && newPhone == null && base64Image == null) {
      Navigator.pop(context, false);
      return;
    }

    final result = await _authService.updateProfile(
      name: newName,
      phone: newPhone,
      imageBase64: base64Image,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Perfil actualizado'), backgroundColor: Colors.green),
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
    final currentImage = widget.userData['profile_image'];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
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
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 3),
                        ),
                        child: ClipOval(
                          child: _isImageDeleted 
                              ? Icon(Icons.person, size: 60, color: colorScheme.primary)
                              : _selectedImage != null
                                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                  : (currentImage != null && currentImage.toString().isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: currentImage,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 300,
                                          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (_, __, ___) => Icon(Icons.person, size: 60, color: colorScheme.primary),
                                        )
                                      : Icon(Icons.person, size: 60, color: colorScheme.primary),
                        ),
                      ),
                      Container(
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
              const SizedBox(height: 40),

              const Text('Nombre de Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'El nombre es obligatorio' : null,
              ),
              
              const SizedBox(height: 20),

              const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_outlined),
                  hintText: '+56 9 1234 5678',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text('Correo Electrónico (No editable)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: widget.userData['email'],
                readOnly: true,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('GUARDAR CAMBIOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}