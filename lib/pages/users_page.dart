import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_back_button.dart';
import 'package:globally/helper/helper_functions.dart';
import 'package:globally/pages/user_profile_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Row(children: [MyBackButton()]),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("Users").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  displayMessageToUser("Something went wrong", context);
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((user) {
                  final username = user["username"]?.toLowerCase() ?? '';
                  final email = user["email"]?.toLowerCase() ?? '';
                  return username.contains(searchQuery) || email.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final String username = user["username"] ?? "Unknown";
                    final String email = user["email"];
                    final Map<String, dynamic> data = user.data() as Map<String, dynamic>;
                    final String? imageUrl = data.containsKey("profileImageUrl") ? data["profileImageUrl"] : null;
                    final bool isOwnAccount = email == FirebaseAuth.instance.currentUser?.email;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                        child: imageUrl == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(username),
                      subtitle: Text(email),
                      trailing: isOwnAccount
                          ? null
                          : FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("Users")
                            .doc(email)
                            .collection("followers")
                            .doc(FirebaseAuth.instance.currentUser!.email)
                            .get(),
                        builder: (context, snapshot) {
                          final isFollowing = snapshot.data?.exists ?? false;
                          return TextButton.icon(
                            onPressed: () async {
                              final ref = FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(email)
                                  .collection("followers")
                                  .doc(FirebaseAuth.instance.currentUser!.email);

                              if (isFollowing) {
                                await ref.delete();
                              } else {
                                await ref.set({"timestamp": Timestamp.now()});
                              }

                              setState(() {}); // Refresh follow state
                            },
                            icon: Icon(
                              isFollowing ? Icons.person_remove : Icons.person_add,
                              color: Colors.white,
                            ),
                            label: Text(
                              isFollowing ? "Unfollow" : "Follow",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(targetEmail: email),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
