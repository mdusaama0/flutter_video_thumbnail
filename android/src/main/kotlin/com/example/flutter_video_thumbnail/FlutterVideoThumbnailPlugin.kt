package com.example.flutter_video_thumbnail

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.util.*

/** FlutterVideoThumbnailPlugin */
class FlutterVideoThumbnailPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_video_thumbnail")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "extractFrames") {
            val videoPath = call.argument<String>("videoPath")
            if (videoPath != null) {
                // Run the frame extraction on a background thread to avoid blocking the UI
                Thread {
                    val filePaths = extractFrames(videoPath)
                    result.success(filePaths)
                }.start()
            } else {
                result.error("INVALID_ARGUMENT", "Video path is missing", null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun extractFrames(videoPath: String): List<String> {
        val retriever = MediaMetadataRetriever()
        retriever.setDataSource(videoPath)

        // Get video duration in milliseconds
        val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0
        val filePaths = mutableListOf<String>()

        // Extract frames every second (1 second = 1,000,000 microseconds)
        val frameInterval = 1_000_000L
        for (time in 0..duration * 1000 step frameInterval) {
            val bitmap = retriever.getFrameAtTime(time, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
            if (bitmap != null) {
                val filePath = saveBitmap(bitmap)
                filePaths.add(filePath)
            }
        }

        retriever.release()
        return filePaths
    }

    private fun saveBitmap(bitmap: Bitmap): String {
        val fileName = UUID.randomUUID().toString() + ".jpg"
        val tempDir = File(cacheDir, "thumbnails")
        if (!tempDir.exists()) {
            tempDir.mkdirs()
        }
        val file = File(tempDir, fileName)

        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 70, out)
        }

        return file.absolutePath
    }

    // Helper to get the cache directory (You may need to adjust this if the context is required)
    private val cacheDir: File
        get() = File(System.getProperty("java.io.tmpdir"))
}
