// PDF Viewer using Google Drive's built-in preview
// More reliable than downloading raw PDF bytes
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl; // Raw Drive share URL
  final String? directUrl; // Direct download URL

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.directUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _error = false;

  // Extract Google Drive file ID
  String? get _driveFileId {
    final url = widget.pdfUrl;
    var m = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (m != null) return m.group(1);
    m = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
    if (m != null) return m.group(1);
    return null;
  }

  // Google Drive embed/preview URL — renders PDF natively without downloading
  String get _previewUrl {
    final id = _driveFileId;
    if (id != null) {
      return 'https://drive.google.com/file/d/$id/preview';
    }
    // Fallback: Google Docs viewer
    return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.pdfUrl)}&embedded=true';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() { _loading = true; _error = false; }),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (_) => setState(() { _loading = false; _error = true; }),
      ))
      ..loadRequest(Uri.parse(_previewUrl));
  }

  Future<void> _openExternal() async {
    final id = _driveFileId;
    final url = id != null
        ? 'https://drive.google.com/file/d/$id/view'
        : widget.pdfUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title,
          style: const TextStyle(fontSize: 15, color: Colors.white),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            tooltip: 'Open in browser',
            onPressed: _openExternal,
          ),
        ],
      ),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryMid),
              SizedBox(height: 16),
              Text('Loading PDF...', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              Text('Fetching from Google Drive',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
            ])),
        if (_error)
          Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text('Could not load PDF.',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                'Make sure the Google Drive file is shared publicly.\n'
                'Go to Drive → right-click file → Share → Anyone with link → Viewer',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _loading = true; _error = false; });
                    _controller.reload();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _openExternal,
                  icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.teal),
                  label: const Text('Open in browser',
                    style: TextStyle(color: AppColors.teal)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.teal)),
                ),
              ]),
            ]),
          )),
      ]),
    );
  }
}
