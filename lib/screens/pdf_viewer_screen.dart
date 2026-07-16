import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;
  const PdfViewerScreen({super.key, required this.title, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  // Use Google Docs viewer — renders any public PDF URL including R2
  // Append timestamp to avoid cache issues
  String get _viewerUrl =>
    'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.pdfUrl)}&embedded=true';

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (e) {
          if (e.isForMainFrame == true) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(_viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(widget.title,
          style: const TextStyle(fontSize: 15, color: Colors.white),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primaryDark,
        actions: [
          // Reload button for when Google Docs viewer times out
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _loading = true);
              _ctrl.loadRequest(Uri.parse(_viewerUrl));
            }),
          // Open in browser as fallback
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white70),
            onPressed: () => launchUrl(Uri.parse(widget.pdfUrl),
              mode: LaunchMode.externalApplication)),
        ],
      ),
      body: Stack(children: [
        WebViewWidget(controller: _ctrl),
        if (_loading)
          Container(
            color: Colors.grey.shade900,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryMid),
                const SizedBox(height: 20),
                const Text('Loading PDF...', style: TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 6),
                const Text('This may take 10–20 seconds on first load',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 24),
                // Tap to reload if it takes too long
                TextButton(
                  onPressed: () {
                    setState(() => _loading = true);
                    _ctrl.loadRequest(Uri.parse(_viewerUrl));
                  },
                  child: const Text('Tap to retry',
                    style: TextStyle(color: AppColors.teal, fontSize: 13))),
              ]))),
      ]),
    );
  }
}
