import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FullScreen extends StatelessWidget {
  final String imgUrl;

  FullScreen({super.key, required this.imgUrl});

  /// Download the image and save it to the device's temporary directory
  Future<String> _downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/downloaded_wallpaper.jpg';
      final file = File(imagePath);
      await file.writeAsBytes(response.bodyBytes);
      return imagePath;
    } else {
      throw Exception('Failed to download image');
    }
  }

  /// Set wallpaper using platform channels
  Future<void> _setWallpaper(String imagePath, int screenType) async {
    const platform = MethodChannel('com.example.wallpaper/wallpaper');
    try {
      final Uint8List bytes = await File(imagePath).readAsBytes();
      await platform.invokeMethod('setWallpaper', {
        'bytes': bytes,
        'screenType': screenType, // 0: Home, 1: Lock, 2: Both
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to set wallpaper: $e");
    }
  }

  /// Show dialog for choosing wallpaper type
  void _showWallpaperDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Wallpaper"),
          content: const Text("Choose where to set the wallpaper:"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _setWallpaper(imagePath, 0); // Home screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Wallpaper set on Home Screen")),
                );
                Navigator.pop(context);
              },
              child: const Text("Home Screen"),
            ),
            TextButton(
              onPressed: () async {
                await _setWallpaper(imagePath, 1); // Lock screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Wallpaper set on Lock Screen")),
                );
                Navigator.pop(context);
              },
              child: const Text("Lock Screen"),
            ),
            TextButton(
              onPressed: () async {
                await _setWallpaper(imagePath, 2); // Both screens
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Wallpaper set on Both Screens")),
                );
                Navigator.pop(context);
              },
              child: const Text("Both Screens"),
            ),
          ],
        );
      },
    );
  }

  /// Download the image and set the wallpaper
  Future<void> downloadAndSetWallpaper(
      String wallpaperUrl, BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading Started...")),
    );

    try {
      final imagePath = await _downloadImage(wallpaperUrl);
      _showWallpaperDialog(context, imagePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await downloadAndSetWallpaper(imgUrl, context);
        },
        label: const Text("Set Wallpaper"),
        icon: const Icon(Icons.download),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              imgUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error, color: Colors.red, size: 50),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
