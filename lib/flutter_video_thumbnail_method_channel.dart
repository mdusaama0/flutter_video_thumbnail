import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_video_thumbnail_platform_interface.dart';

/// An implementation of [FlutterVideoThumbnailPlatform] that uses method channels.
class MethodChannelFlutterVideoThumbnail extends FlutterVideoThumbnailPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_video_thumbnail');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // New method to extract frames from a video using the method channel
  @override
  Future<List<String>?> extractFrames(String videoPath) async {
    final List<dynamic>? result =
        await methodChannel.invokeMethod<List<dynamic>>(
      'extractFrames',
      {'videoPath': videoPath}, // Pass the video path to native code
    );
    return result
        ?.cast<String>(); // Ensure that the result is a list of strings
  }
}
