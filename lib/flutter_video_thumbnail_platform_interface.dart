import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_video_thumbnail_method_channel.dart';

abstract class FlutterVideoThumbnailPlatform extends PlatformInterface {
  FlutterVideoThumbnailPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterVideoThumbnailPlatform _instance =
      MethodChannelFlutterVideoThumbnail();

  static FlutterVideoThumbnailPlatform get instance => _instance;

  static set instance(FlutterVideoThumbnailPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Platform version method (existing)
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  // New extract frames method
  Future<List<String>?> extractFrames(String videoPath) {
    throw UnimplementedError('extractFrames() has not been implemented.');
  }
}
