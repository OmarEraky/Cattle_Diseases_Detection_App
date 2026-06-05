import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cattle_disease_app/core/errors/app_exception.dart';

class ImageInputController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _errorMessage;
  bool _isPicking = false;

  File? get selectedImage => _selectedImage;
  String? get errorMessage => _errorMessage;
  bool get isPicking => _isPicking;

  /// Selects an image using camera or gallery
  Future<void> pickImage(ImageSource source) async {
    _isPicking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Handle camera/gallery permission check
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status.isDenied) {
          throw PermissionException('Camera permission is required to take photos of cattle.');
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    } on PermissionException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
    } finally {
      _isPicking = false;
      notifyListeners();
    }
  }

  /// Reset current image selection
  void clearImage() {
    _selectedImage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
