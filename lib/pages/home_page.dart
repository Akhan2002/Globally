import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_drawer.dart';
import 'package:globally/components/my_post_button.dart';
import 'package:globally/components/my_textfield.dart';
import 'package:globally/database/firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../components/my_feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final List<String> followingEmails = [];
  File? selectedImageFile;

  Map<String, Map<String, dynamic>> userMap = {}; // email → {username, profileImageUrl}

  late TabController _tabController;

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // When switching to "Following" tab
        loadFollowing();
      }
    });
    loadUserMap();
    loadFollowing();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadFollowing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.email)
        .collection("following")
        .get();

    setState(() {
      followingEmails.clear();
      for (var doc in snapshot.docs) {
        followingEmails.add(doc.id);
      }
    });
  }

  Future<void> loadUserMap() async {
    try {
      final users = await FirebaseFirestore.instance.collection("Users").get();
      print("📥 Loaded ${users.docs.length} users");

      Map<String, Map<String, dynamic>> map = {};

      for (var doc in users.docs) {
        final data = doc.data();
        final email = data["email"];
        final username = data["username"] ?? "Unknown";
        final profileImageUrl = data["profileImageUrl"];

        print("👤 User: $email, $username");

        if (email != null) {
          map[email] = {
            "username": username,
            "profileImageUrl": profileImageUrl,
          };
        }
      }

      setState(() {
        userMap = map;
      });

      print("✅ userMap loaded with ${userMap.length} users");

    } catch (e) {
      print("❌ Error loading user map: $e");
    }
  }

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImageFile = File(pickedFile.path);
      });
    }
  }

  void postMessage() async {
    String message = newPostController.text;
    String? imageUrl;

    if (selectedImageFile != null) {
      String fileName = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child("post_images/$fileName");

      try {
        UploadTask uploadTask = ref.putFile(selectedImageFile!);
        await uploadTask.whenComplete(() => print("✅ Upload task completed"));
        imageUrl = await ref.getDownloadURL();
        print("🌐 Image URL: $imageUrl");
      } catch (e) {
        print("❌ Image upload error: $e");
      }
    }

    if (message.isNotEmpty || imageUrl != null) {
      await database.addPost(message, imageUrl: imageUrl);
    }

    setState(() {
      selectedImageFile = null;
    });

    newPostController.clear();
  }

  void showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", textAlign: TextAlign.center),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                if (selectedImageFile != null)
                  Column(
                    children: [
                      Image.file(selectedImageFile!, height: 150),
                      const SizedBox(height: 10),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        hintText: "Say Something...",
                        obscureText: false,
                        controller: newPostController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: selectImage,
                    ),
                    PostButton(onTap: postMessage),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Wait for userMap to load first
          if (userMap.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: "All Posts"),
                      Tab(text: "Following"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // All Posts
                        MyFeed(
                          postStream: database.getPostsStream(),
                          userMap: userMap,
                          onImageTap: (url) => showFullImage(context, url),
                        ),
                          // Following Only Posts
                        StreamBuilder<QuerySnapshot>(
                          stream: database.getPostsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final allPosts = snapshot.data?.docs ?? [];
                            final filteredPosts = allPosts
                                .where((post) => followingEmails.contains(post['UserEmail']))
                                .toList();

                            return MyFeed(
                              posts: filteredPosts,
                              userMap: userMap,
                              onImageTap: (url) => showFullImage(context, url),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
