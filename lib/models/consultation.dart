import 'vital_signs.dart';
import 'prescription.dart';

class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime date;
  final String chiefComplaint; // الشكوى الرئيسية
  final String diagnosis; // التشخيص
  final String? clinicalExamination; // الفحص السريري
  final VitalSigns? vitals; // العلامات الحيوية
  final Prescription? prescription; // الوصفة الطبية
  final List<String> labTestsRequested; // التحاليل والأشعة المطلوبة
  final String? notes; // ملاحظات وتوصيات
  final DateTime? followUpDate; // موعد الاستشارة / الإعادة

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.chiefComplaint,
    required this.diagnosis,
    this.clinicalExamination,
    this.vitals,
    this.prescription,
    this.labTestsRequested = const [],
    this.notes,
    this.followUpDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': date.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'diagnosis': diagnosis,
      'clinicalExamination': clinicalExamination,
      'vitals': vitals?.toMap(),
      'prescription': prescription?.toMap(),
      'labTestsRequested': labTestsRequested,
      'notes': notes,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      chiefComplaint: map['chiefComplaint'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      clinicalExamination: map['clinicalExamination'],
      vitals: map['vitals'] != null ? VitalSigns.fromMap(map['vitals']) : null,
      prescription: map['prescription'] != null
          ? Prescription.fromMap(map['prescription'])
          : null,
      labTestsRequested: List<String>.from(map['labTestsRequested'] ?? []),
      notes: map['notes'],
      followUpDate: map['followUpDate'] != null
          ? DateTime.parse(map['followUpDate'])
          : null,
    );
  }
}
