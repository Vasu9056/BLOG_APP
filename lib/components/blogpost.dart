import 'package:blog_application/Screens/PostDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlogPost extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String postId;
  final Color titleBackgroundColor; // Background color of the title
  final Color titleTextColor; // Text color of the title

  const BlogPost({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.postId,
    required this.titleBackgroundColor,
    required this.titleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(postId: postId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(

            boxShadow: const [
              BoxShadow(
                blurRadius: 5,
                color: Color(0x411D2429),
                offset: Offset(
                  0.0,
                  5,
                ),
              )
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 1, 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  color: titleBackgroundColor, // Apply titleBackgroundColor
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: GoogleFonts.leagueSpartan(
                      color: titleTextColor, // Apply titleTextColor
                      fontSize: 22,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
