import 'package:flutter/material.dart';
  // Import the shimmer package
import 'package:pixi_wallpaper/controller/apiOper.dart';
import 'package:pixi_wallpaper/model/categoryModel.dart';
import 'package:pixi_wallpaper/model/photosModel.dart';
import 'package:pixi_wallpaper/view/screens/fullScreen.dart';
import 'package:pixi_wallpaper/view/screens/search.dart';
import 'package:pixi_wallpaper/view/widgets/categoryBlock.dart';
import 'package:pixi_wallpaper/view/widgets/customAppBar.dart';
import 'package:shimmer/shimmer.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PhotosModel>? trendingWallList;
  List<CategoryModel>? catModList;
  bool isLoading = true;
   final TextEditingController _searchController = TextEditingController();

  Future<void> getCatDetails() async {
    try {
      catModList = await ApiOperations.getCategoriesList();
      setState(() {});
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> getTrendingWallpapers() async {
    try {
      trendingWallList = await ApiOperations.getTrendingWallpapers();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching trending wallpapers: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCatDetails();
    getTrendingWallpapers();
  }

  Widget buildShimmerEffect({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double paddingValue = MediaQuery.of(context).size.width * 0.05;
    final size = MediaQuery.of(context).size;

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
          ? SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar Placeholder
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: buildShimmerEffect(width: size.width, height: 50),
                  ),

                  // Categories Shimmer
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: buildShimmerEffect(width: 100, height: 50),
                        ),
                      ),
                    ),
                  ),

                  // Grid Shimmer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 400,
                        crossAxisSpacing: 13,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) => buildShimmerEffect(
                          width: size.width / 2 - 20, height: 400),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
      padding: EdgeInsets.symmetric(horizontal: paddingValue),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration.collapsed(hintText: "Search Wallpapers"),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_searchController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a search query")),
                );
              } else {
                FocusScope.of(context).unfocus(); // Dismiss the keyboard
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(query: _searchController.text),
                  ),
                );
              }
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
    ),
                  ),

                  // Categories Section
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      height: 50,
                      width: size.width,
                      child: catModList != null && catModList!.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: catModList!.length,
                              itemBuilder: (context, index) => CatBlock(
                                categoryImgSrc: catModList![index].catImgUrl,
                                categoryName: catModList![index].catName,
                              ),
                            )
                          : Center(child: Text("No Categories Found")),
                    ),
                  ),

                  // Wallpapers Grid
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await getTrendingWallpapers();
                        await getCatDetails();
                      },
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 400,
                          crossAxisCount: 2,
                          crossAxisSpacing: 13,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: trendingWallList?.length ?? 0,
                        itemBuilder: (context, index) => GridTile(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreen(
                                    imgUrl: trendingWallList![index].imgSrc,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: trendingWallList![index].imgSrc,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    trendingWallList![index].imgSrc,
                                    height: 400,
                                    width: size.width / 2 - 20,
                                    fit: BoxFit.cover,
                                  ),
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
            ),
    );
  }
}
