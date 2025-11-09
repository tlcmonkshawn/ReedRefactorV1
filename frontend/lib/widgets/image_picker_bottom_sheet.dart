import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bootiehunter/services/image_service.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final ImageService imageService;
  final Function(File) onImageSelected;
  final bool allowMultiple;

  const ImagePickerBottomSheet({
    super.key,
    required this.imageService,
    required this.onImageSelected,
    this.allowMultiple = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowMultiple)
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose Multiple from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final images = await imageService.pickMultipleImages();
                  for (var image in images) {
                    onImageSelected(image);
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await imageService.pickImageFromGallery();
                if (image != null) {
                  onImageSelected(image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await imageService.pickImageFromCamera();
                if (image != null) {
                  onImageSelected(image);
                }
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required ImageService imageService,
    required Function(File) onImageSelected,
    bool allowMultiple = false,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImagePickerBottomSheet(
        imageService: imageService,
        onImageSelected: onImageSelected,
        allowMultiple: allowMultiple,
      ),
    );
  }
}

