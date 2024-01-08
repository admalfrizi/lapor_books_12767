import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/list_item.dart';
import '../../models/akun.dart';
import '../../models/laporan.dart';

class MyLaporanPage extends StatefulWidget {
  final Akun akun;
  const MyLaporanPage({super.key, required this.akun});

  @override
  State<MyLaporanPage> createState() => _MyLaporanPageState();
}

class _MyLaporanPageState extends State<MyLaporanPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Laporan> listLaporan = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTransaksi();
  }

  void getTransaksi() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('laporan')
          .where('uid',
              isEqualTo: _auth.currentUser!
                  .uid) // kondisi untuk menccari laporan yang sesuai dengan akun yang telah login
          .get();

      setState(() {
        listLaporan.clear();
        for (var documents in querySnapshot.docs) {
          List<dynamic>? komentarData = documents.data()['komentar'];

          List<Komentar>? listKomentar = komentarData?.map((map) {
            return Komentar(
              nama: map['nama'],
              isi: map['isi'],
            );
          }).toList();
          listLaporan.add(
            Laporan(
              uid: documents.data()['uid'],
              docId: documents.data()['docId'],
              judul: documents.data()['judul'],
              instansi: documents.data()['instansi'],
              deskripsi: documents.data()['deskripsi'],
              nama: documents.data()['nama'],
              status: documents.data()['status'],
              gambar: documents.data()['gambar'],
              tanggal: documents['tanggal'].toDate(),
              maps: documents.data()['maps'],
              komentar: listKomentar,
            ),
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: listLaporan.isEmpty
            ? const Center(
                child: Column(
                  children: [Text('Datanya Kosong....')],
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1 / 1.234,
                ),
                itemCount: listLaporan.length,
                itemBuilder: (context, index) {
                  return ListItem(
                    laporan: listLaporan[index],
                    akun: widget.akun,
                    isLaporanku: true,
                  );
                }),
      ),
    );
  }
}
