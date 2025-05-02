import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController =
  TextEditingController(text: "name@gmail.com");
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 80),
              _logo(),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "Welcome back!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "EMAIL ADDRESS",
                  suffixIcon: const Icon(Icons.check),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "PASSWORD",
                  suffixIcon: const Icon(Icons.visibility_off),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot password?"),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4380),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Log in",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text("or log in with")),
              const SizedBox(height: 16),
              _socialButtons(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: const Text("Get started!",
                        style: TextStyle(color: Colors.blue)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4A4380),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 48),
      ),
    );
  }

  Widget _socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleButton(Icons.facebook, Colors.blue),
        _circleButton(Icons.g_mobiledata, Colors.red),
        _circleButton(Icons.apple, Colors.black),
      ],
    );
  }

  Widget _circleButton(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }
}
