import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../utils/app_constants.dart';
import 'webview_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  final PermissionService _permService = PermissionService();

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  bool _isLoading = false;

  // Status masing-masing izin
  bool _locationGranted = false;
  bool _cameraGranted = false;
  bool _notifGranted = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final statuses = await _permService.checkAllPermissions();
    if (mounted) {
      setState(() {
        _locationGranted = statuses['location'] ?? false;
        _cameraGranted = statuses['camera'] ?? false;
        _notifGranted = statuses['notification'] ?? false;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isLoading = true);

    final results = await _permService.requestAllPermissions();

    if (mounted) {
      setState(() {
        _locationGranted = results['location'] ?? false;
        _cameraGranted = results['camera'] ?? false;
        _notifGranted = results['notification'] ?? false;
        _isLoading = false;
      });

      // Jika semua izin diberikan, lanjut ke WebView
      if (_locationGranted && _cameraGranted && _notifGranted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _goToWebView();
      }
    }
  }

  Future<void> _requestSinglePermission(String type) async {
    setState(() => _isLoading = true);
    bool result = false;

    switch (type) {
      case 'location':
        result = await _permService.requestLocation();
        break;
      case 'camera':
        result = await _permService.requestCamera();
        break;
      case 'notification':
        result = await _permService.requestNotification();
        break;
    }

    if (mounted) {
      setState(() {
        if (type == 'location') _locationGranted = result;
        if (type == 'camera') _cameraGranted = result;
        if (type == 'notification') _notifGranted = result;
        _isLoading = false;
      });
    }
  }

  void _goToWebView() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const WebViewScreen(url: AppConstants.loginUrl),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  bool get _allGranted =>
      _locationGranted && _cameraGranted && _notifGranted;

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Izin Diperlukan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aplikasi memerlukan beberapa izin\nuntuk fitur presensi berjalan optimal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Daftar izin
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 8),
                    _buildPermissionCard(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF1565C0),
                      bgColor: const Color(0xFFE3F2FD),
                      title: 'Lokasi',
                      description:
                          'Untuk merekam lokasi saat absen dan memverifikasi kehadiran di area sekolah.',
                      isGranted: _locationGranted,
                      onRequest: () => _requestSinglePermission('location'),
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionCard(
                      icon: Icons.camera_alt_rounded,
                      iconColor: const Color(0xFF7B1FA2),
                      bgColor: const Color(0xFFF3E5F5),
                      title: 'Kamera',
                      description:
                          'Untuk scan QR code presensi dan mengambil foto saat absen masuk.',
                      isGranted: _cameraGranted,
                      onRequest: () => _requestSinglePermission('camera'),
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionCard(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFE65100),
                      bgColor: const Color(0xFFFFF3E0),
                      title: 'Notifikasi',
                      description:
                          'Untuk menerima pengingat jadwal presensi dan informasi penting dari sekolah.',
                      isGranted: _notifGranted,
                      onRequest: () => _requestSinglePermission('notification'),
                    ),

                    const SizedBox(height: 28),

                    // Info catatan
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Colors.amber.shade700, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Izin hanya digunakan untuk keperluan presensi dan tidak disimpan di luar server sekolah.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Tombol bawah
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    // Tombol utama
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_allGranted ? _goToWebView : _requestAllPermissions),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _allGranted
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _allGranted
                                        ? Icons.check_circle_rounded
                                        : Icons.security_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _allGranted
                                        ? 'Buka Presensi'
                                        : 'Izinkan Semua',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Skip (lewati)
                    if (!_allGranted) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _isLoading ? null : _goToWebView,
                        child: Text(
                          'Lewati, lanjutkan tanpa izin',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? const Color(0xFF4CAF50).withOpacity(0.5)
              : Colors.grey.shade200,
          width: isGranted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),

            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Status / Tombol
            if (isGranted)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              GestureDetector(
                onTap: _isLoading ? null : onRequest,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Izinkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
