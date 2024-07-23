import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBlogScreen extends StatefulWidget {
  final String postId;

  EditBlogScreen({required this.postId});

  @override
  _EditBlogScreenState createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? _imageUrl;

  @override
  void initState() {
    super.initState();
  
    fetchBlogPost();
  }

  Future<void> fetchBlogPost() async {
    try {
      DocumentSnapshot blogSnapshot = await FirebaseFirestore.instance
          .collection('blog_posts')
          .doc(widget.postId)
          .get();

      if (blogSnapshot.exists) {
        setState(() {
          _titleController.text = blogSnapshot.get('title');
          _contentController.text = blogSnapshot.get('content');
          _imageUrl = blogSnapshot.get('imageUrl');
        });
      }
    } catch (e) {
      print("Error fetching blog post: $e");
    }
  }

  Future<void> updateBlogPost() async {
    try {
      await FirebaseFirestore.instance.collection('blog_posts').doc(widget.postId).update({
        'title': _titleController.text,
        'content': _contentController.text,
        // 'imageUrl': Optionally update imageUrl if needed
      });

      // Optionally update imageUrl logic if needed
      // This should include checking if a new image was uploaded and handling its URL update

      Navigator.pop(context); // Return to previous screen after update
    } catch (e) {
      print("Error updating blog post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Blog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Display existing image if available
            if (_imageUrl != null)
              Image.network(
                _imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateBlogPost,
              child: Text('Update Blog'),
            ),
          ],
        ),
      ),
    );
  }
}
