// ─────────────────────────────────────────
// YCT — PDF Viewer (R2)
// • Reload button
// • Open in browser fallback
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;
  final String? pdfId;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.pdfId,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  String get _viewerUrl =>
    'https://docs.google.com/viewer'
    '?url=${Uri.encodeComponent(widget.pdfUrl)}'
    '&embedded=true';

  @override
  void initState() {
    super.initState();

    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 '
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

  void _reload() {
    setState(() => _loading = true);
    _ctrl.loadRequest(Uri.parse(_viewerUrl));
  }

  void _openBrowser() =>
    launchUrl(Uri.parse(widget.pdfUrl), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(widget.title,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reload',
            onPressed: _reload),
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white70),
            tooltip: 'Open in browser',
            onPressed: _openBrowser),
        ],
      ),
      body: Stack(children: [
        WebViewWidget(controller: _ctrl),
        if (_loading)
          Container(
            color: Colors.grey.shade900,
            child: const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryMid),
                SizedBox(height: 20),
                Text('Loading PDF...',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
                SizedBox(height: 6),
                Text('This may take 10–20 seconds on first load',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
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
          TextButton(onPressed: _reload,
            child: const Text('Reload',
              style: TextStyle(color: AppColors.teal, fontSize: 12))),
          TextButton(onPressed: _openBrowser,
            child: const Text('Browser',
              style: TextStyle(color: AppColors.teal, fontSize: 12))),
        ]),
      ),
    );
  }
}