import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:math';

class MobileDetectionHelper {
  static Future<FaceDetector> createDetector() async {
    return FaceDetector(options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ));
  }

  static Future<List<dynamic>> processImage(dynamic detector, CameraImage image, CameraDescription camera) async {
    if (detector is! FaceDetector) return [];

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.yuv420;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
    return await detector.processImage(inputImage);
  }

  static Map<String, Offset?> getLandmarks(dynamic face) {
    if (face is! Face) return {};
    return {
      'leftEye': face.landmarks[FaceLandmarkType.leftEye]?.position.toOffset(),
      'rightEye': face.landmarks[FaceLandmarkType.rightEye]?.position.toOffset(),
      'noseBase': face.landmarks[FaceLandmarkType.noseBase]?.position.toOffset(),
    };
  }

  static Rect getBoundingBox(dynamic face) {
    if (face is! Face) return Rect.zero;
    return face.boundingBox;
  }
}

extension PointToOffset on Point<int> {
  Offset toOffset() => Offset(x.toDouble(), y.toDouble());
}
