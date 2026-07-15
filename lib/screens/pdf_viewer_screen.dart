// In-app PDF viewer — downloads PDF to temp, renders inline
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;
  const PdfViewerScreen({super.key, required this.title, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _loading = true;
  String? _error;
  int _pages = 0;
  int _currentPage = 0;
  PDFViewController? _controller;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  // Convert Google Drive share link to direct download
  String get _downloadUrl {
    final url = widget.pdfUrl;
    if (url.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'/d/([^/]+)').firstMatch(url);
      if (match != null) {
        return 'https://drive.google.com/uc?export=download&id=${match.group(1)}&confirm=t';
      }
    }
    return url;
  }

  Future<void> _downloadPdf() async {
    try {
      final dir = await getTemporaryDirectory();
      // Use title as filename so same PDF isn't re-downloaded
      final safe = widget.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final file = File('${dir.path}/$safe.pdf');

      if (!file.existsSync()) {
        final dio = Dio();
        await dio.download(
          _downloadUrl,
          file.path,
          onReceiveProgress: (received, total) {
            if (total > 0 && mounted) {
              setState(() {}); // trigger rebuild for progress
            }
          },
        );
      }

      if (mounted) setState(() { _localPath = file.path; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load PDF. Please check your connection.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 15)),
        backgroundColor: AppColors.primaryDark,
        actions: [
          if (_pages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('${_currentPage + 1} / $_pages',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
        ],
      ),
      body: _loading
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryMid),
                const SizedBox(height: 16),
                const Text('Loading PDF...', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                const Text('This may take a moment on first load',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ))
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () { setState(() { _loading = true; _error = null; }); _downloadPdf(); },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ))
              : PDFView(
                  filePath: _localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: 0,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  onRender: (pages) => setState(() => _pages = pages ?? 0),
                  onPageChanged: (page, total) => setState(() => _currentPage = page ?? 0),
                  onError: (error) => setState(() => _error = error.toString()),
                  onPageError: (page, error) {},
                ),
      // Page navigation buttons
      bottomNavigationBar: (_localPath != null && _pages > 1)
          ? Container(
              color: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _currentPage > 0
                        ? () => _controller?.setPage(_currentPage - 1)
                        : null,
                  ),
                  Text('Page ${_currentPage + 1} of $_pages',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _currentPage < _pages - 1
                        ? () => _controller?.setPage(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
