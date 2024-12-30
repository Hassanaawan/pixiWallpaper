import 'package:flutter/material.dart';
import 'package:pixi_wallpaper/view/screens/search.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double paddingValue = MediaQuery.of(context).size.width * 0.05;

    return Container(
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
    );
  }
}
