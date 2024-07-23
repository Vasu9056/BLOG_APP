import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import this package for date formatting

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool isLiked = false;
  User? user; // Store the current user

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    checkIfLiked();
  }

  void checkIfLiked() async {
    if (user != null) {
      var doc = await FirebaseFirestore.instance
          .collection('blog_posts')
          .doc(widget.postId)
          .get();
      var postData = doc.data() as Map<String, dynamic>? ?? {};
      var likes = postData['likes'] as List<dynamic>? ?? [];
      setState(() {
        isLiked = likes.contains(user!.uid);
      });
    }
  }

  void toggleLike() {
    if (user == null) return;

    setState(() {
      isLiked = !isLiked;
    });

    var postRef =
        FirebaseFirestore.instance.collection('blog_posts').doc(widget.postId);
    if (isLiked) {
      postRef.update({
        'likes': FieldValue.arrayUnion([user!.uid]),
      });
    } else {
      postRef.update({
        'likes': FieldValue.arrayRemove([user!.uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFEE8206),
        title: Text(
          "Posts",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('blog_posts')
            .doc(widget.postId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post not found'));
          }

          var postData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          Timestamp timestamp = postData['timestamp'] ?? Timestamp.now();
          DateTime dateTime = timestamp.toDate();
          String formattedDate =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      postData['imageUrl'] ?? '',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    postData['title'] ?? 'No Title',
                    style: GoogleFonts.leagueSpartan(
                      color: const Color(0xFF101213),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          postData['content'] ?? 'No Description',
                          style: GoogleFonts.leagueSpartan(
                            color: const Color.fromARGB(255, 84, 87, 88),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted on: $formattedDate',
                    style: GoogleFonts.leagueSpartan(
                      color: const Color.fromARGB(255, 84, 87, 88),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: toggleLike,
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
