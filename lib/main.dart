import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

WebViewEnvironment? webViewEnvironment;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Official InAppWebView website")),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialSettings:
                      InAppWebViewSettings(javaScriptEnabled: true),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    webViewController!
                        .loadFile(assetFilePath: 'assets/script.html');
                  },
                  onConsoleMessage: (controller, consoleMessage) async {
                    final message = consoleMessage.message;
                    if (message.startsWith('PDF_BASE64:')) {
                      final base64Data =
                          message.replaceFirst('PDF_BASE64:', '');

                      final bytes = base64Decode(base64Data);
                      final directory = await getExternalStorageDirectory();
                      final filePath = '${directory!.path}/sample.pdf';
                      final file = File(filePath);
                      await file.writeAsBytes(bytes);

                      print('PDF saved at $filePath');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF saved at: $filePath')),
                      );
                    }
                  },
                ),
                FloatingActionButton(
                  onPressed: () async {
                    await webViewController!
                        .evaluateJavascript(source: 'generatePDF();');
                  },
                  child: const Icon(Icons.close),
                )
              ],
            ),
          ),
        ])));
  }
}
