import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_drawer.dart';
import 'package:globally/components/my_list_tile.dart';
import 'package:globally/components/my_post_button.dart';
import 'package:globally/components/my_textfield.dart';
import 'package:globally/database/firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  //firestore access
  final FirestoreDatabase database = FirestoreDatabase();

  //text controller
  final TextEditingController newPostController = TextEditingController();

  //post message
  void postMessage(){
    if(newPostController.text.isNotEmpty){
      String message = newPostController.text;
      database.addPost(message);
    }

    newPostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Home",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),

      body: Column(
        children: [
          //textfield
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                      hintText: "Say Something...",
                      obscureText: false,
                      controller: newPostController
                  ),
                ),
                
                PostButton(
                    onTap: postMessage,
                ),
              ],
            ),
          ),

          //posts
          StreamBuilder(
              stream: database.getPostsStream(),
              builder: (context,snapshot) {
                //loading
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                //get posts
                final posts = snapshot.data!.docs;
                //no data
                if (snapshot.data == null || posts.isEmpty){
                  return const Center(child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No Posts...Post Something!"),
                    ),
                  );
                }
                //return list
                return Expanded(
                    child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context,index){
                          final post = posts[index];
                          String message = post["PostMessage"];
                          String userEmail = post["UserEmail"];
                          Timestamp timestamp = post["TimeStamp"];

                          return MyListTile(title: message, subTitle: userEmail);
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