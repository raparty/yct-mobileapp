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

  // Use Google Docs viewer to render any PDF URL — works with R2, Drive, anything
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
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
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
                const Text('Using Google Docs viewer', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ]))),
      ]),
      bottomNavigationBar: Container(
        color: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Icon(Icons.info_outline, color: Colors.white38, size: 14),
          const SizedBox(width: 6),
          const Expanded(child: Text('Powered by Cloudflare R2',
            style: TextStyle(color: Colors.white38, fontSize: 11))),
          TextButton(
            onPressed: () { setState(() => _loading = true); _ctrl.reload(); },
            child: const Text('Reload', style: TextStyle(color: AppColors.teal, fontSize: 12))),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(widget.pdfUrl),
                mode: LaunchMode.externalApplication),
            child: const Text('Browser', style: TextStyle(color: AppColors.teal, fontSize: 12))),
        ]),
      ),
    );
  }
}
