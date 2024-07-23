import 'package:blog_application/Screens/SearchScreen/Search_Screen.dart';
import 'package:blog_application/Widgets/Custom_Drawer.dart';
import 'package:blog_application/Widgets/BlogPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../../ThemeScreen/ThemeProvider_Screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String searchQuery = "";
  List<Map<String, dynamic>> blogPosts = [];
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;

  @override
  void initState() {
    super.initState();
    fetchBlogPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchBlogPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchBlogPosts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('blog_posts')
        .orderBy('timestamp')
        .limit(10);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      setState(() {
        blogPosts.addAll(querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
        hasMore = querySnapshot.docs.length == 10;
      });
    } else {
      setState(() {
        hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> searchBlogPosts(String query) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('blog_posts')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    QuerySnapshot contentSnapshot = await FirebaseFirestore.instance
        .collection('blog_posts')
        .where('content', arrayContains: query)
        .get();
    List<QueryDocumentSnapshot> combinedDocs =
        querySnapshot.docs + contentSnapshot.docs;

    final seen = <String>{};
    List<Map<String, dynamic>> blogPosts = combinedDocs
        .where((doc) {
          final id = doc.id;
          if (seen.contains(id)) {
            return false;
          } else {
            seen.add(id);
            return true;
          }
        })
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return blogPosts;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: const Color(0xFFEE8206),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "Posts",
            style: GoogleFonts.jua(
              color: isDarkMode ? Colors.grey.shade300 : Color(0xFFEE8206),
              fontSize: 50,
            ),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(48.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search posts...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.black : Colors.black,
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(
                              color: Color(0xFFEE8206),
                            )),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        filled: true,
                        fillColor:
                            isDarkMode ? Colors.grey.shade400 : Colors.white,
                        prefixIcon: Icon(Icons.search,
                            color: isDarkMode ? Colors.black : Colors.black),
                      ),
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.trim().toLowerCase();
                          blogPosts.clear();
                          lastDocument = null;
                          hasMore = true;
                          fetchBlogPosts();
                        });
                      },
                    ),
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: searchQuery.isEmpty
                      ? Future.value(blogPosts)
                      : searchBlogPosts(searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        blogPosts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching posts.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts found.'));
                    } else {
                      List<Map<String, dynamic>> displayedPosts =
                          snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                5, 5, 0, 0),
                            child: Text(
                              'Blogs',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...displayedPosts.map((post) {
                            return Column(
                              children: [
                                BlogPost(
                                  imageUrl: post['imageUrl'] ?? '',
                                  title: post['title'] ?? '',
                                  postId: post['postId'] ?? '',
                                  titleBackgroundColor: isDarkMode
                                      ? Colors.grey.shade200
                                      : Colors.white,
                                  titleTextColor:
                                      isDarkMode ? Colors.black : Colors.black,
                                ),
                                const SizedBox(
                                    height: 16), // Space between blog posts
                              ],
                            );
                          }).toList(),
                          if (isLoading)
                            const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
        child: GNav(
          haptic: true,
          curve: Curves.easeOutExpo,
          duration: const Duration(milliseconds: 900),
          gap: 8,
          color: isDarkMode ? Colors.white : Colors.grey.shade500,
          activeColor: const Color.fromARGB(187, 255, 255, 255),
          iconSize: 24,
          tabBackgroundColor: const Color(0xFFEE8206),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          tabs: [
            const GButton(
              icon: LineIcons.home,
            ),
            GButton(
              icon: LineIcons.search,
              iconSize: 30,
              onPressed: () => Get.to(() => SearchScreen()),
            ),
            GButton(
              icon: LineIcons.user,
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}
