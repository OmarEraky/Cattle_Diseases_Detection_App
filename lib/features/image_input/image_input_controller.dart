import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final selectedImageProvider = StateProvider<File?>((ref) => null);

class ImageInputController {
  final ImagePicker _picker;
  final Ref _ref;

  ImageInputController(this._picker, this._ref);

  Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        _ref.read(selectedImageProvider.notifier).state = file;
        return file;
      }
    } catch (_) {
      // Fail silently or handle error in UI
    }
    return null;
  }

  void clear() {
    _ref.read(selectedImageProvider.notifier).state = null;
  }
}

final imageInputControllerProvider = Provider<ImageInputController>((ref) {
  final picker = ref.watch(imagePickerProvider);
  return ImageInputController(picker, ref);
});
