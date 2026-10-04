import 'consultation.dart';

enum Gender { male, female }

class Patient {
  final String id;
  final String patientCode; // e.g. PAT-1002
  final String name;
  final int age;
  final Gender gender;
  final String phone;
  final String? nationalId;
  final String? bloodGroup; // e.g. A+, O+, B-
  final List<String> chronicDiseases; // أمراض مزمنة: سكري، ضغط، ربو
  final List<String> allergies; // حساسية: البنسلين، الأسبرين
  final String? notes;
  final DateTime registeredAt;
  final List<Consultation> medicalHistory;

  Patient({
    required this.id,
    required this.patientCode,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.nationalId,
    this.bloodGroup,
    this.chronicDiseases = const [],
    this.allergies = const [],
    this.notes,
    DateTime? registeredAt,
    this.medicalHistory = const [],
  }) : registeredAt = registeredAt ?? DateTime.now();

  String get genderText => gender == Gender.male ? 'ذكر' : 'أنثى';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientCode': patientCode,
      'name': name,
      'age': age,
      'gender': gender.name,
      'phone': phone,
      'nationalId': nationalId,
      'bloodGroup': bloodGroup,
      'chronicDiseases': chronicDiseases,
      'allergies': allergies,
      'notes': notes,
      'registeredAt': registeredAt.toIso8601String(),
      'medicalHistory': medicalHistory.map((m) => m.toMap()).toList(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      patientCode: map['patientCode'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] == 'female' ? Gender.female : Gender.male,
      phone: map['phone'] ?? '',
      nationalId: map['nationalId'],
      bloodGroup: map['bloodGroup'],
      chronicDiseases: List<String>.from(map['chronicDiseases'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      notes: map['notes'],
      registeredAt: map['registeredAt'] != null
          ? DateTime.parse(map['registeredAt'])
          : DateTime.now(),
      medicalHistory: (map['medicalHistory'] as List<dynamic>?)
              ?.map((m) => Consultation.fromMap(m))
              .toList() ??
          [],
    );
  }

  Patient copyWith({
    String? name,
    int? age,
    Gender? gender,
    String? phone,
    String? nationalId,
    String? bloodGroup,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? notes,
    List<Consultation>? medicalHistory,
  }) {
    return Patient(
      id: id,
      patientCode: patientCode,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      registeredAt: registeredAt,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }
}
