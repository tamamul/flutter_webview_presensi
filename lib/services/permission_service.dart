import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Cek status semua izin sekarang
  Future<Map<String, bool>> checkAllPermissions() async {
    final location = await Permission.location.status;
    final camera = await Permission.camera.status;
    final notification = await Permission.notification.status;

    return {
      'location': location.isGranted,
      'camera': camera.isGranted,
      'notification': notification.isGranted,
    };
  }

  /// Cek apakah semua izin sudah diberikan
  Future<bool> areAllPermissionsGranted() async {
    final statuses = await checkAllPermissions();
    return statuses.values.every((granted) => granted);
  }

  /// Minta semua izin sekaligus
  Future<Map<String, bool>> requestAllPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.camera,
      Permission.notification,
    ].request();

    return {
      'location': statuses[Permission.location]?.isGranted ?? false,
      'camera': statuses[Permission.camera]?.isGranted ?? false,
      'notification': statuses[Permission.notification]?.isGranted ?? false,
    };
  }

  /// Minta izin lokasi
  Future<bool> requestLocation() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  /// Minta izin kamera
  Future<bool> requestCamera() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  /// Minta izin notifikasi
  Future<bool> requestNotification() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }
}
