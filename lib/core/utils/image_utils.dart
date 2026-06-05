import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:cattle_disease_app/core/errors/app_exception.dart';

class ImageUtils {
  /// Decodes a file, crops a sub-region (defined by bounding box percentages or absolute pixels),
  /// and saves the cropped region as a new temporary JPEG file.
  static Future<File> cropBodyPart({
    required File originalImage,
    required double xPercent,      // Bounding box X start relative (0.0 to 1.0)
    required double yPercent,      // Bounding box Y start relative (0.0 to 1.0)
    required double widthPercent,  // Bounding box width relative (0.0 to 1.0)
    required double heightPercent, // Bounding box height relative (0.0 to 1.0)
  }) async {
    try {
      final bytes = await originalImage.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw ImageProcessingException('Failed to decode the original image.');
      }

      // Convert relative dimensions to absolute pixel values
      final int originalWidth = image.width;
      final int originalHeight = image.height;

      int x = (xPercent * originalWidth).clamp(0, originalWidth).toInt();
      int y = (yPercent * originalHeight).clamp(0, originalHeight).toInt();
      int width = (widthPercent * originalWidth).clamp(1, originalWidth - x).toInt();
      int height = (heightPercent * originalHeight).clamp(1, originalHeight - y).toInt();

      // Crop the image using the dart 'image' package
      final croppedImage = img.copyCrop(image, x: x, y: y, width: width, height: height);

      // Save the cropped image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final croppedFile = File(tempPath);
      
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));
      return croppedFile;
    } catch (e) {
      throw ImageProcessingException('Error cropping selected body part: $e');
    }
  }

  /// Resizes a image file to target width and height and converts it to a Float32List
  /// normalized to [0, 1] (or standard mean/std if model requires it)
  /// Outputs [1, targetHeight, targetWidth, 3] representation as a flat Float32List
  static Future<Float32List> preprocessForClassifier({
    required File imageFile,
    required int targetWidth,
    required int targetHeight,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw ImageProcessingException('Failed to decode image for classifier.');
      }

      // Resize
      final resizedImage = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
      );

      // Allocate memory for flat Float32List: height * width * channels (RGB = 3)
      final Float32List buffer = Float32List(targetHeight * targetWidth * 3);
      int index = 0;

      for (int y = 0; y < targetHeight; y++) {
        for (int x = 0; x < targetWidth; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // Extract RGB values (image package contains rgb channels normalized to [0, 255])
          // We normalize to [0, 1] range: value / 255.0
          buffer[index++] = pixel.r / 255.0;
          buffer[index++] = pixel.g / 255.0;
          buffer[index++] = pixel.b / 255.0;
        }
      }

      return buffer;
    } catch (e) {
      throw ImageProcessingException('Failed to preprocess image for classifier: $e');
    }
  }

  /// Generate a flat Float32List representation from an image file for YOLO input
  static Future<Float32List> preprocessForYolo({
    required File imageFile,
    required int targetWidth,
    required int targetHeight,
  }) async {
    // YOLO models typically require normalized images (0.0 to 1.0)
    return preprocessForClassifier(
      imageFile: imageFile,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }
}
