import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set WebView platform only if on Android
  if (Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  runApp(const Temp());
}

class Temp extends StatelessWidget {
  const Temp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3D Baby Viewer',
      home: Scaffold(
        appBar: AppBar(title: const Text('3D Baby Viewer')),
        body: const Baby3DView(),
      ),
    );
  }
}

class Baby3DView extends StatefulWidget {
  const Baby3DView({super.key});

  @override
  State<Baby3DView> createState() => _Baby3DViewState();
}

class _Baby3DViewState extends State<Baby3DView> {
  WebViewController? _sketchfabController;

  bool get _webViewSupported {
    return defaultTargetPlatform == TargetPlatform.android ||   
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();

    // Only initialize if platform supports WebView
    if (_webViewSupported) {
      _sketchfabController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(
          'https://sketchfab.com/models/1eb7a58308d348e9883d4345e35df00c/embed',
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '3D Baby Model',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        // Local GLB 3D model
        Expanded(
          child: ModelViewer(
            src: 'assets/models/Astronaut.glb',
            alt: 'A 3D model of a baby',
            autoRotate: true,
            cameraControls: true,
            backgroundColor: Colors.transparent,
            ar: false,
          ),
        ),

        const Divider(height: 1),

        // Conditionally show WebView only on supported platforms
        Expanded(
          child: _webViewSupported && _sketchfabController != null
              ? WebViewWidget(controller: _sketchfabController!)
              : const Center(
                  child: Text(
                    'WebView not supported on this platform.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ),

        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Pinch to zoom • Drag to rotate',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
