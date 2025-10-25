import 'package:tflite_flutter/tflite_flutter.dart';

class RiskPredictor {
  static final RiskPredictor _instance = RiskPredictor._internal();
  factory RiskPredictor() => _instance;
  RiskPredictor._internal();

  Interpreter? _interpreter;
  bool get isModelLoaded => _interpreter != null;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/risk_model.tflite');
      print('TFLite model loaded successfully');
    } catch (e) {
      print('Error loading TFLite model: $e');
      rethrow;
    }
  }

  Future<double> predictRisk(List<double> inputData) async {
    if (_interpreter == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      final input = [inputData];
      // Output shape should match your model's output, e.g. [1, 1] for a single float
      var output = List<List<double>>.generate(1, (_) => List.filled(1, 0.0));
      _interpreter!.run(input, output);
      double score = output[0][0];
      if (score.isNaN) score = 0.0;
      return score.clamp(0.0, 1.0);
    } catch (e) {
      print('Error during prediction: $e');
      return 0.0;
    }
  }

  String getRiskLabel(double score) {
    return score <= 0.5 ? 'Safe' : 'Risk';
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
