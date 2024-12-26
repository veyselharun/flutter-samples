// Object detection exmaple using YOLO.
//
// https://docs.ultralytics.com/modes/export/
// https://docs.ultralytics.com/models/yolo11/
// https://docs.ultralytics.com/models/yolov8/


import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Detection class to hold results
class Detection {
  final Rect boundingBox;
  final double confidence;
  final int classId;

  Detection({
    required this.boundingBox,
    required this.confidence,
    required this.classId,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  List<String>? _labels;
  Interpreter? _interpreter;
  String _detectionResult = "No detection";
  DetectionView? detectionView;

  // Constants
  final double confidenceThreshold = 0.25;
  final double iouThreshold = 0.45;


  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    _interpreter =
        await Interpreter.fromAsset('assets/yolov8m_float32.tflite');
    print(_interpreter!.getInputTensor(0).shape);
    print(_interpreter!.getOutputTensor(0).shape);
  }

  // Load labels from the asset file
  Future<void> _loadLabels() async {
    final labelsData =
        await DefaultAssetBundle.of(context).loadString('assets/coco_labels_2014_2017.txt');
    setState(() {
      _labels = labelsData.split('\n');
    });
  }

  List<Detection> processModelOutput(List<List<List<double>>> modelOutput) {
    // modelOutput shape: [1, 84, 8400]
    // modelOutput[0] shape: [84, 8400]
    final outputs = modelOutput[0]; // Get first batch
    
    // Separate box coordinates and class scores
    final boxes = <Rect>[];
    final scores = <double>[];
    final classes = <int>[];
    
    // For each of the 8400 predictions
    for (var i = 0; i < 8400; i++) {
      // Extract box coordinates (first 4 values)
      final x = outputs[0][i];
      final y = outputs[1][i];
      final w = outputs[2][i];
      final h = outputs[3][i];
      
      // Convert to Rect
      final rect = Rect.fromLTWH(
        x - w/2, // Convert from center to top-left
        y - h/2,
        w,
        h
      );
      
      // Find class with highest score
      var maxScore = 0.0;
      var maxClass = 0;
      for (var c = 0; c < 80; c++) {
        final score = outputs[c + 4][i];
        if (score > maxScore) {
          maxScore = score;
          maxClass = c;
        }
      }
      
      if (maxScore > confidenceThreshold) {
        final absoluteRect = Rect.fromLTWH(
          rect.left * 640,
          rect.top * 640,
          rect.width * 640,
          rect.height * 640
        );

        boxes.add(absoluteRect);
        scores.add(maxScore);
        classes.add(maxClass);
      }
    }
    
    // Apply Non-Max Suppression
    final indices = nonMaxSuppression(boxes, scores, iouThreshold);
    
    // Create final detections list
    final detections = indices.map((i) => Detection(
      boundingBox: boxes[i],
      confidence: scores[i],
      classId: classes[i]
    )).toList();
    
    return detections;
  }

  // Non-Max Suppression implementation
  List<int> nonMaxSuppression(List<Rect> boxes, List<double> scores, double iouThreshold) {
    final indices = <int>[];
    
    // Create list of indices
    final indexList = List<int>.generate(scores.length, (i) => i);
    
    // Sort indices by scores in descending order
    indexList.sort((a, b) => scores[b].compareTo(scores[a]));
    
    while (indexList.isNotEmpty) {
      final index = indexList[0];
      indices.add(index);
      
      indexList.removeAt(0);
      
      // Remove boxes with high IoU
      indexList.removeWhere((compareIndex) {
        final overlap = _calculateIoU(boxes[index], boxes[compareIndex]);
        return overlap >= iouThreshold;
      });
    }
    
    return indices;
  }

  // Calculate Intersection over Union (IoU)
  double _calculateIoU(Rect box1, Rect box2) {
    final intersectionRect = box1.intersect(box2);
    
    if (intersectionRect.isEmpty) return 0.0;
    
    final intersectionArea = intersectionRect.width * intersectionRect.height;
    final box1Area = box1.width * box1.height;
    final box2Area = box2.width * box2.height;
    final unionArea = box1Area + box2Area - intersectionArea;
    
    return intersectionArea / unionArea;
  }

  Future<void> _detectObjects(File imageFile) async {
    // Create input tensor
    // Convert the image to YOLO input tensor
    // Input tensor is a 4D array with shape [1, 640, 640, 3]
    final List<List<List<List<double>>>> inputTensor = await _createYOLOInputTensor(imageFile);

    // Create output tensor
    // Output tensor is a 3D array with shape [1, 84, 8400]
    final List<List<List<double>>> outputTensor = List.generate(
      1,
      (_) => List.generate(
        84,
        (_) => List.filled(8400, 0.0)
      )
    );

    // Run inference
    _interpreter!.run(inputTensor, outputTensor);

    final detections = processModelOutput(outputTensor);

    // Process detections
    for (final detection in detections) {
      print('Veysel: Class: ${detection.classId}');
      print('Veysel: Confidence: ${detection.confidence}');
      print('Veysel: Bounding Box: ${detection.boundingBox}');
    }

    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    Size originalImageSize = Size(image.width.toDouble(), image.height.toDouble());
    setState(() {
      detectionView = DetectionView(detections: detections, image: Image.file(imageFile), originalImageSize: originalImageSize, labels: _labels!,);    
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detectionResult = 'Detecting';
      });
      await _detectObjects(_image!);
    }
  }

  Future<List<List<List<List<double>>>>> _createYOLOInputTensor(
      File imageFile) async {
    // Load the image using the `image` package
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    // Define the YOLO input size
    // For YOLO classification input size should be 640
    const int inputSize = 640;

    // Resize the image to YOLO input size (640x640)
    // Should we make this linear?
    final img.Image resizedImage =
        img.copyResize(image!, width: inputSize, height: inputSize);

    // Normalize and convert the image to a 4D tensor
    // The tensor shape should be [1, 640, 640, 3] and normalized between 0 and 1
    // We can use List<dynamic>. If we choose to do that we also need to change the return value.
    List<List<List<List<double>>>> inputTensor = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            // Get pixel values
            final pixel = resizedImage.getPixel(x, y);
            // Normalize pixel values between 0 and -1.
            // If you want to normalize between -1 and 1 the formula should be like
            // (pixel_value - 127.5) / 127.5
            final r = pixel.r / 255.0;
            final g = pixel.g / 255.0;
            final b = pixel.b / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );

    return inputTensor;
  }
  
  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YOLO Object Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _image != null ? Image.file(_image!) : Text('No image selected.'),
            ),
            SizedBox(height: 16),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: detectionView != null ? detectionView! : Text('No image selected.'),
            ),
            SizedBox(height: 16),
            Text(
              _detectionResult,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }
}


class DetectionView extends StatelessWidget {
  final List<Detection> detections;
  final Image image;
  final Size originalImageSize;
  final List<String> labels;

  const DetectionView({
    super.key,
    required this.detections,
    required this.image,
    required this.originalImageSize,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        
        return CustomPaint(
          foregroundPainter: BoundingBoxPainter(
            detections: detections,
            originalImageSize: originalImageSize,
            labels: labels,
          ),
          child: image,
        );
      },
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final Size originalImageSize;  // Original image size before resize
  final List<String> labels;
  
  BoundingBoxPainter({
    required this.detections,
    required this.originalImageSize,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final double aspectRatio = originalImageSize.width / originalImageSize.height;
    final double newWidth, newHeight;
    if (aspectRatio > 1) {
      newWidth = 300;
      newHeight = 300 / aspectRatio;
    } else {
      newWidth = 300 / aspectRatio;
      newHeight = 300;
    }
    final Size displaySize = Size(newWidth, newHeight);
    final topMargin = (300 - newHeight) / 2;

    // Calculate scaling factors from model input (640x640) to original image size
    final modelToOriginalScaleX = originalImageSize.width / 640;
    final modelToOriginalScaleY = originalImageSize.height / 640;

    // Calculate scaling factors from original to display size
    final originalToDisplayScaleX = displaySize.width / originalImageSize.width;
    final originalToDisplayScaleY = displaySize.height / originalImageSize.height;

    for (final detection in detections) {
      // First, scale from model input size (640x640) to original image size
      final originalRect = Rect.fromLTWH(
        detection.boundingBox.left * modelToOriginalScaleX,
        detection.boundingBox.top * modelToOriginalScaleY,
        detection.boundingBox.width * modelToOriginalScaleX,
        detection.boundingBox.height * modelToOriginalScaleY,
      );

      // Then, scale to display size
      final displayRect = Rect.fromLTWH(
        originalRect.left * originalToDisplayScaleX,
        (originalRect.top * originalToDisplayScaleY) + topMargin,
        originalRect.width * originalToDisplayScaleX,
        originalRect.height * originalToDisplayScaleY,
      );

      // Draw bounding box
      canvas.drawRect(displayRect, paint);

      // Draw label
      final label = '${labels[detection.classId]} ${(detection.confidence * 100).toStringAsFixed(1)}%';
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.red,
          fontSize: 14,
        ),
      );
      
      textPainter.layout();

      // Draw label background
      final textBgPaint = Paint()..color = Colors.red;
      canvas.drawRect(
        Rect.fromLTWH(
          displayRect.left,
          displayRect.top - textPainter.height,
          textPainter.width,
          textPainter.height
        ),
        textBgPaint,
      );

      // Draw text
      textPainter.paint(
        canvas,
        Offset(displayRect.left, displayRect.top - textPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}