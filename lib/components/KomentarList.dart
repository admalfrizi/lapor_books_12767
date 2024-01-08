import 'package:flutter/material.dart';

import '../models/akun.dart';
import '../models/laporan.dart';
import 'styles.dart';

class KomentarList extends StatefulWidget {
  final String nama;
  final String isi;

  const KomentarList({required this.nama, required this.isi,super.key});

  @override
  State<KomentarList> createState() => _KomentarListState();
}

class _KomentarListState extends State<KomentarList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.nama,
                style: headerStyle(level: 3),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                  widget.isi
              )
            ],
          ),
        ),
      ),
    );
  }
}
