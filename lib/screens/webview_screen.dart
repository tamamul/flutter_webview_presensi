import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_constants.dart';
import '../services/notification_service.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _currentUrl = '';
  double _loadingProgress = 0;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
    NotificationService.init();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _currentUrl = url;
                _loadingProgress = 0;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress / 100);
            }
          },
          onPageFinished: (url) async {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
              });
              final canGoBack = await _controller.canGoBack();
              if (mounted) setState(() => _canGoBack = canGoBack);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (request) {
            // Blokir navigasi ke domain lain jika diperlukan
            // return NavigationDecision.prevent;
            return NavigationDecision.navigate;
          },
        ),
      )
      // Inject meta viewport & CSS agar mobile-friendly
      ..addJavaScriptChannel(
        'FlutterApp',
        onMessageReceived: (message) {
          _handleJsMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handleJsMessage(String message) {
    // Tangani pesan dari JavaScript jika diperlukan
    debugPrint('JS Message: $message');
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return _showExitDialog();
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Keluar Aplikasi?'),
            content: const Text(
                'Apakah Anda yakin ingin keluar dari aplikasi presensi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // WebView
            if (!_hasError) WebViewWidget(controller: _controller),

            // Loading Progress
            if (_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _loadingProgress > 0 ? _loadingProgress : null,
                  backgroundColor: Colors.green.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2E7D32),
                  ),
                  minHeight: 3,
                ),
              ),

            // Error State
            if (_hasError) _buildErrorWidget(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: _canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => _controller.goBack(),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/logo.png',
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                ),
              ),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Presensi MARSA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isLoading)
            Text(
              'Memuat...',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            )
          else
            Text(
              _formatUrl(_currentUrl),
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        // Tombol refresh
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Muat ulang',
          onPressed: () => _controller.reload(),
        ),
        // Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            switch (value) {
              case 'home':
                _controller.loadRequest(Uri.parse(AppConstants.loginUrl));
                break;
              case 'reload':
                _controller.reload();
                break;
              case 'clear':
                _controller.clearCache();
                _controller.reload();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'home',
              child: Row(
                children: [
                  Icon(Icons.home_rounded, color: Color(0xFF1B5E20)),
                  SizedBox(width: 10),
                  Text('Halaman Utama'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reload',
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, color: Color(0xFF1B5E20)),
                  SizedBox(width: 10),
                  Text('Muat Ulang'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.cleaning_services_rounded,
                      color: Color(0xFF1B5E20)),
                  SizedBox(width: 10),
                  Text('Bersihkan Cache'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 72,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              const Text(
                'Gagal Memuat Halaman',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Periksa koneksi internet Anda dan coba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _hasError = false);
                  _controller.reload();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUrl(String url) {
    if (url.isEmpty) return AppConstants.baseUrl;
    try {
      final uri = Uri.parse(url);
      return uri.host + (uri.path.length > 1 ? uri.path : '');
    } catch (_) {
      return url;
    }
  }
}
