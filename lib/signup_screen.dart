import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:authenticationtry/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      AssetImage("images/image.jpeg"), // Replace with your logo
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(height: 20),
                Text(
                  "Create An Account:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextField(usernameController, "Username"),
                _buildTextField(emailController, "Email"),
                _buildTextField(passwordController, "Password",
                    isPassword: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String message = await auth.signUp(
                        emailController.text, passwordController.text);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                    if (message == "Registration Successful!") {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => LoginScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  ),
                  child:
                      Text("Continue", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                Text("Or", style: TextStyle(color: Colors.white)),
                SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {}, // Implement Google Sign-In
                  icon: Image.asset("images/image.jpeg", width: 24),
                  label: Text("Register Using Google",
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => LoginScreen())),
                  child: Text(
                    "Already Have An Account? Login",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
