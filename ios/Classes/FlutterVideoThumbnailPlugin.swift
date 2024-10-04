import Flutter
import UIKit
import AVFoundation

public class FlutterVideoThumbnailPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_video_thumbnail", binaryMessenger: registrar.messenger())
        let instance = FlutterVideoThumbnailPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "extractFrames":
            guard let args = call.arguments as? [String: Any],
                  let videoPath = args["videoPath"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Video path is missing", details: nil))
                return
            }
            extractFrames(from: videoPath, completion: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func extractFrames(from videoPath: String, completion: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: videoPath)
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        // Allow tolerance for non-keyframes extraction
        imageGenerator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: 600)
        imageGenerator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: 600)

        // Extract frames at regular intervals
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let frameTimes = stride(from: 0.0, to: durationSeconds, by: 1.0).map {
            CMTime(seconds: $0, preferredTimescale: 600)
        }

        var filePaths = [String]()
        let dispatchGroup = DispatchGroup()

        // Generate frames asynchronously with fallback on non-keyframes
        for time in frameTimes {
            dispatchGroup.enter()
            imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, actualTime, result, error in
                if let cgImage = cgImage, result == .succeeded {
                    let uiImage = UIImage(cgImage: cgImage)
                    if let imageData = uiImage.jpegData(compressionQuality: 0.7) {
                        let fileName = UUID().uuidString + ".jpg"
                        let tempDirectory = NSTemporaryDirectory()
                        let fileURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(fileName)
                        do {
                            try imageData.write(to: fileURL)
                            filePaths.append(fileURL.path)
                        } catch {
                            print("Error saving image: \(error.localizedDescription)")
                        }
                    }
                } else {
                    print("Error generating image at \(CMTimeGetSeconds(actualTime)): \(error?.localizedDescription ?? "Unknown error")")
                }
                dispatchGroup.leave()
            }
        }

        // Notify when all frames are processed
        dispatchGroup.notify(queue: .main) {
            completion(filePaths)
        }
    }

}
