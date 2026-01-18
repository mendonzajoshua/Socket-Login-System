import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// CHANGE to your laptop IP
const String SERVER_IP = "192.168.29.209";
const int SERVER_PORT = 5001;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Socket Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      home: const LoginRegisterScreen(),
    );
  }
}

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureOld = true;
  bool _obscureNew = true;

  Future<void> sendRequest(String action) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (username.isEmpty ||
        (action != "update" && password.isEmpty) ||
        (action == "update" && (oldPassword.isEmpty || newPassword.isEmpty))) {
      showSnack("Please fill all required fields", false);
      return;
    }

    try {
      final socket = await Socket.connect(SERVER_IP, SERVER_PORT);

      final Map<String, String> request = {
        "action": action,
        "username": username,
      };

      if (action == "login" || action == "register") {
        request["password"] = password;
      } else {
        request["old_password"] = oldPassword;
        request["new_password"] = newPassword;
      }

      socket.writeln(jsonEncode(request));

      socket.listen((data) {
        final response = utf8.decode(data);
        showSnack(response, response.toLowerCase().contains("success"));
        socket.destroy();
      });
    } catch (_) {
      showSnack("Cannot connect to server", false);
    }
  }

  void showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  InputDecoration fieldStyle(String label, VoidCallback? toggle, bool obscure) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      suffixIcon: toggle == null
          ? null
          : IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: toggle,
            ),
    );
  }

  Widget actionButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Secure Login",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F7FA), Color(0xFFE4EBF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /* Grain overlay
          Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/grain.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),*/

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                buildCard(
                  title: "Login / Register",
                  children: [
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.black),

                      decoration: fieldStyle("Username", null, false),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureLogin,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: fieldStyle(
                        "Password",
                        () => setState(() => _obscureLogin = !_obscureLogin),
                        _obscureLogin,
                      ),
                    ),
                    const SizedBox(height: 16),
                    actionButton(
                      "Register",
                      Colors.green,
                      () => sendRequest("register"),
                    ),
                    const SizedBox(height: 10),
                    actionButton(
                      "Login",
                      Colors.blue,
                      () => sendRequest("login"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                buildCard(
                  title: "Update Password",
                  children: [
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: _obscureOld,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: fieldStyle(
                        "Old Password",
                        () => setState(() => _obscureOld = !_obscureOld),
                        _obscureOld,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: fieldStyle(
                        "New Password",
                        () => setState(() => _obscureNew = !_obscureNew),
                        _obscureNew,
                      ),
                    ),
                    const SizedBox(height: 16),
                    actionButton(
                      "Update Password",
                      Colors.orange,
                      () => sendRequest("update"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
