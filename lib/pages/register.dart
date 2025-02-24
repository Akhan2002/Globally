import 'package:flutter/material.dart';
import 'package:globally/components/my_button.dart';
import 'package:globally/components/my_textfield.dart';
import 'package:globally/components/my_button.dart';

class RegisterPage extends StatelessWidget {

  final Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  //register method
  void register(){

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
                    onTap: register,
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
                        onTap: onTap,
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