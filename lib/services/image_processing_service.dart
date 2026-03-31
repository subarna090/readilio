import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class ImageProcessingService {
  static const _maxDimension = 1200;

  /// Pre-processes a captured image for OCR.
  /// Returns path to the processed image.
  Future<String> preprocess(String inputPath, String outputDir) async {
    final outputPath = p.join(outputDir, 'processed_${p.basename(inputPath)}');

    // Step 1: Compress and resize to max 1200px wide (fast path via plugin)
    final compressed = await FlutterImageCompress.compressAndGetFile(
      inputPath,
      outputPath,
      minWidth: 800,
      minHeight: 600,
      quality: 88,
    );

    if (compressed == null) {
      // Fallback: copy original
      await File(inputPath).copy(outputPath);
      return outputPath;
    }

    // Step 2: Load with image package for further processing
    final bytes = await File(compressed.path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return outputPath;

    // Step 3: Resize if still too large
    if (image.width > _maxDimension || image.height > _maxDimension) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: _maxDimension);
      } else {
        image = img.copyResize(image, height: _maxDimension);
      }
    }

    // Step 4: Convert to grayscale for better OCR accuracy
    image = img.grayscale(image);

    // Step 5: Adjust brightness/contrast
    image = img.adjustColor(image, contrast: 1.2, brightness: 0.0);

    // Save processed image
    final processedBytes = img.encodeJpg(image, quality: 90);
    await File(outputPath).writeAsBytes(processedBytes);

    return outputPath;
  }

  /// Detects capture quality issues.
  /// Returns a [CaptureGuidance] with warnings.
  Future<CaptureGuidance> analyzeCapture(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      return const CaptureGuidance(isTooBlurry: true);
    }

    final gray = img.grayscale(image);
    final pixels = gray.getBytes(order: img.ChannelOrder.red);

    // Brightness check: average luminance
    double sum = 0;
    for (final p in pixels) {
      sum += p;
    }
    final avgBrightness = sum / pixels.length;
    final isToooDark = avgBrightness < 60;

    // Blur check: variance of Laplacian (simple approximation)
    // We approximate by checking variance across the grayscale values
    double variance = 0;
    for (final p in pixels) {
      final diff = p - avgBrightness;
      variance += diff * diff;
    }
    variance /= pixels.length;
    final isTooBlurry = variance < 200;

    return CaptureGuidance(
      isTooDark: isToooDark,
      isTooBlurry: isTooBlurry,
    );
  }
}

class CaptureGuidance {
  final bool isTooDark;
  final bool isTooBlurry;
  final bool isGlare;

  const CaptureGuidance({
    this.isTooDark = false,
    this.isTooBlurry = false,
    this.isGlare = false,
  });

  bool get hasIssue => isTooDark || isTooBlurry || isGlare;

  String get message {
    if (isTooDark) return 'Too dark — move to better light';
    if (isTooBlurry) return 'Hold steady for a clearer shot';
    if (isGlare) return 'Reduce glare by tilting the book';
    return '';
  }
}
