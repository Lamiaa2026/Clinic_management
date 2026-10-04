class Doctor {
  final String id;
  final String name;
  final String title; // e.g. استشاري أول / أخصائي
  final String specialty; // e.g. طب وجراحة العيون، طب الأطفال، الأمراض الباطنية
  final String roomNumber; // e.g. عيادة 101
  final double consultationFee; // سعر الكشف
  final double followUpFee; // سعر الاستشارة
  final String phone;
  final List<String> availableDays; // e.g. ['السبت', 'الأحد', 'الثلاثاء']
  final String workingHours; // e.g. 05:00 م - 10:00 م
  final int avatarColorValue;
  final double rating;
  final bool isAvailableToday;

  Doctor({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.roomNumber,
    required this.consultationFee,
    this.followUpFee = 0.0,
    required this.phone,
    required this.availableDays,
    required this.workingHours,
    this.avatarColorValue = 0xFF0F766E,
    this.rating = 4.9,
    this.isAvailableToday = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'specialty': specialty,
      'roomNumber': roomNumber,
      'consultationFee': consultationFee,
      'followUpFee': followUpFee,
      'phone': phone,
      'availableDays': availableDays,
      'workingHours': workingHours,
      'avatarColorValue': avatarColorValue,
      'rating': rating,
      'isAvailableToday': isAvailableToday,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      title: map['title'] ?? 'طبيب أخصائي',
      specialty: map['specialty'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? 0.0,
      followUpFee: (map['followUpFee'] as num?)?.toDouble() ?? 0.0,
      phone: map['phone'] ?? '',
      availableDays: List<String>.from(map['availableDays'] ?? []),
      workingHours: map['workingHours'] ?? '',
      avatarColorValue: map['avatarColorValue'] ?? 0xFF0F766E,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      isAvailableToday: map['isAvailableToday'] ?? true,
    );
  }
}
