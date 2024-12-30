import 'package:flutter/material.dart';
import 'package:pixi_wallpaper/controller/apiOper.dart';
import 'package:pixi_wallpaper/model/photosModel.dart';
import 'package:pixi_wallpaper/view/screens/fullScreen.dart';
import 'package:pixi_wallpaper/view/widgets/customAppBar.dart';
// Ensure SearchBar is correctly imported

class SearchScreen extends StatefulWidget {
  final String query;
  SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<PhotosModel> searchResults;
  bool isLoading = true;
  bool hasError = false; // To track if there is an error
  final TextEditingController _searchController = TextEditingController();

  // Fetch search results from API
  Future<void> getSearchResults() async {
    try {
      searchResults = await ApiOperations.searchWallpapers(widget.query);
      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching results. Please try again.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getSearchResults(); // Fetch results when screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    final double paddingValue = MediaQuery.of(context).size.width * 0.05;
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
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : hasError
              ? Center(child: Text('Error loading results. Try again.')) // Show error message
              : SingleChildScrollView(
                  child: Column(
                    children: [
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
                  ), // SearchBar widget for dynamic querying
                      SizedBox(height: 10),
                      // GridView for displaying search results
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                             mainAxisExtent: 400,
                          crossAxisCount: 2,
                          crossAxisSpacing: 13,
                          mainAxisSpacing: 10,
                          ),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return GridTile(
                              child: InkWell(
                                onTap: () {
                                  // Navigate to FullScreen view
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreen(
                                        imgUrl: searchResults[index].imgSrc,
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: searchResults[index].imgSrc, // Ensure the tag is unique
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        searchResults[index].imgSrc,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
