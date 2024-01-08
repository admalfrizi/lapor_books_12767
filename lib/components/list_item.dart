import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/akun.dart';
import '../models/laporan.dart';
import 'styles.dart';

class ListItem extends StatefulWidget {
  final Laporan laporan;
  final Akun akun;
  final bool isLaporanku;
  ListItem(
      {super.key,
      required this.laporan,
      required this.akun,
      required this.isLaporanku});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  void deleteLaporan() async {
    try {
      await _firestore.collection('laporan').doc(widget.laporan.docId).delete();

      // menghapus gambar dari storage
      if (widget.laporan.gambar != '') {
        await _storage.refFromURL(widget.laporan.gambar!).delete();
      }
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  Future<int> getLikedTotal() async {
    var getLaporan = _firestore.collection('laporan').doc(widget.laporan.docId);
    var docSnapshot = await getLaporan.get();

    Map<String, dynamic> data = docSnapshot.data()!;
    List? likesData = data['likes'];
    int? total = likesData?.length ?? 0;

    return total;
  }
  

  @override
  void initState() {
    super.initState();
    getLikedTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: {
            'laporan': widget.laporan,
            'akun': widget.akun,
          });
        },
        onLongPress: () {
          if (widget.isLaporanku) {
            showDialog(
                context: context,
                builder: (BuildContext) {
                  return AlertDialog(
                    title: Text('Delete ${widget.laporan.judul}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteLaporan();
                        },
                        child: Text('Hapus'),
                      ),
                    ],
                  );
                });
          }
        },
        child: Column(
          children: [
            widget.laporan.gambar != ''
                ? Image.network(
                    widget.laporan.gambar!,
                    width: 130,
                    height: 130,
                  )
                : Image.asset(
                    'assets/istock-default.jpg',
                    width: 130,
                    height: 130,
                  ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: const BoxDecoration(
                  border: Border.symmetric(horizontal: BorderSide(width: 2))),
              child: Text(
                widget.laporan.judul,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: warningColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                          ),
                          border: const Border.symmetric(
                              vertical: BorderSide(width: 1))),
                      alignment: Alignment.center,
                      child: Text(
                        widget.laporan.status,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(5)),
                          border: const Border.symmetric(
                              vertical: BorderSide(width: 1))),
                      alignment: Alignment.center,
                      child: FutureBuilder<int>(
                        future: getLikedTotal(),
                        builder: (BuildContext context,  snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator(),
                            );
                          } else {
                            final likesTotal = snapshot.data;
                            return Text(
                              "${likesTotal.toString()} Likes",
                            );
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
