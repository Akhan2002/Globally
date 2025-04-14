import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_back_button.dart';
import 'package:globally/components/my_feed.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Map<String, Map<String, dynamic>> userMap = {};
  List<QueryDocumentSnapshot> likedPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadUserMap();

    final postsSnapshot = await FirebaseFirestore.instance
        .collection("Posts")
        .get();

    List<QueryDocumentSnapshot> liked = [];

    for (final post in postsSnapshot.docs) {
      final likeDoc = await post.reference
          .collection("likes")
          .doc(currentUser!.email)
          .get();

      if (likeDoc.exists) {
        liked.add(post);
      }
    }

    setState(() {
      likedPosts = liked;
      isLoading = false;
    });
  }

  Future<void> loadUserMap() async {
    final users = await FirebaseFirestore.instance.collection("Users").get();
    Map<String, Map<String, dynamic>> map = {};

    for (var doc in users.docs) {
      final data = doc.data();
      final email = data["email"];
      final username = data["username"] ?? "Unknown";
      final profileImageUrl = data["profileImageUrl"];

      if (email != null) {
        map[email] = {
          "username": username,
          "profileImageUrl": profileImageUrl,
        };
      }
    }

    userMap = map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0),
              child: Row(children: [MyBackButton()]),
            ),
            const SizedBox(height: 8),
            const Text("Your Favorites", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MyFeed(
                posts: likedPosts,
                userMap: userMap,
                onImageTap: (url) {
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
                            child: Image.network(url),
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
