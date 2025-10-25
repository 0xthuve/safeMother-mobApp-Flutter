import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as g_auth;

class FoodScanPage extends StatefulWidget {
  @override
  _FoodScanPageState createState() => _FoodScanPageState();
}

class _FoodScanPageState extends State<FoodScanPage> {
  Map<String, dynamic>? _scanResult;
  bool _loading = false;
  String? _errorMessage;
  g_auth.AutoRefreshingAuthClient? _client;
  List<String> _detectedLabels = [];

  @override
  void initState() {
    super.initState();
    _initClient();
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }

  Future<void> _initClient() async {
    if (_client != null) return;
    try {
      final serviceAccountJson = await rootBundle
          .loadString('assets/still-cipher-468306-p2-aae0a6034688.json');
      final serviceAccountCredentials =
          g_auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      _client = await g_auth.clientViaServiceAccount(
        serviceAccountCredentials,
        ['https://www.googleapis.com/auth/cloud-platform'],
      );
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      print('Error initializing Google Cloud client: $e');
      setState(() {
        _errorMessage = 'Failed to initialize Google Cloud client: $e';
      });
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.camera);
  }

  Future<List<String>> getFoodLabels(File imageFile) async {
    if (_client == null) {
      throw Exception('Google Cloud client not initialized.');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    const url = 'https://vision.googleapis.com/v1/images:annotate';
    final body = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 10}
          ]
        }
      ]
    });

    final response = await _client!.post(Uri.parse(url),
        body: body, headers: {"Content-Type": "application/json"});

    if (response.statusCode != 200) {
      throw Exception('Failed to get labels: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['responses'] == null ||
        data['responses'].isEmpty ||
        data['responses'][0]['labelAnnotations'] == null) {
      return [];
    }

    final labels = data['responses'][0]['labelAnnotations'] as List;
    return labels.map((l) => l['description'] as String).toList();
  }

  Future<Map<String, dynamic>> loadFoodSafetyData() async {
    final jsonStr = await rootBundle.loadString('assets/food_safety.json');
    return jsonDecode(jsonStr);
  }

  Map<String, dynamic>? findFoodInDatabase(
      List<String> labels, Map<String, dynamic> foodData) {
    // Search through all categories in the food database
    final Map<String, dynamic> foods =
        foodData['Food Safety Guide for Pregnancy']['foods'];

    for (var label in labels) {
      final lowerLabel = label.toLowerCase();

      // Search in all categories
      for (var category in foods.keys) {
        final categoryFoods = foods[category] as Map<String, dynamic>?;
        if (categoryFoods != null && categoryFoods.containsKey(lowerLabel)) {
          return {
            'name': label,
            'category': category,
            ...categoryFoods[lowerLabel]
          };
        }
      }

      // Try partial matching for common food names
      for (var category in foods.keys) {
        final categoryFoods = foods[category] as Map<String, dynamic>?;
        if (categoryFoods != null) {
          for (var foodKey in categoryFoods.keys) {
            if (lowerLabel.contains(foodKey) || foodKey.contains(lowerLabel)) {
              return {
                'name': label,
                'category': category,
                ...categoryFoods[foodKey]
              };
            }
          }
        }
      }
    }

    return null;
  }

  Future<void> scanFood() async {
    setState(() {
      _loading = true;
      _scanResult = null;
      _errorMessage = null;
      _detectedLabels = [];
    });

    try {
      if (_client == null) {
        await _initClient();
        if (_client == null) {
          setState(() {
            _errorMessage =
                _errorMessage ?? 'Google Cloud client not initialized.';
            _loading = false;
          });
          return;
        }
      }

      final image = await pickImageFromCamera();
      if (image == null) {
        setState(() {
          _errorMessage = 'No image selected.';
          _loading = false;
        });
        return;
      }

      _detectedLabels = await getFoodLabels(File(image.path));
      final foodData = await loadFoodSafetyData();
      final result = findFoodInDatabase(_detectedLabels, foodData);

      setState(() {
        _scanResult = result;
        if (result == null && _detectedLabels.isNotEmpty) {
          _errorMessage =
              'Food not found in database. Detected: ${_detectedLabels.join(", ")}';
        } else if (result == null) {
          _errorMessage =
              'No food items detected. Please try again with a clearer image.';
        }
      });
    } catch (e) {
      print('Error during food scan: $e');
      setState(() {
        _errorMessage = 'Error during scan: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Safety Scanner'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: _loading
              ? _buildLoadingWidget()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildScanButton(),
                    SizedBox(height: 24),
                    if (_scanResult != null) _buildResultCard(_scanResult!),
                    if (_errorMessage != null) _buildErrorCard(_errorMessage!),
                    if (_detectedLabels.isNotEmpty && _scanResult == null)
                      _buildDetectedLabelsCard(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          strokeWidth: 4,
        ),
        SizedBox(height: 20),
        Text(
          'Scanning your food...',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Please wait while we analyze the image',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade300,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.camera_alt, size: 40, color: Colors.white),
            onPressed: scanFood,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Tap to Scan Food',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Take a picture of any food item',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final bool isSafe = result['safe'] == true;
    final String foodName = result['name'] ?? 'Unknown Food';
    final String category =
        result['category']?.toString().replaceAll('_', ' ') ?? 'General';

    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSafe ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSafe ? Icons.check_circle : Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          isSafe ? 'SAFE TO EAT' : 'AVOID',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Icon(
                    isSafe ? Icons.emoji_food_beverage : Icons.no_food,
                    color: isSafe ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Food Name
              Text(
                foodName.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),

              SizedBox(height: 4),

              // Category
              Text(
                'Category: $category',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),

              SizedBox(height: 16),

              // Safety Advice
              _buildInfoSection(
                'Safety Advice',
                result['advice'] ?? 'No specific advice available.',
                Icons.health_and_safety,
                isSafe ? Colors.green : Colors.red,
              ),

              SizedBox(height: 12),

              // Nutrition Information
              // FIX: Check if 'nutrition' is a Map and access the 'details' field
              if (result['nutrition'] != null && result['nutrition'] is Map)
                _buildInfoSection(
                  'Nutrition',
                  (result['nutrition']['details'] as String?) ??
                      'No nutrition details available.',
                  Icons.local_dining,
                  Colors.orange,
                ),

              SizedBox(height: 12),

              // Calories
              if (result['calories'] != null)
                _buildInfoSection(
                  'Calories',
                  result['calories'],
                  Icons.local_fire_department,
                  Colors.orange.shade700,
                ),

              SizedBox(height: 12),

              // Consumption Recommendation
              if (result['consumption'] != null)
                _buildInfoSection(
                  'Recommended Intake',
                  result['consumption'],
                  Icons.timeline,
                  Colors.blue,
                ),

              SizedBox(height: 16),

              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag(
                      'Pregnancy Safe', isSafe ? Colors.green : Colors.red),
                  // FIX: Check if 'nutrition' is a Map and access the 'level' field
                  if (result['nutrition'] != null &&
                      result['nutrition'] is Map &&
                      result['nutrition']['level'] != null)
                    _buildTag('Nutrition: ${result['nutrition']['level']}',
                        Colors.orange),
                  _buildTag(category, Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.orange.shade50,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectedLabelsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detected Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _detectedLabels
                    .map((label) => _buildTag(label, Colors.blue))
                    .toList(),
              ),
              SizedBox(height: 8),
              Text(
                'Note: These items were detected but not found in our safety database.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
