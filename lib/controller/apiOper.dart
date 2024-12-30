import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:pixi_wallpaper/model/categoryModel.dart';
import 'package:pixi_wallpaper/model/photosModel.dart';

class ApiOperations {
  static List<PhotosModel> trendingWallpapers = [];
  static List<PhotosModel> searchWallpapersList = [];
  static List<CategoryModel> cateogryModelList = [];

  static String _apiKey = "RCD3f5EKWrTwYrUmGEIN4KWnqtg2Rasp8LASW1PEzy8IMCVOifrapWCD";

  static Future<List<PhotosModel>> getTrendingWallpapers() async {
    try {
      trendingWallpapers.clear();
      final response = await http.get(
        Uri.parse("https://api.pexels.com/v1/curated"),
        headers: {"Authorization": _apiKey},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        List photos = jsonData['photos'];
        for (var element in photos) {
          trendingWallpapers.add(PhotosModel.fromAPI2App(element));
        }
      } else {
        print("Failed to fetch trending wallpapers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred while fetching trending wallpapers: $e");
    }

    return trendingWallpapers;
  }

  static Future<List<PhotosModel>> searchWallpapers(String query) async {
    try {
      searchWallpapersList.clear();
      final response = await http.get(
        Uri.parse(
            "https://api.pexels.com/v1/search?query=$query&per_page=30&page=1"),
        headers: {"Authorization": _apiKey},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        List photos = jsonData['photos'];
        for (var element in photos) {
          searchWallpapersList.add(PhotosModel.fromAPI2App(element));
        }
      } else {
        print("Failed to search wallpapers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred while searching wallpapers: $e");
    }

    return searchWallpapersList;
  }

  static Future<List<CategoryModel>> getCategoriesList() async {
    List<String> categoryNames = [
      "Cars",
      "Nature",
      "Bikes",
      "Street",
      "City",
      "Flowers"
    ];
    cateogryModelList.clear();

    final _random = Random();
    for (String catName in categoryNames) {
      List<PhotosModel> photoList = await searchWallpapers(catName);
      if (photoList.isNotEmpty) {
        PhotosModel photoModel = photoList[_random.nextInt(photoList.length)];
        cateogryModelList
            .add(CategoryModel(catImgUrl: photoModel.imgSrc, catName: catName));
      }
    }

    return cateogryModelList;
  }
}
