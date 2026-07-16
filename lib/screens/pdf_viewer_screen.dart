import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl; // Google Drive file share URL

  const PdfViewerScreen({super.key, required this.title, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  // Extract file ID from any Drive URL format
  String? get _id {
    final u = widget.pdfUrl;
    // https://drive.google.com/file/d/FILE_ID/view
    var m = RegExp(r'/file/d/([a-zA-Z0-9_-]{10,})').firstMatch(u);
    if (m != null) return m.group(1);
    // https://drive.google.com/open?id=FILE_ID
    m = RegExp(r'[?&]id=([a-zA-Z0-9_-]{10,})').firstMatch(u);
    if (m != null) return m.group(1);
    return null;
  }

  bool get _isFolder => widget.pdfUrl.contains('/folders/');
  bool get _hasPdf => _id != null && !_isFolder;

  // Google Drive PDF preview — renders natively, no download needed
  String get _previewUrl => 'https://drive.google.com/file/d/$_id/preview?rm=minimal';

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 11; Mobile) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (e) { if (e.isForMainFrame == true) setState(() => _loading = false); },
        onNavigationRequest: (req) {
          final host = Uri.tryParse(req.url)?.host ?? '';
          if (host.contains('google.com') || host.contains('gstatic.com')) {
            return NavigationDecision.navigate;
          }
          launchUrl(Uri.parse(req.url), mode: LaunchMode.externalApplication);
          return NavigationDecision.prevent;
        },
      ));

    if (_hasPdf) {
      _ctrl.loadRequest(Uri.parse(_previewUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show helpful error if URL is a folder or invalid
    if (!_hasPdf) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: Text(widget.title), backgroundColor: AppColors.primaryDark),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.link_off, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 20),
            const Text('PDF link needs updating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('How to fix:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  '1. Go to Google Drive\n'
                  '2. Right-click the PDF file (not a folder)\n'
                  '3. Click "Share"\n'
                  '4. Set to "Anyone with link → Viewer"\n'
                  '5. Click "Copy link"\n'
                  '6. Paste in the pdf_url column in your Google Sheet\n\n'
                  'The link should look like:\n',
                  style: TextStyle(fontSize: 12, height: 1.6)),
                SelectableText(
                  'https://drive.google.com/file/d/FILE_ID/view',
                  style: TextStyle(fontSize: 11, color: AppColors.primary,
                      fontFamily: 'monospace', fontWeight: FontWeight.w600)),
              ])),
            const SizedBox(height: 20),
            const Text('Current URL in your Sheet:',
              style: TextStyle(color: AppColors.textMid, fontSize: 12)),
            const SizedBox(height: 6),
            SelectableText(widget.pdfUrl,
              style: const TextStyle(fontSize: 10, color: Colors.red, height: 1.4)),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(widget.title,
          style: const TextStyle(fontSize: 15, color: Colors.white),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            tooltip: 'Open in browser',
            onPressed: () => launchUrl(
              Uri.parse('https://drive.google.com/file/d/$_id/view'),
              mode: LaunchMode.externalApplication)),
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
                SizedBox(height: 16),
                Text('Loading PDF...', style: TextStyle(color: Colors.white70, fontSize: 15)),
                SizedBox(height: 6),
                Text('Using Google Drive preview', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ]))),
      ]),
      bottomNavigationBar: Container(
        color: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Icon(Icons.info_outline, color: Colors.white38, size: 14),
          const SizedBox(width: 6),
          const Expanded(
            child: Text('PDF must be publicly shared in Drive',
              style: TextStyle(color: Colors.white38, fontSize: 11))),
          TextButton(
            onPressed: () { setState(() => _loading = true); _ctrl.reload(); },
            child: const Text('Reload', style: TextStyle(color: AppColors.teal, fontSize: 12))),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse('https://drive.google.com/file/d/$_id/view'),
              mode: LaunchMode.externalApplication),
            child: const Text('Browser', style: TextStyle(color: AppColors.teal, fontSize: 12))),
        ]),
      ),
    );
  }
}
