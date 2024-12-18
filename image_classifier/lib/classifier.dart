import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
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
  String _classificationResult = "No prediction";

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    _interpreter =
        await Interpreter.fromAsset('assets/yolov8n-cls_float32.tflite');
  }

  Future<void> _loadLabels() async {
    final labelsData =
        await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
    setState(() {
      _labels = labelsData.split('\n');
    });
  }

  Future<void> _classifyImage(File imageFile) async {
    // Convert the image to YOLO input tensor
    final inputTensor = await _createYOLOInputTensor(imageFile);

    // Run inference
    final outputTensor =
        List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);
        
    _interpreter!.run(inputTensor, outputTensor);

    List<double> probabilities = outputTensor.first;
    int highestProbabilityIndex = probabilities
      .indexWhere((element) => element == probabilities.reduce(max));
    
    // print('Veysel $highestProbabilityIndex');   
    
    final label = _labels![highestProbabilityIndex];
    final confidence = probabilities[highestProbabilityIndex];

    setState(() {
      _classificationResult =
          "$label: ${(confidence * 100).toStringAsFixed(2)}%";
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _classificationResult = 'Classifying...';
      });
      await _classifyImage(_image!);
    }
  }

  
  Future<List<List<List<List<double>>>>> _createYOLOInputTensor(
      File imageFile) async {
    // Load the image using the `image` package
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    // Define YOLO input size
    const int inputSize = 416;

    // Resize the image to YOLO input size (416x416)
    // Should we make this linear?
    final img.Image resizedImage =
        img.copyResize(image!, width: inputSize, height: inputSize);
    /*
    final resizedImage = img.copyResize(image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear);*/

    // Normalize and convert the image to a 4D tensor
    List<List<List<List<double>>>> inputTensor = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            final r = pixel.r / 255.0;
            final g = pixel.r / 255.0;
            final b = pixel.r / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );

    return inputTensor;
  }
  
  /*
  Future<List<dynamic>> _createYOLOInputTensor(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    // Define YOLO input size
    const int imageWidth = 224;
    const int imageHeight = 224;

    img.Image resizedImage =
        img.copyResize(image!, width: imageWidth, height: imageHeight);

    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [channel.r, channel.g, channel.b])
        .map((value) => value.toDouble())
        .toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = imageWidth;
    int width = imageWidth;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] =
              (float32Array[c * height * width + h * width + w] - 127.5) /
                  127.5;
        }
      }
    }

    return reshapedArray.reshape([1, 224, 224, 3]);
  }
  */

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MobileNet Image Classification')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: _image != null ? Image.file(_image!) : Text('No image selected.'),
          ),
          SizedBox(height: 16),
          Text(
            _classificationResult,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
        ],
      ),
    );
  }
}
