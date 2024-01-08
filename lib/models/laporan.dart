class Laporan {
  final String uid;
  final String docId;
  List? likes;
  final String judul;
  final String instansi;
  String? deskripsi;
  String? gambar;
  final String nama;
  final String status;
  final DateTime tanggal;
  final String maps;
  List<Komentar>? komentar;

  Laporan({
    required this.uid,
    required this.docId,
    required this.judul,
    required this.instansi,
    this.deskripsi,
    this.gambar,
    this.likes,
    required this.nama,
    required this.status,
    required this.tanggal,
    required this.maps,
    this.komentar,
  });

  factory Laporan.fromMap(Map<String, dynamic> map) {
    return Laporan(
        uid: map['uid'],
        docId: map['docId'],
        judul: map['judul'],
        instansi: map['instansi'],
        nama: map['nama'],
        status: map['status'],
        tanggal: map['tanggal'],
        maps: map['maps'],
        komentar: List<Komentar>.from(map['komentar']?.map((x) => Komentar.fromMap(x)))
    );
  }
}

class Komentar {
  final String nama;
  final String isi;

  Komentar({
    required this.nama,
    required this.isi,
  });

  factory Komentar.fromMap(Map<String, dynamic> map) {
    return Komentar(
      nama: map['nama'],
      isi: map['isi'],
    );
  }
}
