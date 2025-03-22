

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  //current user
  User? user = FirebaseAuth.instance.currentUser;
  //get posts from firebase
  final CollectionReference posts = FirebaseFirestore.instance.collection("Posts");

  //post a message
  Future<void> addPost(String message){
    return posts.add({
      'UserEmail': user!.email,
      'PostMessage': message,
      'TimeStamp': Timestamp.now(),
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