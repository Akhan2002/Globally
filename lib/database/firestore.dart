

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  //current user
  User? user = FirebaseAuth.instance.currentUser;
  //get posts from firebase
  final CollectionReference posts = FirebaseFirestore.instance.collection("Posts");

  //post a message
  Future<void> addPost(String message, {String? imageUrl}) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    await FirebaseFirestore.instance.collection("Posts").add({
      "UserEmail": userEmail,
      "PostMessage": message,
      "TimeStamp": Timestamp.now(),
      if (imageUrl != null) "ImageUrl": imageUrl,
    });
  }

  //read posts from firebase
  Stream<QuerySnapshot> getPostsStream(){
    final postsStream = FirebaseFirestore.instance
        .collection("Posts")
        .orderBy("TimeStamp", descending: true)
        .snapshots();
    return postsStream;
  }

}