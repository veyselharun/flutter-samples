// Decouple ChatScreen
import 'package:flutter/material.dart';
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'On-Device LLM Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _engine = LlamaEngine(LlamaBackend());
  String _output = '';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    final path = await getModelPath();
    await _engine.loadModel(path);
    setState(() => _isLoaded = true);
  }

  Future<void> _generate(String prompt) async {
    setState(() => _output = '');

    String buffer = '';
    await for (final token in _engine.generate(prompt)) {
      buffer += token;
      setState(() => _output = cleanLLMOutput(buffer));
    }
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('On-Device LLM Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isLoaded)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Column(
                  children: [
                    ChatOutputSection(output: _output),
                    SizedBox(height: 12),
                    ChatInputSection(generate: _generate),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatInputSection extends StatefulWidget {
  const ChatInputSection({super.key, required this.generate});

  final Future<void> Function(String) generate;

  @override
  State<ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends State<ChatInputSection> {
  final _textEditingController = TextEditingController();

  void preparePrompt() {
    final prompt = _textEditingController.text;
    if (prompt.isNotEmpty) {
      widget.generate(prompt);
      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Ask something...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colorScheme.outline, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          onPressed: preparePrompt,
          child: const Icon(Icons.send),
        ),
      ],
    );
  }
}

class ChatOutputSection extends StatelessWidget {
  const ChatOutputSection({super.key, required this.output});

  final String output;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(reverse: true, child: Text(output)),
      ),
    );
  }
}

Future<String> getModelPath() async {
  final dir = await getApplicationDocumentsDirectory();
  final modelFile = File('${dir.path}/Qwen3.5-0.8B-Q4_K_M.gguf');

  if (!await modelFile.exists()) {
    // First run: copy from assets to filesystem
    final data = await rootBundle.load(
      'assets/models/Qwen3.5-0.8B-Q4_K_M.gguf',
    );
    await modelFile.writeAsBytes(data.buffer.asUint8List());
  }

  return modelFile.path;
}

// Clean model formatting artifacts
String cleanLLMOutput(String text) {
  return text
      .replaceAll('<s>', '')
      .replaceAll('</s>', '')
      .replaceAll('[INST]', '')
      .replaceAll('[/INST]', '')
      .replaceAll('<<SYS>>', '')
      .replaceAll('<</SYS>>', '')
      .replaceAll('<think>', '')
      .replaceAll('</think>', '')
      .replaceAll('<0x0A>', '\n')
      .replaceAll('<0x09>', '\t')
      .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m[1] ?? '')
      .replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m[1] ?? '')
      .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '')
      .trimLeft();
}
