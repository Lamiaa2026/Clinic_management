enum VisitType {
  newVisit,
  followUp,
  emergency;

  String get title {
    switch (this) {
      case VisitType.newVisit:
        return 'كشف جديد';
      case VisitType.followUp:
        return 'استشارة / إعادة';
      case VisitType.emergency:
        return 'حالة طارئة';
    }
  }
}

enum AppointmentStatus {
  waiting,
  inConsultation,
  completed,
  cancelled,
  noShow;

  String get title {
    switch (this) {
      case AppointmentStatus.waiting:
        return 'في الانتظار';
      case AppointmentStatus.inConsultation:
        return 'داخل الكشف';
      case AppointmentStatus.completed:
        return 'تم الكشف';
      case AppointmentStatus.cancelled:
        return 'ملغي';
      case AppointmentStatus.noShow:
        return 'لم يحضر';
    }
  }
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final int tokenNumber;
  final VisitType visitType;
  final AppointmentStatus status;
  final double fee;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.tokenNumber,
    this.visitType = VisitType.newVisit,
    this.status = AppointmentStatus.waiting,
    required this.fee,
    this.isPaid = true,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Appointment copyWith({
    String? patientName,
    String? patientPhone,
    String? doctorId,
    String? doctorName,
    String? specialty,
    DateTime? dateTime,
    int? tokenNumber,
    VisitType? visitType,
    AppointmentStatus? status,
    double? fee,
    bool? isPaid,
    String? notes,
  }) {
    return Appointment(
      id: id,
      patientId: patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      dateTime: dateTime ?? this.dateTime,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      visitType: visitType ?? this.visitType,
      status: status ?? this.status,
      fee: fee ?? this.fee,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': dateTime.toIso8601String(),
      'tokenNumber': tokenNumber,
      'visitType': visitType.name,
      'status': status.name,
      'fee': fee,
      'isPaid': isPaid,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      specialty: map['specialty'] ?? '',
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'])
          : DateTime.now(),
      tokenNumber: map['tokenNumber'] ?? 1,
      visitType: VisitType.values.firstWhere(
        (e) => e.name == map['visitType'],
        orElse: () => VisitType.newVisit,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.waiting,
      ),
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      isPaid: map['isPaid'] ?? true,
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
