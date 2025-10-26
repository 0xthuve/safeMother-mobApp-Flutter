// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:googleapis_auth/auth_io.dart' as g_auth;
// import 'utils/toast_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class FoodScanPage extends StatefulWidget {
//   @override
//   _FoodScanPageState createState() => _FoodScanPageState();
// }

// class _FoodScanPageState extends State<FoodScanPage> {
//   Map<String, dynamic>? _scanResult;
//   bool _loading = false;
//   String? _errorMessage;
//   g_auth.AutoRefreshingAuthClient? _client;
//   String? _visionInitError;
//   List<String> _detectedLabels = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _client?.close();
//     super.dispose();
//   }

//   Future<void> _initClient({bool showToast = false, String? credentialsJson}) async {
//     if (_client != null) return;
//     try {
//       // Determine credentials: explicit param > saved prefs > bundled asset
//       String creds = '';
//       if (credentialsJson != null && credentialsJson.trim().isNotEmpty) {
//         creds = credentialsJson;
//       } else {
//         final prefs = await SharedPreferences.getInstance();
//         final saved = prefs.getString('vision_service_account');
//         if (saved != null && saved.isNotEmpty) {
//           creds = saved;
//         } else {
//           creds = await rootBundle
//               .loadString('assets/still-cipher-468306-p2-aae0a6034688.json');
//         }
//       }

//       final serviceAccountCredentials =
//           g_auth.ServiceAccountCredentials.fromJson(creds);
//       _client = await g_auth.clientViaServiceAccount(
//         serviceAccountCredentials,
//         ['https://www.googleapis.com/auth/cloud-platform'],
//       );
//       setState(() {
//         _errorMessage = null;
//         _visionInitError = null;
//       });
//     } catch (e) {
//       // Keep the raw error in logs for debugging, but show a concise
//       // user-facing message. Common causes: invalid service account key,
//       // revoked credentials, project API not enabled, or device clock skew.
//       print('Error initializing Google Cloud client: $e');
//       _visionInitError = e.toString();

//       String friendly;
//       final errorText = _visionInitError!.toLowerCase();
//       if (errorText.contains('invalid_jwt') ||
//           errorText.contains('invalid jwt') ||
//           errorText.contains('invalid_grant') ||
//           errorText.contains('invalid jwt signature')) {
//         friendly =
//             'Authentication failed for Google Vision. This usually means the service account key is invalid or the device time is incorrect.';
//         // Provide a short actionable toast to the user only when requested
//         if (showToast) {
//           await ToastService.showInfo(
//               'Google Vision auth failed. Try manual entry or check service account configuration.');
//         }
//       } else {
//         friendly = 'Failed to initialize Google Cloud client.';
//         if (showToast) await ToastService.showInfo('Google Vision not available.');
//       }

//       setState(() {
//         _errorMessage = '$friendly';
//       });

//       // Optionally include a short hint in logs (do not expose full key)
//       print('Google Vision init hint: $friendly');
//     }
//   }

//   Future<void> _showConfigureDialog() async {
//     final TextEditingController ctrl = TextEditingController();
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Configure Google Vision'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Paste the service account JSON here. This will be stored locally on the device.',
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: ctrl,
//                 minLines: 6,
//                 maxLines: 14,
//                 decoration: InputDecoration(
//                   hintText: '{\"type\": \"service_account\", ...}',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );

//     if (result == true) {
//       final text = ctrl.text.trim();
//       if (text.isEmpty) {
//         await ToastService.showError('No credentials provided.');
//         return;
//       }
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('vision_service_account', text);
//         // Try init immediately and show toast on failure
//         await _initClient(showToast: true, credentialsJson: text);
//         if (_client != null) {
//           await ToastService.showInfo('Google Vision configured successfully.');
//           setState(() {});
//         }
//       } catch (e) {
//         print('Error saving Vision credentials: $e');
//         await ToastService.showError('Failed to configure Google Vision.');
//       }
//     }
//   }

//   Future<XFile?> pickImageFromCamera() async {
//     final ImagePicker picker = ImagePicker();
//     return await picker.pickImage(source: ImageSource.camera);
//   }

//   Future<List<String>> getFoodLabels(File imageFile) async {
//     if (_client == null) {
//       throw Exception('Google Cloud client not initialized.');
//     }

//     final bytes = await imageFile.readAsBytes();
//     final base64Image = base64Encode(bytes);
//     const url = 'https://vision.googleapis.com/v1/images:annotate';
//     final body = jsonEncode({
//       "requests": [
//         {
//           "image": {"content": base64Image},
//           "features": [
//             {"type": "LABEL_DETECTION", "maxResults": 10}
//           ]
//         }
//       ]
//     });

//     final response = await _client!.post(Uri.parse(url),
//         body: body, headers: {"Content-Type": "application/json"});

//     if (response.statusCode != 200) {
//       throw Exception('Failed to get labels: ${response.body}');
//     }

//     final data = jsonDecode(response.body);

//     if (data['responses'] == null ||
//         data['responses'].isEmpty ||
//         data['responses'][0]['labelAnnotations'] == null) {
//       return [];
//     }

//     final labels = data['responses'][0]['labelAnnotations'] as List;
//     return labels.map((l) => l['description'] as String).toList();
//   }

//   Future<Map<String, dynamic>> loadFoodSafetyData() async {
//     final jsonStr = await rootBundle.loadString('assets/food_safety.json');
//     return jsonDecode(jsonStr);
//   }

//   Map<String, dynamic>? findFoodInDatabase(
//       List<String> labels, Map<String, dynamic> foodData) {
//     // Search through all categories in the food database
//     final Map<String, dynamic> foods =
//         foodData['Food Safety Guide for Pregnancy']['foods'];

//     for (var label in labels) {
//       final lowerLabel = label.toLowerCase();

//       // Search in all categories
//       for (var category in foods.keys) {
//         final categoryFoods = foods[category] as Map<String, dynamic>?;
//         if (categoryFoods != null && categoryFoods.containsKey(lowerLabel)) {
//           return {
//             'name': label,
//             'category': category,
//             ...categoryFoods[lowerLabel]
//           };
//         }
//       }

//       // Try partial matching for common food names
//       for (var category in foods.keys) {
//         final categoryFoods = foods[category] as Map<String, dynamic>?;
//         if (categoryFoods != null) {
//           for (var foodKey in categoryFoods.keys) {
//             if (lowerLabel.contains(foodKey) || foodKey.contains(lowerLabel)) {
//               return {
//                 'name': label,
//                 'category': category,
//                 ...categoryFoods[foodKey]
//               };
//             }
//           }
//         }
//       }
//     }

//     return null;
//   }

//   Future<void> scanFood() async {
//     setState(() {
//       _loading = true;
//       _scanResult = null;
//       _errorMessage = null;
//       _detectedLabels = [];
//     });

//     try {
//       if (_client == null) {
//         // Only offer the option to try online — manual entry is not allowed.
//         final choice = await showDialog<String>(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               title: Text('Google Vision not configured'),
//               content: Text(
//                   'Google Vision is not available or not configured. Would you like to try online vision?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop('cancel'),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop('online'),
//                   child: Text('Try Online'),
//                 ),
//               ],
//             );
//           },
//         );

//         if (choice == null || choice == 'cancel') {
//           setState(() {
//             _loading = false;
//           });
//           return;
//         }

//         if (choice == 'online') {
//           // User explicitly asked to try online; show toast on failure.
//           await _initClient(showToast: true);
//           if (_client == null) {
//             // Still not available — inform the user and abort since manual
//             // entry is not supported per user preference.
//             setState(() {
//               _errorMessage =
//                   'Google Vision not available. Please enable Vision API or configure service account.';
//               _loading = false;
//             });
//             return;
//           }
//         }
//       }

//       // Proceed with exclusive scan flow: pick image and run Vision detection.
//       final image = await pickImageFromCamera();
//       if (image == null) {
//         setState(() {
//           _errorMessage = 'No image selected.';
//           _loading = false;
//         });
//         return;
//       }

//       // At this point we require the Vision client to be available
//       if (_client == null) {
//         setState(() {
//           _errorMessage =
//               'Google Vision not available. Please try online setup and retry.';
//           _loading = false;
//         });
//         return;
//       }

//       _detectedLabels = await getFoodLabels(File(image.path));
//       final foodData = await loadFoodSafetyData();
//       final result = findFoodInDatabase(_detectedLabels, foodData);

//       setState(() {
//         _scanResult = result;
//         if (result == null && _detectedLabels.isNotEmpty) {
//           _errorMessage =
//               'Food not found in database. Detected: ${_detectedLabels.join(", ")}';
//         } else if (result == null) {
//           _errorMessage =
//               'No food items detected. Please try again with a clearer image.';
//         }
//       });
//     } catch (e) {
//       print('Error during food scan: $e');
//       setState(() {
//         _errorMessage = 'Error during scan: $e';
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Food Safety Scanner'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Theme.of(context).colorScheme.primary.withOpacity(0.06), Colors.white],
//           ),
//         ),
//         child: Center(
//           child: _loading
//               ? _buildLoadingWidget()
//               : Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildScanButton(),
//                     SizedBox(height: 24),
//                     if (_scanResult != null) _buildResultCard(_scanResult!),
//                     if (_errorMessage != null) _buildErrorCard(_errorMessage!),
//                     if (_detectedLabels.isNotEmpty && _scanResult == null)
//                       _buildDetectedLabelsCard(),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingWidget() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CircularProgressIndicator(
//           valueColor:
//               AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
//           strokeWidth: 4,
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Scanning your food...',
//           style: TextStyle(
//             fontSize: 18,
//             color: Colors.grey.shade700,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 10),
//         Text(
//           'Please wait while we analyze the image',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScanButton() {
//     return Column(
//       children: [
//         Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primary,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: IconButton(
//             icon: Icon(Icons.camera_alt, size: 40, color: Colors.white),
//             onPressed: scanFood,
//           ),
//         ),
//         SizedBox(height: 16),
//         Text(
//           'Tap to Scan Food',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           'Take a picture of any food item',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 12),
//         if (_client == null)
//           TextButton.icon(
//             onPressed: _showConfigureDialog,
//             icon: Icon(Icons.settings),
//             label: Text('Configure Vision'),
//           ),
//       ],
//     );
//   }

//   Widget _buildResultCard(Map<String, dynamic> result) {
//     final bool isSafe = result['safe'] == true;
//     final String foodName = result['name'] ?? 'Unknown Food';
//     final String category =
//         result['category']?.toString().replaceAll('_', ' ') ?? 'General';

//     return Container(
//       margin: EdgeInsets.all(16),
//       child: Card(
//         elevation: 8,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with status
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: isSafe ? Colors.green : Colors.red,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           isSafe ? Icons.check_circle : Icons.warning,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                         SizedBox(width: 6),
//                         Text(
//                           isSafe ? 'SAFE TO EAT' : 'AVOID',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Spacer(),
//                   Icon(
//                     isSafe ? Icons.emoji_food_beverage : Icons.no_food,
//                     color: isSafe ? Colors.green : Colors.red,
//                     size: 24,
//                   ),
//                 ],
//               ),

//               SizedBox(height: 16),

//               // Food Name
//               Text(
//                 foodName.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade800,
//                 ),
//               ),

//               SizedBox(height: 4),

//               // Category
//               Text(
//                 'Category: $category',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade600,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),

//               SizedBox(height: 16),

//               // Safety Advice
//               _buildInfoSection(
//                 'Safety Advice',
//                 result['advice'] ?? 'No specific advice available.',
//                 Icons.health_and_safety,
//                 isSafe ? Colors.green : Colors.red,
//               ),

//               SizedBox(height: 12),

//               // Nutrition Information
//               // FIX: Check if 'nutrition' is a Map and access the 'details' field
//               if (result['nutrition'] != null && result['nutrition'] is Map)
//                 _buildInfoSection(
//                   'Nutrition',
//                   (result['nutrition']['details'] as String?) ??
//                       'No nutrition details available.',
//                   Icons.local_dining,
//                   Colors.orange,
//                 ),

//               SizedBox(height: 12),

//               // Calories
//               if (result['calories'] != null)
//                 _buildInfoSection(
//                   'Calories',
//                   result['calories'],
//                   Icons.local_fire_department,
//                   Colors.orange.shade700,
//                 ),

//               SizedBox(height: 12),

//               // Consumption Recommendation
//               if (result['consumption'] != null)
//                 _buildInfoSection(
//                   'Recommended Intake',
//                   result['consumption'],
//                   Icons.timeline,
//                   Theme.of(context).colorScheme.primary,
//                 ),

//               SizedBox(height: 16),

//               // Tags
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: [
//                   _buildTag(
//                       'Pregnancy Safe', isSafe ? Colors.green : Colors.red),
//                   // FIX: Check if 'nutrition' is a Map and access the 'level' field
//                   if (result['nutrition'] != null &&
//                       result['nutrition'] is Map &&
//                       result['nutrition']['level'] != null)
//                     _buildTag('Nutrition: ${result['nutrition']['level']}',
//                         Colors.orange),
//                   _buildTag(category, Theme.of(context).colorScheme.secondary),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoSection(
//       String title, String content, IconData icon, Color color) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 18, color: color),
//             SizedBox(width: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: color,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 6),
//         Text(
//           content,
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade700,
//             height: 1.4,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTag(String text, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color,
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorCard(String message) {
//     return Container(
//       margin: EdgeInsets.all(16),
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         color: Colors.orange.shade50,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Icon(Icons.error_outline, color: Colors.orange, size: 24),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   message,
//                   style: TextStyle(
//                     color: Colors.orange.shade800,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetectedLabelsCard() {
//     return Container(
//       margin: EdgeInsets.all(16),
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Detected Items',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//         children: _detectedLabels
//           .map((label) =>
//             _buildTag(label, Theme.of(context).colorScheme.primary))
//                     .toList(),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Note: These items were detected but not found in our safety database.',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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