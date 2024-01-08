import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/list_item.dart';
import '../../models/akun.dart';
import '../../models/laporan.dart';

class AllLaporanPage extends StatefulWidget {
  final Akun akun;
  AllLaporanPage({super.key, required this.akun});

  @override
  State<AllLaporanPage> createState() => _AllLaporanPageState();
}

class _AllLaporanPageState extends State<AllLaporanPage> {
  final _firestore = FirebaseFirestore.instance;

  List<Laporan> listLaporan = [];

  @override
  void initState() {
    super.initState();
    getTransaksi();
  }

  void getTransaksi() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('laporan').get();

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
      final snackbar = SnackBar(content: Text(e.toString()));
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    isLaporanku: false,
                  );
                }),
      ),
    );
  }
}
