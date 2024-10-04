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
    
    // Set tolerance to zero to retrieve the exact frame, not just the keyframes
    imageGenerator.requestedTimeToleranceAfter = .zero
    imageGenerator.requestedTimeToleranceBefore = .zero
    
    // Define the times to extract frames (one frame every second)
    let times = stride(from: 0.0, to: CMTimeGetSeconds(asset.duration), by: 1.0).map {
        CMTime(seconds: $0, preferredTimescale: 600)
    }
    
    var filePaths = [String]()
    let dispatchGroup = DispatchGroup()

    // Generate images asynchronously
    for time in times {
        dispatchGroup.enter()
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, result, error in
            if let image = image, result == .succeeded {
                let uiImage = UIImage(cgImage: image)
                if let imageData = uiImage.jpegData(compressionQuality: 0.7) {  // Save as JPEG with 70% quality
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
            }
            dispatchGroup.leave()
        }
    }

    // Notify when all images are generated
    dispatchGroup.notify(queue: .main) {
        completion(filePaths)
    }
}

}
