import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globally/components/my_button.dart';
import 'package:globally/components/my_textfield.dart';

import '../helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {

  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPwController = TextEditingController();

  //register method
  void registerUser() async{
    //loading
    showDialog(context: context,
        builder: (context)=> const Center(
          child: CircularProgressIndicator(),
        ),
    );

    // password don't match
    if (passwordController.text != confirmPwController.text){
      //loading stops
      Navigator.pop(context);
      //error message
      displayMessageToUser("Passwords don't match!",context);
    }

    // passwords match
    else {
      try {
        //attempt
        UserCredential? userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

        //add user to database
        createUserDocument(userCredential);

        //loading stops
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch(e){
        //loading stops
        Navigator.pop(context);
        //display error
        displayMessageToUser(e.code, context);
      }
    }
    // try create user
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null){
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
            'email': userCredential.user!.email,
            'username': usernameController.text,
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),

                  // app name
                  const SizedBox(height: 25),
                  const Text(
                    "Globally",
                    style: TextStyle(fontSize: 20),
                  ),

                  //username field
                  const SizedBox(height: 50),
                  MyTextField(
                      hintText: "Username",
                      obscureText: false,
                      controller: usernameController
                  ),

                  //email field
                  const SizedBox(height: 10),
                  MyTextField(
                      hintText: "Email",
                      obscureText: false,
                      controller: emailController
                  ),

                  const SizedBox(height: 10),
                  MyTextField(
                      hintText: "Password",
                      obscureText: true,
                      controller: passwordController
                  ),

                  const SizedBox(height: 10),
                  MyTextField(
                      hintText: "Confirm Password",
                      obscureText: true,
                      controller: confirmPwController
                  ),

                  //forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Forgot Password?",
                        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                      ),

                    ],
                  ),

                  //register button
                  const SizedBox(height: 25),
                  MyButton(
                    text: "Register",
                    onTap: registerUser,
                  ),

                  //registration
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already Have an Account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(" Login Here",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            )

        )
    );
  }
}