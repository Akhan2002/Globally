import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  final String targetEmail;

  const UserProfilePage({super.key, required this.targetEmail});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  String username = '';
  String summary = '';
  String? profileImageUrl;
  bool isFollowing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.targetEmail)
        .get();

    final data = doc.data();
    if (data != null) {
      username = data["username"] ?? '';
      summary = data["summary"] ?? '';
      profileImageUrl = data["profileImageUrl"];
    }

    final followDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.targetEmail)
        .collection("followers")
        .doc(currentUser!.email)
        .get();

    isFollowing = followDoc.exists;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> toggleFollow() async {
    final currentUserEmail = currentUser!.email!;
    final targetEmail = widget.targetEmail;

    final targetFollowerRef = FirebaseFirestore.instance
        .collection("Users")
        .doc(targetEmail)
        .collection("followers")
        .doc(currentUserEmail);

    final currentUserFollowingRef = FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUserEmail)
        .collection("following")
        .doc(targetEmail);

    if (isFollowing) {
      await targetFollowerRef.delete();
      await currentUserFollowingRef.delete();
    } else {
      await targetFollowerRef.set({"timestamp": Timestamp.now()});
      await currentUserFollowingRef.set({"timestamp": Timestamp.now()});
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isOwnProfile = widget.targetEmail == currentUser!.email;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Column(
            children: [
              const Row(
                children: [
                  BackButton(),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Image
              CircleAvatar(
                radius: 60,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, size: 64)
                    : null,
              ),
              const SizedBox(height: 20),

              // Username
              Text(
                username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                widget.targetEmail,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Summary
              Text(
                summary.isNotEmpty ? summary : "No summary provided.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),

              // Follow Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwnProfile
                      ? Colors.grey
                      : Theme.of(context).brightness == Brightness.dark
                      ? Colors.tealAccent[700]
                      : Colors.blueAccent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isOwnProfile ? null : toggleFollow,
                icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add),
                label: Text(
                  isOwnProfile
                      ? "This is you"
                      : isFollowing
                      ? "Unfollow"
                      : "Follow",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
