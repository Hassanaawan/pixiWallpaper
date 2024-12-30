package com.example.pixi_wallpaper

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wallpaper/wallpaper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "setWallpaper") {
                    val bytes = call.argument<ByteArray>("bytes")
                    val screenType = call.argument<Int>("screenType") ?: 0
                    if (bytes != null) {
                        val inputStream = ByteArrayInputStream(bytes)
                        val bitmap = BitmapFactory.decodeStream(inputStream)
                        val wallpaperManager = WallpaperManager.getInstance(applicationContext)
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                when (screenType) {
                                    0 -> wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                                    1 -> wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                                    2 -> wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
                                }
                            } else {
                                wallpaperManager.setBitmap(bitmap)
                            }
                            result.success("Wallpaper set successfully")
                        } catch (e: Exception) {
                            result.error("ERROR", "Failed to set wallpaper", e.localizedMessage)
                        }
                    } else {
                        result.error("ERROR", "No image data", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}