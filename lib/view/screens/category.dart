import 'package:flutter/material.dart';
import 'package:pixi_wallpaper/controller/apiOper.dart';
import 'package:pixi_wallpaper/model/photosModel.dart';
import 'package:pixi_wallpaper/view/screens/fullScreen.dart';
import 'package:pixi_wallpaper/view/widgets/customAppBar.dart';
import 'package:shimmer/shimmer.dart';

class CategoryScreen extends StatefulWidget {
  final String catName;
  final String catImgUrl;

  CategoryScreen({super.key, required this.catImgUrl, required this.catName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<PhotosModel> categoryResults = [];
  bool isLoading = true;

  /// Fetch related wallpapers for the category
  Future<void> getCatRelWall() async {
    try {
      categoryResults = await ApiOperations.searchWallpapers(widget.catName);
    } catch (e) {
      debugPrint("Error fetching category wallpapers: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCatRelWall();
  }

  /// Custom shimmer effect widget
  Widget shimmerEffect({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        color: Colors.grey[300],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: CustomAppBar(
          word1: "Pixel",
          word2: "Wallpaper",
        ),
      ),
      body: isLoading
          ? Center(
              child: shimmerEffect(height: 150, width: screenWidth),
            )
          : Column(
              children: [
                // Category Header Section
                Stack(
                  children: [
                    // Category Image
                    Image.network(
                      widget.catImgUrl,
                      height: 150,
                      width: screenWidth,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return shimmerEffect(height: 150, width: screenWidth);
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          shimmerEffect(height: 150, width: screenWidth),
                    ),
                    // Overlay
                    Container(
                      height: 150,
                      width: screenWidth,
                      color: Colors.black38,
                    ),
                    // Centered Category Text
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Category",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            widget.catName,
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Grid of Wallpapers
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 400,
                      crossAxisCount: 2,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categoryResults.length,
                    itemBuilder: (context, index) => GridTile(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreen(
                                imgUrl: categoryResults[index].imgSrc,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: categoryResults[index].imgSrc,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: borderRadius,
                              child: Image.network(
                                categoryResults[index].imgSrc,
                                height: 800,
                                width: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return shimmerEffect(height: 400, width: 200);
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
