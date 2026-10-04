class VitalSigns {
  final String? systolicBp; // الانقباضي e.g. 120
  final String? diastolicBp; // الانبساطي e.g. 80
  final String? pulse; // نبضات القلب e.g. 72 bpm
  final String? temperature; // درجة الحرارة e.g. 37.0 C
  final String? bloodSugar; // سكر الدم e.g. 110 mg/dL
  final String? weight; // الوزن e.g. 75 kg
  final String? height; // الطول e.g. 175 cm
  final String? spO2; // نسبة الأكسجين e.g. 98%
  final DateTime recordedAt;

  VitalSigns({
    this.systolicBp,
    this.diastolicBp,
    this.pulse,
    this.temperature,
    this.bloodSugar,
    this.weight,
    this.height,
    this.spO2,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  String get bloodPressure =>
      (systolicBp != null && diastolicBp != null)
          ? '$systolicBp/$diastolicBp'
          : '-';

  double? get bmi {
    if (weight == null || height == null) return null;
    final w = double.tryParse(weight!);
    final h = double.tryParse(height!);
    if (w == null || h == null || h <= 0) return null;
    final heightInMeters = h / 100;
    return w / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> toMap() {
    return {
      'systolicBp': systolicBp,
      'diastolicBp': diastolicBp,
      'pulse': pulse,
      'temperature': temperature,
      'bloodSugar': bloodSugar,
      'weight': weight,
      'height': height,
      'spO2': spO2,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory VitalSigns.fromMap(Map<String, dynamic> map) {
    return VitalSigns(
      systolicBp: map['systolicBp'],
      diastolicBp: map['diastolicBp'],
      pulse: map['pulse'],
      temperature: map['temperature'],
      bloodSugar: map['bloodSugar'],
      weight: map['weight'],
      height: map['height'],
      spO2: map['spO2'],
      recordedAt: map['recordedAt'] != null
          ? DateTime.parse(map['recordedAt'])
          : DateTime.now(),
    );
  }
}
