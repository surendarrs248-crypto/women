import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsFallbackService {
  bool get supportsDirectSms =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      final locationStatus = await Permission.locationWhenInUse.request();
      if (defaultTargetPlatform != TargetPlatform.android) {
        return locationStatus.isGranted;
      }
      final smsStatus = await Permission.sms.request();
      return locationStatus.isGranted && smsStatus.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<Position?> currentPosition({Position? cachedPosition}) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
    } catch (_) {
      return cachedPosition;
    }
  }

  String buildSosMessage({
    required String userName,
    required DateTime timestamp,
    Position? position,
  }) {
    final location = position == null
        ? 'Location unavailable.'
        : 'Location: https://maps.google.com/?q=${position.latitude},${position.longitude}.';
    return 'SOS from $userName. $location Time: ${timestamp.toIso8601String()}. '
      'This is an automated emergency alert from SAKHI - please call immediately.';
  }

  /// Android sends directly. iOS opens a pre-filled compose sheet and the
  /// recipient must tap Send; the platform does not expose silent SMS sending.
  Future<List<String>> sendEmergencySms({
    required List<String> guardianNumbers,
    required String message,
  }) async {
    if (guardianNumbers.isEmpty) return const [];

    if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
      final first = guardianNumbers.first;
      try {
        final uri = Uri(
          scheme: 'sms',
          path: first,
          queryParameters: {'body': message},
        );
        if (await launchUrl(uri)) return guardianNumbers.skip(1).toList();
      } catch (_) {}
      return guardianNumbers;
    }

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return guardianNumbers;
    }

    final failed = <String>[];
    for (final number in guardianNumbers) {
      try {
        await Telephony.instance.sendSms(to: number, message: message);
      } catch (_) {
        failed.add(number);
      }
    }
    return failed;
  }
}