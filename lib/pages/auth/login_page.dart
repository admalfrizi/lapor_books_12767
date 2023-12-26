import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book_apps/components/validators.dart';

import '../../components/input_layout.dart';
import '../../components/styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String? email;
  String? password;

  void login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);

      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', ModalRoute.withName('/dashboard'));
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Text('Login', style: headerStyle(level:1)),
              Container(
                child: const Text(
                  'Login to your account',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InputLayout(
                            'Email',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                  email = value;
                                }),
                                validator: notEmptyValidator,
                                decoration: customInputDecoration(
                                    "email@email.com"))),
                        InputLayout(
                            'Password',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                  password = value;
                                }),
                                validator: notEmptyValidator,
                                obscureText: true,
                                decoration: customInputDecoration(""))),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width,
                          child: FilledButton(
                              style: buttonStyle,
                              child: Text('Login',
                                  style:
                                  headerStyle(level: 3, dark: false)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              }),
                        )
                      ],
                    )),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, '/register'),
                    child: const Text('Daftar di sini',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
