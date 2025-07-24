// lib/features/pengepul/models/sampah_model.dart
class SampahStok {
  final String id;
  final String jenis;
  final double jumlah;
  final DateTime lastUpdate;

  SampahStok({
    required this.id,
    required this.jenis,
    required this.jumlah,
    required this.lastUpdate,
  });

  factory SampahStok.fromJson(Map<String, dynamic> json) {
    return SampahStok(
      id: json['id'] ?? '',
      jenis: json['jenis'] ?? '',
      jumlah: (json['jumlah'] ?? 0).toDouble(),
      lastUpdate: DateTime.tryParse(json['lastUpdate'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenis': jenis,
      'jumlah': jumlah,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  SampahStok copyWith({
    String? id,
    String? jenis,
    double? jumlah,
    DateTime? lastUpdate,
  }) {
    return SampahStok(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      jumlah: jumlah ?? this.jumlah,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

// lib/features/pengepul/models/transaksi_model.dart
class TransaksiPembelian {
  final String id;
  final String namaMasyarakat;
  final String jenisSampah;
  final double berat;
  final double harga;
  final String tanggal;
  final String alamat;

  TransaksiPembelian({
    required this.id,
    required this.namaMasyarakat,
    required this.jenisSampah,
    required this.berat,
    required this.harga,
    required this.tanggal,
    required this.alamat,
  });

  factory TransaksiPembelian.fromJson(Map<String, dynamic> json) {
    return TransaksiPembelian(
      id: json['id'] ?? '',
      namaMasyarakat: json['namaMasyarakat'] ?? '',
      jenisSampah: json['jenisSampah'] ?? '',
      berat: (json['berat'] ?? 0).toDouble(),
      harga: (json['harga'] ?? 0).toDouble(),
      tanggal: json['tanggal'] ?? '',
      alamat: json['alamat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaMasyarakat': namaMasyarakat,
      'jenisSampah': jenisSampah,
      'berat': berat,
      'harga': harga,
      'tanggal': tanggal,
      'alamat': alamat,
    };
  }
}

// Data service untuk dummy data
class SampahDataService {
  static List<SampahStok> getStokSampah() {
    return [
      SampahStok(
        id: 'stok_1',
        jenis: 'Plastik',
        jumlah: 120.5,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SampahStok(
        id: 'stok_2',
        jenis: 'Kertas',
        jumlah: 75.0,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      SampahStok(
        id: 'stok_3',
        jenis: 'Besi',
        jumlah: 22.8,
        lastUpdate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SampahStok(
        id: 'stok_4',
        jenis: 'Kaca',
        jumlah: 45.2,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      SampahStok(
        id: 'stok_5',
        jenis: 'Aluminium',
        jumlah: 8.5,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}

class TransaksiDataService {
  static List<TransaksiPembelian> getRiwayatPembelian() {
    return [
      TransaksiPembelian(
        id: 'trans_1',
        namaMasyarakat: 'Budi Santoso',
        jenisSampah: 'Plastik',
        berat: 5.5,
        harga: 27500,
        tanggal: '15 Januari 2024',
        alamat: 'Jl. Merdeka No. 123',
      ),
      TransaksiPembelian(
        id: 'trans_2',
        namaMasyarakat: 'Siti Nurhaliza',
        jenisSampah: 'Kertas',
        berat: 8.2,
        harga: 16400,
        tanggal: '14 Januari 2024',
        alamat: 'Jl. Sudirman No. 45',
      ),
      TransaksiPembelian(
        id: 'trans_3',
        namaMasyarakat: 'Ahmad Wijaya',
        jenisSampah: 'Besi',
        berat: 3.7,
        harga: 18500,
        tanggal: '13 Januari 2024',
        alamat: 'Jl. Diponegoro No. 67',
      ),
      TransaksiPembelian(
        id: 'trans_4',
        namaMasyarakat: 'Maya Sari',
        jenisSampah: 'Plastik',
        berat: 4.1,
        harga: 20500,
        tanggal: '12 Januari 2024',
        alamat: 'Jl. Ahmad Yani No. 89',
      ),
      TransaksiPembelian(
        id: 'trans_5',
        namaMasyarakat: 'Eko Prasetyo',
        jenisSampah: 'Kaca',
        berat: 6.8,
        harga: 13600,
        tanggal: '11 Januari 2024',
        alamat: 'Jl. Gajah Mada No. 21',
      ),
      TransaksiPembelian(
        id: 'trans_6',
        namaMasyarakat: 'Rina Dewi',
        jenisSampah: 'Kertas',
        berat: 7.3,
        harga: 14600,
        tanggal: '10 Januari 2024',
        alamat: 'Jl. Kartini No. 34',
      ),
      TransaksiPembelian(
        id: 'trans_7',
        namaMasyarakat: 'Dodi Hermawan',
        jenisSampah: 'Aluminium',
        berat: 2.1,
        harga: 21000,
        tanggal: '09 Januari 2024',
        alamat: 'Jl. Pahlawan No. 56',
      ),
      TransaksiPembelian(
        id: 'trans_8',
        namaMasyarakat: 'Lestari Indah',
        jenisSampah: 'Plastik',
        berat: 9.4,
        harga: 47000,
        tanggal: '08 Januari 2024',
        alamat: 'Jl. Kenanga No. 78',
      ),
    ];
  }
}