import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_drawer.dart';
import 'package:globally/components/my_list_tile.dart';
import 'package:globally/components/my_post_button.dart';
import 'package:globally/components/my_textfield.dart';
import 'package:globally/database/firestore.dart';
import 'package:globally/pages/user_profile_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  File? selectedImageFile;

  Map<String, Map<String, dynamic>> userMap = {}; // email → {username, profileImageUrl}

  @override
  void initState() {
    super.initState();
    loadUserMap();
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
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )

          else
            StreamBuilder(
              stream: database.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final posts = snapshot.data!.docs;
                if (snapshot.data == null || posts.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Text("No Posts...Post Something!"),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final Map<String, dynamic>? postData = post.data() as Map<String, dynamic>?;
                        String message = post["PostMessage"];
                        String userEmail = post["UserEmail"];
                        String? imageUrl = postData != null && postData.containsKey("ImageUrl")
                            ? postData["ImageUrl"]
                            : null;

                        final userInfo = userMap[userEmail];
                        final username = userInfo?["username"] ?? userEmail;
                        final profileImageUrl = userInfo?["profileImageUrl"];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UserProfilePage(targetEmail: userEmail),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage: profileImageUrl != null
                                          ? NetworkImage(profileImageUrl)
                                          : null,
                                      child: profileImageUrl == null
                                          ? const Icon(Icons.person, size: 16)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    username,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (message.isNotEmpty)
                              MyListTile(title: message, subTitle: ''),
                            if (imageUrl != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: GestureDetector(
                                  onTap: () => showFullImage(context, imageUrl),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
