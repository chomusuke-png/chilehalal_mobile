import 'package:flutter/material.dart';

enum ImagePickerAction { camera, gallery, delete }

class ImagePickerHelper {
  static Future<ImagePickerAction?> showActionSheet(
    BuildContext context, {
    required bool hasExistingImage,
  }) {
    return showModalBottomSheet<ImagePickerAction>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(context, ImagePickerAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Subir de galería'),
                onTap: () => Navigator.pop(context, ImagePickerAction.gallery),
              ),
              if (hasExistingImage) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Eliminar foto', 
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => Navigator.pop(context, ImagePickerAction.delete),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}