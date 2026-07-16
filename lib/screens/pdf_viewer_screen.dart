// PDF Viewer — uses Google Drive's embedded preview iframe
// The key is adding &rm=minimal to suppress login prompts
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
  late final WebViewController _controller;
  bool _loading = true;
  int _loadAttempt = 0;

  // Extract Google Drive file ID from any URL format
  String? get _driveId {
    final url = widget.pdfUrl;
    var m = RegExp(r'/file/d/([a-zA-Z0-9_-]{10,})').firstMatch(url);
    if (m != null) return m.group(1);
    m = RegExp(r'[?&]id=([a-zA-Z0-9_-]{10,})').firstMatch(url);
    if (m != null) return m.group(1);
    return null;
  }

  // Use Google Drive's built-in PDF preview — no auth needed for public files
  String get _embedUrl {
    final id = _driveId;
    if (id == null) return widget.pdfUrl;
    // The preview URL with rm=minimal removes the Google Drive UI chrome
    return 'https://drive.google.com/file/d/$id/preview?rm=minimal';
  }

  String get _viewUrl {
    final id = _driveId;
    if (id != null) return 'https://drive.google.com/file/d/$id/view';
    return widget.pdfUrl;
  }

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (e) {
          // Ignore minor resource errors, only flag fatal ones
          if (e.isForMainFrame == true) {
            setState(() => _loading = false);
          }
        },
        onNavigationRequest: (req) {
          // Allow Google domains, block everything else to prevent redirects
          final host = Uri.tryParse(req.url)?.host ?? '';
          if (host.contains('google.com') || host.contains('gstatic.com') || host.contains('googleapis.com')) {
            return NavigationDecision.navigate;
          }
          // Open external links in browser
          launchUrl(Uri.parse(req.url), mode: LaunchMode.externalApplication);
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(_embedUrl));
  }

  void _retry() {
    setState(() { _loading = true; _loadAttempt++; });
    _controller.loadRequest(Uri.parse(_embedUrl));
  }

  void _openBrowser() {
    launchUrl(Uri.parse(_viewUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(widget.title,
          style: const TextStyle(fontSize: 15, color: Colors.white),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            tooltip: 'Open in browser',
            onPressed: _openBrowser,
          ),
        ],
      ),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          Container(
            color: Colors.grey[900],
            child: const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryMid),
                SizedBox(height: 16),
                Text('Loading PDF...', style: TextStyle(color: Colors.white70, fontSize: 15)),
                SizedBox(height: 6),
                Text('First load may take 10-15 seconds',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            )),
          ),
      ]),
      bottomNavigationBar: Container(
        color: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Icon(Icons.info_outline, color: Colors.white38, size: 14),
          const SizedBox(width: 6),
          const Expanded(
            child: Text('File must be publicly shared in Google Drive',
              style: TextStyle(color: Colors.white38, fontSize: 11))),
          TextButton(
            onPressed: _retry,
            child: const Text('Reload', style: TextStyle(color: AppColors.teal, fontSize: 12))),
          TextButton(
            onPressed: _openBrowser,
            child: const Text('Browser', style: TextStyle(color: AppColors.teal, fontSize: 12))),
        ]),
      ),
    );
  }
}
