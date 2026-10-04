class PrescriptionItem {
  final String medicineName;
  final String dosage; // e.g. 500mg, 1 قرص
  final String frequency; // e.g. 3 مرات يومياً بعد الأكل
  final String duration; // e.g. لمدة 5 أيام
  final String? instructions; // e.g. مع شرب كميات كافية من الماء

  PrescriptionItem({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }

  factory PrescriptionItem.fromMap(Map<String, dynamic> map) {
    return PrescriptionItem(
      medicineName: map['medicineName'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      instructions: map['instructions'],
    );
  }
}

class Prescription {
  final String id;
  final String doctorName;
  final String doctorSpecialty;
  final String patientName;
  final DateTime date;
  final List<PrescriptionItem> items;
  final String? notes;

  Prescription({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientName,
    required this.date,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'notes': notes,
    };
  }

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'] ?? '',
      patientName: map['patientName'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => PrescriptionItem.fromMap(i))
              .toList() ??
          [],
      notes: map['notes'],
    );
  }
}
