import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book_apps/pages/main/all_laporan_page.dart';
import 'package:lapor_book_apps/pages/main/profile_page.dart';

import '../components/styles.dart';
import '../models/akun.dart';
import 'main/my_laporan_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardFull();
  }
}

class DashboardFull extends StatefulWidget {
  const DashboardFull({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardFull();
}

class _DashboardFull extends State<DashboardFull> {

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Akun akun = Akun(
    uid: '',
    docId: '',
    nama: '',
    email: '',
    role: '',
    noHp: '',
  );

  int _selectedIndex = 0;
  List<Widget> pages = [];

  void getAkun() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('akun')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print(userData);

        setState(() {
          akun = Akun(
              uid: userData['uid'],
              nama: userData['nama'],
              email: userData['email'],
              docId: userData['docId'],
              role: userData['role'],
              noHp: userData['noHP']
          );
        });
      }
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
  void initState() {
    super.initState();
    getAkun();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    pages = <Widget>[
      AllLaporanPage(akun: akun),
      const MyLaporanPage(),
      ProfilePage(akun: akun),
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add, size: 35),
        onPressed: () {},
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Lapor Book'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        selectedFontSize: 16,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey[800],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Semua',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Laporan Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : pages.elementAt(_selectedIndex),
    );
  }
}