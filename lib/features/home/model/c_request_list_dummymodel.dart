// lib/features/home/model/c_request_list_dummymodel.dart
import 'dart:math';

enum RequestType { all, toYou }

enum RequestStatus { pending, accepted, completed, cancelled }

class TrashItem {
  final String name;
  final double weight;

  TrashItem({required this.name, required this.weight});

  factory TrashItem.fromJson(Map<String, dynamic> json) {
    return TrashItem(
      name: json['trash_name'] ?? '',
      weight: (json['amoun_weight'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'trash_name': name, 'amoun_weight': weight};
  }
}

class RequestModel {
  final String id;
  final String name;
  final String phone;
  final List<TrashItem> trashItems;
  final String address;
  final double distanceFromYou;
  final String requestedAt;
  final RequestStatus status;
  final String? imageUrl;

  RequestModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.trashItems,
    required this.address,
    required this.distanceFromYou,
    required this.requestedAt,
    this.status = RequestStatus.pending,
    this.imageUrl,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      trashItems: (json['request_trash'] as List? ?? [])
          .map((item) => TrashItem.fromJson(item))
          .toList(),
      address: json['address'] ?? '',
      distanceFromYou: (json['distance_from_you'] ?? 0).toDouble(),
      requestedAt: json['requestedAt'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'request_trash': trashItems.map((item) => item.toJson()).toList(),
      'address': address,
      'distance_from_you': distanceFromYou,
      'requestedAt': requestedAt,
      'status': status.name,
      'imageUrl': imageUrl,
    };
  }

  double get totalWeight {
    return trashItems.fold(0, (sum, item) => sum + item.weight);
  }

  String get statusText {
    switch (status) {
      case RequestStatus.pending:
        return 'Menunggu';
      case RequestStatus.accepted:
        return 'Diterima';
      case RequestStatus.completed:
        return 'Selesai';
      case RequestStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  RequestModel copyWith({
    String? id,
    String? name,
    String? phone,
    List<TrashItem>? trashItems,
    String? address,
    double? distanceFromYou,
    String? requestedAt,
    RequestStatus? status,
    String? imageUrl,
  }) {
    return RequestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      trashItems: trashItems ?? this.trashItems,
      address: address ?? this.address,
      distanceFromYou: distanceFromYou ?? this.distanceFromYou,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class RequestDataService {
  static final Random _random = Random();

  // Data realistic untuk mock
  static const List<String> _indonesianNames = [
    'Budi Santoso',
    'Siti Nurhaliza',
    'Ahmad Fauzi', 
    'Dewi Sartika',
    'Bambang Wijaya',
    'Ratna Sari',
    'Eko Prasetyo',
    'Maya Indira',
    'Rizki Ramadhan',
    'Indah Permata',
    'Dani Setiawan',
    'Lestari Wulandari',
    'Agus Hermawan',
    'Sari Melati',
    'Joko Susilo',
    'Fitri Handayani',
    'Wahyu Hidayat',
    'Nina Marlina',
    'Dimas Pratama',
    'Rina Kusuma',
  ];

  static const List<String> _areas = [
    'Jl. Mawar No. 15, Kel. Sumberjo',
    'Jl. Melati Raya 23, Kel. Tegalrejo', 
    'Jl. Anggrek 8, Kel. Karangbesuki',
    'Jl. Dahlia 12A, Kel. Sukun',
    'Jl. Bougenville 45, Kel. Lowokwaru',
    'Jl. Tulip 7, Kel. Blimbing',
    'Jl. Sakura 33, Kel. Klojen',
    'Jl. Kenanga 21, Kel. Kedungkandang',
    'Jl. Cempaka 18, Kel. Mergelo',
    'Jl. Seruni 9, Kel. Mulyorejo',
    'Jl. Flamboyan 27, Kel. Purwantoro',
    'Jl. Alamanda 14, Kel. Arjosari',
    'Jl. Kamboja 31, Kel. Bunulrejo',
    'Jl. Teratai 6, Kel. Dinoyo',
    'Jl. Lily 19, Kel. Jatimulyo',
    'Jl. Gardenia 22, Kel. Landungsari',
    'Jl. Azalea 11, Kel. Kasin',
    'Jl. Zinnia 16, Kel. Gadang',
    'Jl. Lavender 25, Kel. Ketawanggede',
    'Jl. Jasmine 13, Kel. Sawojajar',
  ];

  static const List<String> _trashTypes = [
    'Botol Plastik',
    'Kardus',
    'Kertas',
    'Kaleng Bekas',
    'Botol Kaca',
    'Plastik Kemasan',
    'Koran Bekas',
    'Majalah',
    'Kantong Plastik',
    'Wadah Makanan',
    'Galon Bekas',
    'Ember Plastik',
    'Jerigen',
    'Dus Minuman',
    'Tempat Makan Styrofoam',
  ];

  static const List<RequestStatus> _statusOptions = [
    RequestStatus.pending,
    RequestStatus.accepted,
    RequestStatus.completed,
    RequestStatus.cancelled,
  ];

  static List<RequestModel> getAllRequests() {
    final List<RequestModel> requests = [];
    
    // Generate 8 requests dengan data realistis
    for (int i = 0; i < 8; i++) {
      final nameIndex = i % _indonesianNames.length;
      final areaIndex = i % _areas.length;
      
      // Generate random trash items (1-4 items)
      final trashCount = _random.nextInt(3) + 1; // 1-3 items
      final List<TrashItem> trashItems = [];
      
      for (int j = 0; j < trashCount; j++) {
        final trashIndex = _random.nextInt(_trashTypes.length);
        final weight = (_random.nextDouble() * 20 + 5); // 5-25 kg
        trashItems.add(TrashItem(
          name: _trashTypes[trashIndex],
          weight: double.parse(weight.toStringAsFixed(1)),
        ));
      }
      
      // Generate realistic phone number
      final phoneVariations = [
        '6281${_random.nextInt(900000000) + 100000000}',
        '6282${_random.nextInt(900000000) + 100000000}',
        '6285${_random.nextInt(900000000) + 100000000}',
        '6287${_random.nextInt(900000000) + 100000000}',
        '6288${_random.nextInt(900000000) + 100000000}',
      ];
      
      // Generate realistic time (last 24 hours)
      final hours = _random.nextInt(24);
      final minutes = _random.nextInt(60);
      final timeString = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      
      // Generate realistic distance (0.5 - 15 km)
      final distance = (_random.nextDouble() * 14.5 + 0.5);
      
      // Assign status based on time (older requests more likely to be processed)
      RequestStatus status;
      if (hours < 2) {
        status = RequestStatus.pending; // Recent requests are usually pending
      } else if (hours < 8) {
        status = _random.nextBool() ? RequestStatus.pending : RequestStatus.accepted;
      } else if (hours < 16) {
        final statusRand = _random.nextInt(3);
        status = [RequestStatus.accepted, RequestStatus.completed, RequestStatus.pending][statusRand];
      } else {
        final statusRand = _random.nextInt(4);
        status = _statusOptions[statusRand];
      }
      
      requests.add(RequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: _indonesianNames[nameIndex],
        phone: phoneVariations[i % phoneVariations.length],
        trashItems: trashItems,
        address: _areas[areaIndex],
        distanceFromYou: double.parse(distance.toStringAsFixed(1)),
        requestedAt: timeString,
        status: status,
        imageUrl: i % 3 == 0 ? 'https://via.placeholder.com/150x150/cccccc/999999?text=Sampah+${i + 1}' : null,
      ));
    }
    
    // Sort by time (newest first)
    requests.sort((a, b) {
      final aTime = a.requestedAt.split(':');
      final bTime = b.requestedAt.split(':');
      final aMinutes = int.parse(aTime[0]) * 60 + int.parse(aTime[1]);
      final bMinutes = int.parse(bTime[0]) * 60 + int.parse(bTime[1]);
      return bMinutes.compareTo(aMinutes);
    });
    
    return requests;
  }

  static List<RequestModel> getRequestsForYou() {
    // Generate 2-3 requests specifically assigned to the collector
    final List<RequestModel> personalRequests = [];
    
    final assignedNames = [
      'Pak Rahman Hidayat',
      'Bu Siti Aminah', 
      'Bapak Kusno',
    ];
    
    final assignedAreas = [
      'Jl. Veteran No. 45, Kel. Penanggungan',
      'Jl. Soekarno Hatta 123, Kel. Mojolangu', 
      'Jl. Ahmad Yani 67, Kel. Rampal Celaket',
    ];
    
    for (int i = 0; i < 3; i++) {
      final trashItems = [
        [
          TrashItem(name: 'Botol Kaca', weight: 12.5),
          TrashItem(name: 'Kardus Besar', weight: 18.0),
        ],
        [
          TrashItem(name: 'Kertas Koran', weight: 8.5),
          TrashItem(name: 'Plastik Kemasan', weight: 6.2),
          TrashItem(name: 'Kaleng Bekas', weight: 4.8),
        ],
        [
          TrashItem(name: 'Galon Bekas', weight: 15.5),
          TrashItem(name: 'Jerigen Plastik', weight: 22.0),
        ],
      ];
      
      final times = ['08:30', '10:15', '14:45'];
      final phones = ['628123456789', '628234567890', '628345678901'];
      final distances = [2.3, 1.8, 4.1];
      
      personalRequests.add(RequestModel(
        id: 'req_personal_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: assignedNames[i],
        phone: phones[i],
        trashItems: trashItems[i],
        address: assignedAreas[i],
        distanceFromYou: distances[i],
        requestedAt: times[i],
        status: i == 0 ? RequestStatus.pending : (i == 1 ? RequestStatus.accepted : RequestStatus.pending),
        imageUrl: i % 2 == 0 ? 'https://via.placeholder.com/150x150/4CAF50/ffffff?text=Sampah+Prioritas' : null,
      ));
    }
    
    return personalRequests;
  }

  static RequestModel getMyRequest() {
    // Single request example for current user context
    return RequestModel(
      id: 'req_current_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Ibu Kartini Sari',
      phone: '6281234567890',
      trashItems: [
        TrashItem(name: 'Botol Plastik', weight: 8.5),
        TrashItem(name: 'Kardus', weight: 12.0),
        TrashItem(name: 'Kertas Bekas', weight: 6.5),
      ],
      address: 'Jl. Merdeka No. 17, Kel. Oro-oro Dowo',
      distanceFromYou: 1.2,
      requestedAt: '09:45',
      status: RequestStatus.accepted,
      imageUrl: 'https://via.placeholder.com/150x150/2196F3/ffffff?text=Sampah+Saya',
    );
  }

  // Helper method untuk mendapatkan requests berdasarkan type
  static List<RequestModel> getRequestsByType(RequestType type) {
    switch (type) {
      case RequestType.all:
        return getAllRequests();
      case RequestType.toYou:
        return getRequestsForYou();
    }
  }

  // Helper method untuk mendapatkan count berdasarkan type
  static int getRequestCount(RequestType type) {
    return getRequestsByType(type).length;
  }

  // Helper method untuk mendapatkan pending requests count
  static int getPendingRequestsCount(RequestType type) {
    return getRequestsByType(type)
        .where((request) => request.status == RequestStatus.pending)
        .length;
  }

  // Helper method untuk mendapatkan today's statistics
  static Map<String, int> getTodayStatistics() {
    final allRequests = getAllRequests();
    
    return {
      'total': allRequests.length,
      'pending': allRequests.where((r) => r.status == RequestStatus.pending).length,
      'accepted': allRequests.where((r) => r.status == RequestStatus.accepted).length,
      'completed': allRequests.where((r) => r.status == RequestStatus.completed).length,
      'cancelled': allRequests.where((r) => r.status == RequestStatus.cancelled).length,
    };
  }

  // Helper method untuk simulate data updates
  static void refreshData() {
    // Simulate data refresh - dalam implementasi real, ini akan call API
    // Untuk mock, kita bisa regenerate data atau update timestamp
  }
}