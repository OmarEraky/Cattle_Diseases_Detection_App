import 'dart:io';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';
import '../models/crop_type.dart';

class CropResult {
  final String cropPath;
  final CropType cropTypeUsed;
  final String? warning;

  CropResult({
    required this.cropPath,
    required this.cropTypeUsed,
    this.warning,
  });
}

class CropService {
  static int _counter = 0;

  Future<CropResult> crop({
    required File originalImageFile,
    required Rect boundingBox,
    required CropType requiredCropType,
    List<List<double>>? mask,
  }) async {
    try {
      final bytes = await originalImageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw ImageProcessingException('Failed to decode original image for cropping');
      }

      // Convert Rect coordinates to pixel integers and clamp within bounds
      final int imgWidth = originalImage.width;
      final int imgHeight = originalImage.height;

      int x = boundingBox.left.round().clamp(0, imgWidth - 1);
      int y = boundingBox.top.round().clamp(0, imgHeight - 1);
      int w = boundingBox.width.round().clamp(1, imgWidth - x);
      int h = boundingBox.height.round().clamp(1, imgHeight - y);

      // Perform crop
      var croppedImage = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);

      CropType cropTypeUsed = CropType.rectangular;
      String? warning;

      if (requiredCropType == CropType.masked) {
        if (mask != null) {
          cropTypeUsed = CropType.masked;
          // Apply mask. Assume mask is a 2D grid of size (w, h) or can be sampled
          // Let's modify pixels where mask is low (e.g. < 0.5) to black
          final int maskH = mask.length;
          final int maskW = maskH > 0 ? mask[0].length : 0;

          if (maskW > 0 && maskH > 0) {
            for (int cy = 0; cy < croppedImage.height; cy++) {
              for (int cx = 0; cx < croppedImage.width; cx++) {
                // Map cropped pixel coordinate to mask coordinate
                final int mx = ((cx / croppedImage.width) * maskW).floor().clamp(0, maskW - 1);
                final int my = ((cy / croppedImage.height) * maskH).floor().clamp(0, maskH - 1);
                
                final double maskVal = mask[my][mx];
                if (maskVal < 0.5) {
                  // Set pixel to black
                  croppedImage.setPixelRgb(cx, cy, 0, 0, 0);
                }
              }
            }
          } else {
            warning = 'Masked crop was required, but mask dimensions were invalid. Fell back to rectangular crop.';
          }
        } else {
          warning = 'Masked crop was required by the classifier, but YOLO segmentation masks are not supported/available.';
        }
      }

      // Save the cropped image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final cropFile = File('${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}_${_counter++}.jpg');
      
      // Write jpeg bytes
      await cropFile.writeAsBytes(img.encodeJpg(croppedImage));

      return CropResult(
        cropPath: cropFile.path,
        cropTypeUsed: cropTypeUsed,
        warning: warning,
      );
    } catch (e) {
      throw ImageProcessingException('Failed to crop image', e.toString());
    }
  }
}
