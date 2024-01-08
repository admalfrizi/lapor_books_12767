import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/status_dialog.dart';
import '../components/styles.dart';
import '../models/akun.dart';
import '../models/laporan.dart';

class DetailLaporanPage extends StatefulWidget {
  const DetailLaporanPage({super.key});

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  bool _isLoading = false;
  bool isLiked = false;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? status;
  Laporan? laporan;


  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  void statusDialog(laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    void checkLikes() async {
      var getLaporan = _firestore.collection('laporan').doc(laporan.docId);
      final currentUserId = _auth.currentUser?.uid;
      var docSnapshot = await getLaporan.get();
      if(docSnapshot.exists){
        Map<String, dynamic> data = docSnapshot.data()!;
        List likesData = data['likes'];

        if(likesData.contains(currentUserId) == true){
          if(mounted){
            setState(() {
              isLiked = true;
            });
          }
        }

      } else {
        if(mounted){
          setState(() {
            isLiked = false;
          });
        }
      }
    }

    void likedLaporan() async {
      DocumentReference getLaporan = _firestore.collection('laporan').doc(laporan.docId);
      final currentUserId = _auth.currentUser?.uid;

      getLaporan.update({
        'likes': FieldValue.arrayUnion([currentUserId])
      });

      setState(() {
        isLiked = true;
      });
    }


    if(mounted){
      checkLikes();
    }

    Future<int> getTotalLikes() async {
      var getLaporan = _firestore.collection('laporan').doc(laporan.docId);
      var docSnapshot = await getLaporan.get();

      Map<String, dynamic> data = docSnapshot.data()!;
      List? likesData = data['likes'];
      int? total = likesData?.length ?? 0;

      return total;
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 15),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/istock-default.jpg'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          laporan.status == 'Posted'
                              ? textStatus(
                                  'Posted', Colors.yellow, Colors.black)
                              : laporan.status == 'Process'
                                  ? textStatus(
                                      'Process', Colors.green, Colors.white)
                                  : textStatus(
                                      'Done', Colors.blue, Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                        trailing: SizedBox(width: 45),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                            child: Text(DateFormat('dd MMMM yyyy')
                                .format(laporan.tanggal))),
                        trailing: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      SizedBox(height: 50),
                      Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 12,),
                            FutureBuilder<int>(
                              future: getTotalLikes(),
                              builder: (BuildContext context,  snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  final likesTotal = snapshot.data;
                                  return Text(
                                    "${likesTotal.toString()} Likes",
                                    style: TextStyle(
                                      fontSize: 16
                                    ),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(laporan.deskripsi ?? ''),
                      ),
                      if (akun.role == 'admin')
                        Container(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Ubah Status'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: !isLiked ? FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          likedLaporan();
        },
        child: const Icon(
          Icons.favorite_rounded,
          color: Colors.white,
        ),
      ) : null,
    );
  }

  Container textStatus(String text, var bgcolor, var textcolor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: bgcolor,
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(color: textcolor),
      ),
    );
  }
}
