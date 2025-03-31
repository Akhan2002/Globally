import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_back_button.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();

  String? profileImageUrl;
  File? newProfileImage;

  bool isEditing = false;

  String originalUsername = '';
  String originalSummary = '';
  String? originalImageUrl;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();

    final data = doc.data();
    if (data != null) {
      setState(() {
        originalUsername = data["username"] ?? '';
        originalSummary = data["summary"] ?? '';
        originalImageUrl = data["profileImageUrl"];

        usernameController.text = originalUsername;
        summaryController.text = originalSummary;
        profileImageUrl = originalImageUrl;
      });
    }
  }

  Future<void> pickProfileImage() async {
    if (!isEditing) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveChanges() async {
    String? imageUrl = profileImageUrl;

    if (newProfileImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_pics/${currentUser!.uid}.jpg");

      await ref.putFile(newProfileImage!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({
      "username": usernameController.text,
      "summary": summaryController.text,
      "profileImageUrl": imageUrl,
    });

    setState(() {
      profileImageUrl = imageUrl;
      originalImageUrl = imageUrl;
      originalUsername = usernameController.text;
      originalSummary = summaryController.text;
      newProfileImage = null;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  void cancelEdit() {
    setState(() {
      usernameController.text = originalUsername;
      summaryController.text = originalSummary;
      profileImageUrl = originalImageUrl;
      newProfileImage = null;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Column(
            children: [
              Row(
                children: [
                  const MyBackButton(),
                  const Spacer(),
                  if (!isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Image
              GestureDetector(
                onTap: pickProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: newProfileImage != null
                      ? FileImage(newProfileImage!)
                      : (profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null) as ImageProvider<Object>?,
                  child: (!isEditing &&
                      newProfileImage == null &&
                      profileImageUrl == null)
                      ? const Icon(Icons.person, size: 64)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Username
              isEditing
                  ? TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              )
                  : Text(
                usernameController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Summary
              isEditing
                  ? TextField(
                controller: summaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Summary",
                  border: OutlineInputBorder(),
                ),
              )
                  : Text(
                summaryController.text.isNotEmpty
                    ? summaryController.text
                    : "No summary provided.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // Save & Cancel buttons
              if (isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text("Save"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: cancelEdit,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.tealAccent
                              : Colors.blueAccent,
                        ),
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.tealAccent
                            : Colors.blueAccent,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel),
                          SizedBox(width: 8),
                          Text("Cancel"),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
