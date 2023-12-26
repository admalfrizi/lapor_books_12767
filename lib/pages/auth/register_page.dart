import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/input_layout.dart';
import '../../components/styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? nama;
  String? email;
  String? noHP;

  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void initState() {
    super.initState();
  }

  void register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference akunCollection = _db.collection('akun');

      final password = _password.text;
      await _auth.createUserWithEmailAndPassword(
          email: email!, password: password);

      final docId = akunCollection.doc().id;
      await akunCollection.doc(docId).set({
        'uid': _auth.currentUser!.uid,
        'nama': nama,
        'email': email,
        'noHP': noHP,
        'docId': docId,
        'role': 'user',
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      print(e);
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
              SizedBox(height: 80),
              Text('Register', style: headerStyle(level: 1)),
              Container(
                child: const Text(
                  'Create your profile to start your journey',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 50),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // di sini nanti komponen inputnya
                        InputLayout(
                            'Nama',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                  nama = value;
                                }),
                                decoration: customInputDecoration(
                                    "Nama Lengkap"))),
                        InputLayout(
                            'Email',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                  email = value;
                                }),
                                decoration: customInputDecoration(
                                    "email@email.com"))),
                        InputLayout(
                            'No. Handphone',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                  noHP = value;
                                }),
                                decoration: customInputDecoration(
                                    "+62 80000000"))),
                        InputLayout(
                            'Password',
                            TextFormField(
                                controller: _password,
                                obscureText: true,
                                decoration: customInputDecoration(""))),
                        InputLayout(
                            'Konfirmasi Password',
                            TextFormField(
                                obscureText: true,
                                decoration: customInputDecoration(""))),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width,
                          child: FilledButton(
                              style: buttonStyle,
                              child: Text('Register',
                                  style: headerStyle(level: 2)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  register();
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
                  const Text('Sudah punya akun? '),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login di sini',
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
