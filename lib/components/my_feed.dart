import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_list_tile.dart';
import 'package:globally/pages/user_profile_page.dart';

class MyFeed extends StatelessWidget {
  final Stream<QuerySnapshot>? postStream;
  final Map<String, Map<String, dynamic>> userMap;
  final Function(String imageUrl) onImageTap;
  final List<QueryDocumentSnapshot>? posts;


  const MyFeed({
    super.key,
    required this.userMap,
    required this.onImageTap,
    this.postStream,
    this.posts,
  });

  @override
  Widget build(BuildContext context) {
    if (posts != null) {
      // 🔵 Use the provided list of posts directly (used in "Following" feed)
      final postList = posts!;
      if (postList.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Text("No posts from followed users yet."),
          ),
        );
      }

      return buildPostList(context, postList);
    }

    return StreamBuilder(
      stream: postStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final postList = snapshot.data?.docs ?? [];

        if (postList.isEmpty) {
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text("No Posts...Post Something!"),
            ),
          );
        }

        return buildPostList(context, postList);
      },
    );
  }

  Widget buildPostList(BuildContext context, List<QueryDocumentSnapshot> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final postData = post.data() as Map<String, dynamic>;
        final message = postData["PostMessage"] ?? '';
        final userEmail = postData["UserEmail"];
        final imageUrl = postData["ImageUrl"];
        final postId = post.id;
        final timestamp = postData["TimeStamp"] as Timestamp?;
        final postTime = timestamp?.toDate();
        final formattedTime = postTime != null
            ? "${postTime.month}/${postTime.day} ${postTime.hour}:${postTime.minute.toString().padLeft(2, '0')}"
            : '';

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
                      backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                      child: profileImageUrl == null ? const Icon(Icons.person, size: 16) : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    username,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (message.isNotEmpty) MyListTile(title: message, subTitle: ''),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () => onImageTap(imageUrl),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Posts")
                    .doc(postId)
                    .collection("likes")
                    .snapshots(),
                builder: (context, snapshot) {
                  final user = FirebaseAuth.instance.currentUser;
                  final hasLiked = snapshot.data?.docs
                      .any((doc) => doc.id == user?.email) ??
                      false;
                  final likeCount = snapshot.data?.docs.length ?? 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              hasLiked ? Icons.favorite : Icons.favorite_border,
                              color: hasLiked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              final ref = FirebaseFirestore.instance
                                  .collection("Posts")
                                  .doc(postId)
                                  .collection("likes")
                                  .doc(user!.email);

                              if (hasLiked) {
                                await ref.delete();
                              } else {
                                await ref.set({"timestamp": Timestamp.now()});
                              }
                            },
                          ),
                          Text('$likeCount'),
                        ],
                      ),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}


