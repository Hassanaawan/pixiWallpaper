import 'package:flutter/material.dart';
import 'package:pixi_wallpaper/view/screens/category.dart';

class CatBlock extends StatelessWidget {
  final String categoryName;
  final String categoryImgSrc;

  CatBlock({
    super.key,
    required this.categoryImgSrc,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(
              catImgUrl: categoryImgSrc,
              catName: categoryName,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 7),
        child: Stack(
          alignment: Alignment.center,  // This will center the child widgets
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                categoryImgSrc,
                height: 100, // Adjusted to match the layout
                width: 100,  // Adjusted to match the layout
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 100,  // Adjusted to match the image size
              width: 100,   // Adjusted to match the image size
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Positioned(
              child: Text(
                categoryName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,  // Font size can be adjusted
                ),
                textAlign: TextAlign.center, // Ensures the text is centered
                overflow: TextOverflow.ellipsis, // Handles text overflow
              ),
            ),
          ],
        ),
      ),
    );
  }
}
