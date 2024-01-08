import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/akun.dart';
import '../models/laporan.dart';
import 'input_layout.dart';
import 'styles.dart';

class KomentarLaporanDialog extends StatefulWidget {
  final Laporan laporan;
  final Akun akun;
  const KomentarLaporanDialog({ required this.laporan,required this.akun});

  @override
  State<KomentarLaporanDialog> createState() => _KomentarLaporanDialogState();
}

class _KomentarLaporanDialogState extends State<KomentarLaporanDialog> {
  late String komentar;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void addKomentar() async {
    CollectionReference transaksiCollection = _firestore.collection('laporan');
    try {
      await transaksiCollection.doc(widget.laporan.docId).update({
        'komentar': FieldValue.arrayUnion([{
          "nama" : widget.akun.nama,
          "isi" : komentar
        }]),
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: primaryColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.laporan.judul,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                onChanged: (String value) => setState(() {
                  komentar = value;
                }),
                decoration: customInputDecoration("Isi Komentar"),
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addKomentar();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Simpan Komentar'),
            ),
          ],
        ),
      ),
    );
  }
}
