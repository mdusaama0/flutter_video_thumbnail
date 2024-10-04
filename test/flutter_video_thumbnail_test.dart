import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_video_thumbnail/flutter_video_thumbnail.dart';
import 'package:flutter_video_thumbnail/flutter_video_thumbnail_platform_interface.dart';
import 'package:flutter_video_thumbnail/flutter_video_thumbnail_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterVideoThumbnailPlatform
    with MockPlatformInterfaceMixin
    implements FlutterVideoThumbnailPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  // Implement the missing extractFrames method
  @override
  Future<List<String>?> extractFrames(String videoPath) =>
      Future.value(['path/to/frame1.png', 'path/to/frame2.png']);
}

void main() {
  final FlutterVideoThumbnailPlatform initialPlatform =
      FlutterVideoThumbnailPlatform.instance;

  test('$MethodChannelFlutterVideoThumbnail is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterVideoThumbnail>());
  });

  test('getPlatformVersion', () async {
    FlutterVideoThumbnail flutterVideoThumbnailPlugin = FlutterVideoThumbnail();
    MockFlutterVideoThumbnailPlatform fakePlatform =
        MockFlutterVideoThumbnailPlatform();
    FlutterVideoThumbnailPlatform.instance = fakePlatform;

    expect(await flutterVideoThumbnailPlugin.getPlatformVersion(), '42');
  });

  // Add a test for extractFrames
  test('extractFrames', () async {
    FlutterVideoThumbnail flutterVideoThumbnailPlugin = FlutterVideoThumbnail();
    MockFlutterVideoThumbnailPlatform fakePlatform =
        MockFlutterVideoThumbnailPlatform();
    FlutterVideoThumbnailPlatform.instance = fakePlatform;

    final frames =
        await flutterVideoThumbnailPlugin.extractFrames('video/path.mp4');
    expect(frames, ['path/to/frame1.png', 'path/to/frame2.png']);
  });
}
