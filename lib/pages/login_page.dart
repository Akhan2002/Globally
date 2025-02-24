import 'package:flutter/material.dart';
import 'package:globally/components/my_button.dart';
import 'package:globally/components/my_textfield.dart';
import 'package:globally/components/my_button.dart';

class LoginPage extends StatelessWidget {

  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  //login method
  void login(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.background,
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

              //email field
              const SizedBox(height: 50),
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

              //forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Forgot Password?",
                    style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                  ),

                ],
              ),

              //signin button
              const SizedBox(height: 25),
              MyButton(
                  text: "Login",
                  onTap: login,
              ),

              //registration
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't Have an Account?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(" Register Here",
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