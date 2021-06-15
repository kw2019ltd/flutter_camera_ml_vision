part of 'flutter_camera_ml_vision.dart';

Future<CameraDescription?> _getCamera(CameraLensDirection dir) async {
  final cameras = await availableCameras();
  final camera =
      cameras.firstWhereOrNull((camera) => camera.lensDirection == dir);
  return camera ?? (cameras.isEmpty ? null : cameras.first);
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final allBytes = WriteBuffer();
  planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

Future<T> _detect<T>(
  CameraImage image,
  HandleDetection<T> handleDetection,
  InputImageRotation rotation,
) async {
  return handleDetection(_processCameraImage(image));
}

InputImage _processCameraImage(CameraImage image) {
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

  final imageRotation = InputImageRotation.Rotation_0deg;

  final inputImageFormat =
      InputImageFormatMethods.fromRawValue(image.format.raw) ??
          InputImageFormat.NV21;

  final planeData = image.planes.map(
    (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();

  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: imageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );

  return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
}

InputImageRotation _rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return InputImageRotation.Rotation_0deg;
    case 90:
      return InputImageRotation.Rotation_90deg;
    case 180:
      return InputImageRotation.Rotation_180deg;
    default:
      assert(rotation == 270);
      return InputImageRotation.Rotation_270deg;
  }
}
