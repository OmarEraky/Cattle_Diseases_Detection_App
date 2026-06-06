import 'dart:io';
import 'package:image/image.dart' as img;
import '../../../core/errors/app_exception.dart';

class PreprocessingService {
  // Decode image from file
  Future<img.Image> loadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw ImageProcessingException('Failed to decode image file');
      }
      return image;
    } catch (e) {
      throw ImageProcessingException('Error reading or decoding image', e.toString());
    }
  }

  // Preprocess image for classifier (NHWC shape: [1, size, size, 3] with ImageNet normalization)
  Future<List<List<List<List<double>>>>> preprocessForClassifier(
    File imageFile, {
    int size = 224,
    List<double> mean = const [0.485, 0.456, 0.406],
    List<double> std = const [0.229, 0.224, 0.225],
  }) async {
    final image = await loadImage(imageFile);
    
    // Resize image using cubic/bilinear interpolation
    final resized = img.copyResize(image, width: size, height: size);

    // Create 4D array: [1, size, size, 3]
    final input = List.generate(
      1,
      (_) => List.generate(
        size,
        (y) => List.generate(
          size,
          (x) {
            // Get pixel color at (x, y)
            final pixel = resized.getPixel(x, y);
            
            // In package:image v4, getPixel returns a Pixel object with r, g, b, a channels.
            // Let's normalize from [0, 255] to [0, 1] then apply ImageNet mean/std
            final r = pixel.r / 255.0;
            final g = pixel.g / 255.0;
            final b = pixel.b / 255.0;

            final nr = (r - mean[0]) / std[0];
            final ng = (g - mean[1]) / std[1];
            final nb = (b - mean[2]) / std[2];

            return [nr, ng, nb];
          },
        ),
      ),
    );

    return input;
  }

  // Preprocess image for YOLO segmentation (NHWC shape: [1, size, size, 3] normalized [0, 1])
  Future<List<List<List<List<double>>>>> preprocessForYolo(
    File imageFile, {
    int size = 640,
  }) async {
    final image = await loadImage(imageFile);
    final resized = img.copyResize(image, width: size, height: size);

    final input = List.generate(
      1,
      (_) => List.generate(
        size,
        (y) => List.generate(
          size,
          (x) {
            final pixel = resized.getPixel(x, y);
            final r = pixel.r / 255.0;
            final g = pixel.g / 255.0;
            final b = pixel.b / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );

    return input;
  }
}
