import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dashboard/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberPassword = false;
  bool _isLoading = false;

  Future<void> handleSubmit() async {
    final email = _emailController.value.text;
    final password = _passwordController.value.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashBoard()),
      );
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration getInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(
        icon,
        color: Colors.black,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(35.0),
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(35.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(35.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFE40001),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                      bottomRight: Radius.circular(80),
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 5.0,
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 50),
                  child: const Column(
                    children: [
                      Text(
                        "SCDM System",
                        style: TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Doctor's Dashboard",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(top: 200),
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration:
                                      getInputDecoration('Email', Icons.person),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: getInputDecoration(
                                      'Password', Icons.lock),
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 10),
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: Colors.black,
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberPassword,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberPassword = value ?? false;
                                          });
                                        },
                                        activeColor: Colors.red,
                                        checkColor: Colors.white,
                                      ),
                                      const Text(
                                        'Remember Password',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Container(
                                  width: 300,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 228, 0, 0),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 25,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: LoginPage()));
}
