import 'flutter_video_thumbnail_platform_interface.dart';

class FlutterVideoThumbnail {
  // Method to get platform version (existing method)
  Future<String?> getPlatformVersion() {
    return FlutterVideoThumbnailPlatform.instance.getPlatformVersion();
  }

  // New method to extract frames from a video
  Future<List<String>?> extractFrames(String videoPath) {
    return FlutterVideoThumbnailPlatform.instance.extractFrames(videoPath);
  }
}
