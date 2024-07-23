import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img; // Import image package for resizing

void main() async {
  runApp(TextEditor());
}

class TextEditor extends StatefulWidget {
  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  final HtmlEditorController controller = HtmlEditorController();
  String initialContent = ""; // Replace with your initial HTML content

  @override
  void initState() {
    super.initState();
    // Load initial content from a file (optional)
    loadInitialContent();
  }

  Future<void> loadInitialContent() async {
    try {
      final String content =
          await rootBundle.loadString('assets/initial_content.html');
      setState(() {
        initialContent = content;
        // controller.text = initialContent; // Initialize controller text here
      });
    } catch (error) {
      print("Error loading initial content: $error");
    }
  }

  Future<void> saveContent() async {
    // final String content = controller.text;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_html_content.html');
      // await file.writeAsString(content);
      print('Content saved successfully!');
    } catch (error) {
      print("Error saving content: $error");
    }
  }

  void insertImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // Resize image
        final resizedImage = await resizeImage(imageFile);

        // Convert resized image to base64
        final base64Image = base64Encode(resizedImage);

        // Insert into HTML editor
        controller.insertHtml('<img src="data:image/png;base64,$base64Image"/>');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<Uint8List> resizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    // Resize image to a maximum width of 800 pixels (adjust as needed)
    final resizedImage = img.copyResize(image!, width: 800);

    // Convert resized image to Uint8List (byte data)
    return resizedImage.getBytes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('HTML Text Editor'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: saveContent,
            ),
            IconButton(
              icon: Icon(Icons.image),
              onPressed: insertImage,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              HtmlEditor(
                controller: controller,
                // Other properties can be added as needed
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
