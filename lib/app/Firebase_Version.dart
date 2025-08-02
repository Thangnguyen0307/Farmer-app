import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<bool> checkForceUpdate(BuildContext context) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 0),
    ),
  );
  await remoteConfig.fetchAndActivate();

  final forceUpdateVersion = remoteConfig.getString('force_update_version');
  print('Remote Config version: "$forceUpdateVersion"');
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;

  if (compareVersion(currentVersion, forceUpdateVersion) < 0) {
    // version cũ => bắt update
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Cập nhật ứng dụng'),
            content: const Text(
              'Phiên bản này đã cũ, vui lòng cập nhật để tiếp tục sử dụng.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Mở link Google Play/App Store của app bạn
                },
                child: const Text('Cập nhật ngay'),
              ),
            ],
          ),
    );
    return false;
  }
  return true;
}

// Hàm so sánh version: 1.2.3 < 1.3.0 => -1
int compareVersion(String v1, String v2) {
  final v1Parts = v1.split('.').map(int.parse).toList();
  final v2Parts = v2.split('.').map(int.parse).toList();

  final length = [
    v1Parts.length,
    v2Parts.length,
  ].reduce((a, b) => a > b ? a : b);
  while (v1Parts.length < length) {
    v1Parts.add(0);
  }
  while (v2Parts.length < length) {
    v2Parts.add(0);
  }

  for (int i = 0; i < length; i++) {
    if (v1Parts[i] != v2Parts[i]) return v1Parts[i].compareTo(v2Parts[i]);
  }
  return 0;
}
