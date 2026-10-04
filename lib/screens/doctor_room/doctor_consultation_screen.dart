import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../models/consultation.dart';
import '../../models/doctor.dart';
import '../../models/patient.dart';
import '../../models/prescription.dart';
import '../../models/vital_signs.dart';
import '../../providers/clinic_provider.dart';
import 'prescription_preview_dialog.dart';

class DoctorConsultationScreen extends StatefulWidget {
  final Patient patient;
  final Doctor doctor;
  final Appointment? appointment;

  const DoctorConsultationScreen({
    super.key,
    required this.patient,
    required this.doctor,
    this.appointment,
  });

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _chiefComplaintController = TextEditingController();
  final _clinicalExamController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  // Vitals Controllers
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _tempController = TextEditingController();
  final _sugarController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _spO2Controller = TextEditingController();

  // Prescription Items
  final List<PrescriptionItem> _prescriptionItems = [];
  final _medNameController = TextEditingController();
  final _medDosageController = TextEditingController();
  final _medFreqController = TextEditingController();
  final _medDurationController = TextEditingController();
  final _medInstructionsController = TextEditingController();

  // Lab Tests
  final List<String> _selectedLabTests = [];
  final _customLabTestController = TextEditingController();

  DateTime? _followUpDate;

  final List<String> _commonLabTests = [
    'تحليل صورة دم كاملة CBC',
    'تحليل سكر صائم وفاطر FBS/PP',
    'تحليل سكر تراكمي HbA1c',
    'وظائف كبد ورقية SGPT/SGOT',
    'وظائف كلى Serum Creatinine',
    'تحليل دهون ثلاثية وكوليسترول Lipid Profile',
    'فحص بول كامل Urine Analysis',
    'أشعة سينية عادية X-Ray',
    'سونار على البطن والحوض Abdominal US',
    'رسم قلب كهربائي ECG',
  ];

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _clinicalExamController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();

    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _sugarController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _spO2Controller.dispose();

    _medNameController.dispose();
    _medDosageController.dispose();
    _medFreqController.dispose();
    _medDurationController.dispose();
    _medInstructionsController.dispose();
    _customLabTestController.dispose();
    super.dispose();
  }

  void _addMedication() {
    final name = _medNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة اسم الدواء')),
      );
      return;
    }

    setState(() {
      _prescriptionItems.add(
        PrescriptionItem(
          medicineName: name,
          dosage: _medDosageController.text.trim().isNotEmpty
              ? _medDosageController.text.trim()
              : 'قرص واحد',
          frequency: _medFreqController.text.trim().isNotEmpty
              ? _medFreqController.text.trim()
              : 'مرتين يومياً',
          duration: _medDurationController.text.trim().isNotEmpty
              ? _medDurationController.text.trim()
              : 'لمدة أسبوع',
          instructions: _medInstructionsController.text.trim().isNotEmpty
              ? _medInstructionsController.text.trim()
              : null,
        ),
      );
      _medNameController.clear();
      _medDosageController.clear();
      _medFreqController.clear();
      _medDurationController.clear();
      _medInstructionsController.clear();
    });
  }

  void _addCustomLabTest() {
    final text = _customLabTestController.text.trim();
    if (text.isNotEmpty && !_selectedLabTests.contains(text)) {
      setState(() {
        _selectedLabTests.add(text);
        _customLabTestController.clear();
      });
    }
  }

  void _saveConsultation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vitals = VitalSigns(
      systolicBp: _systolicController.text.trim().isNotEmpty ? _systolicController.text.trim() : null,
      diastolicBp: _diastolicController.text.trim().isNotEmpty ? _diastolicController.text.trim() : null,
      pulse: _pulseController.text.trim().isNotEmpty ? _pulseController.text.trim() : null,
      temperature: _tempController.text.trim().isNotEmpty ? _tempController.text.trim() : null,
      bloodSugar: _sugarController.text.trim().isNotEmpty ? _sugarController.text.trim() : null,
      weight: _weightController.text.trim().isNotEmpty ? _weightController.text.trim() : null,
      height: _heightController.text.trim().isNotEmpty ? _heightController.text.trim() : null,
      spO2: _spO2Controller.text.trim().isNotEmpty ? _spO2Controller.text.trim() : null,
    );

    Prescription? rx;
    if (_prescriptionItems.isNotEmpty) {
      rx = Prescription(
        id: const Uuid().v4().substring(0, 8),
        doctorName: widget.doctor.name,
        doctorSpecialty: widget.doctor.specialty,
        patientName: widget.patient.name,
        date: DateTime.now(),
        items: List.from(_prescriptionItems),
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
    }

    final consultation = Consultation(
      id: 'cons_${const Uuid().v4().substring(0, 8)}',
      patientId: widget.patient.id,
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.name,
      doctorSpecialty: widget.doctor.specialty,
      date: DateTime.now(),
      chiefComplaint: _chiefComplaintController.text.trim(),
      clinicalExamination: _clinicalExamController.text.trim().isNotEmpty ? _clinicalExamController.text.trim() : null,
      diagnosis: _diagnosisController.text.trim(),
      vitals: vitals,
      prescription: rx,
      labTestsRequested: _selectedLabTests,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      followUpDate: _followUpDate,
    );

    final clinic = Provider.of<ClinicProvider>(context, listen: false);
    clinic.recordConsultation(
      patientId: widget.patient.id,
      consultation: consultation,
      appointmentId: widget.appointment?.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل وحفظ الكشف الطبي للمريض ${widget.patient.name} بنجاح'),
        backgroundColor: AppColors.completed,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('غرفة الكشف الطبي - ${widget.doctor.name}'),
        actions: [
          if (_prescriptionItems.isNotEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('معاينة الروشتة'),
              onPressed: () {
                final previewRx = Prescription(
                  id: 'PREVIEW',
                  doctorName: widget.doctor.name,
                  doctorSpecialty: widget.doctor.specialty,
                  patientName: widget.patient.name,
                  date: DateTime.now(),
                  items: _prescriptionItems,
                );
                showDialog(
                  context: context,
                  builder: (_) => PrescriptionPreviewDialog(
                    prescription: previewRx,
                    labTests: _selectedLabTests,
                  ),
                );
              },
            ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('حفظ وإنهاء الكشف'),
            onPressed: _saveConsultation,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Patient Quick Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primarySubtle,
                      child: Text(
                        widget.patient.name.characters.first,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.patient.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.patient.patientCode,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'العمر: ${widget.patient.age} سنة  •  النوع: ${widget.patient.genderText}  •  فصيلة الدم: ${widget.patient.bloodGroup ?? "-"}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          if (widget.patient.chronicDiseases.isNotEmpty || widget.patient.allergies.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                ...widget.patient.chronicDiseases.map(
                                  (c) => Chip(
                                    label: Text('مزمن: $c', style: const TextStyle(fontSize: 11)),
                                    backgroundColor: AppColors.primarySubtle,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                ...widget.patient.allergies.map(
                                  (a) => Chip(
                                    label: Text('حساسية: $a', style: const TextStyle(fontSize: 11, color: Colors.deepOrange)),
                                    backgroundColor: Colors.orange.shade50,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.appointment != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('رقم الدور', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                            Text(
                              '#${widget.appointment!.tokenNumber}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Chief Complaint & Clinical Examination
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.speaker_notes_outlined, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'الشكوى الحالية والفحص السريري (History & Physical Exam)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('الشكوى الرئيسية (Chief Complaint) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _chiefComplaintController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'وصف الأعراض التي يشتكي منها المريض ومدة ظهورها...',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى تسجيل شكوى المريض' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('نتائج الفحص السريري (Clinical Examination)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _clinicalExamController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'ملاحظات الفحص الطبي (فحص الصدر، البطن، الحلق، المفاصل...)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Vital Signs Recording Grid
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.monitor_heart_outlined, color: AppColors.bpColor),
                          SizedBox(width: 8),
                          Text(
                            'العلامات الحيوية أثناء الزيارة (Vital Signs)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width > 800 ? 4 : (width > 500 ? 2 : 1);
                          return GridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                            children: [
                              TextFormField(
                                controller: _systolicController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'الضغط الانقباضي (Systolic)',
                                  hintText: '120',
                                  suffixText: 'mmHg',
                                  prefixIcon: Icon(Icons.speed, color: AppColors.bpColor),
                                ),
                              ),
                              TextFormField(
                                controller: _diastolicController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'الضغط الانبساطي (Diastolic)',
                                  hintText: '80',
                                  suffixText: 'mmHg',
                                  prefixIcon: Icon(Icons.speed, color: AppColors.bpColor),
                                ),
                              ),
                              TextFormField(
                                controller: _pulseController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'نبضات القلب (Pulse)',
                                  hintText: '72',
                                  suffixText: 'bpm',
                                  prefixIcon: Icon(Icons.favorite, color: AppColors.pulseColor),
                                ),
                              ),
                              TextFormField(
                                controller: _tempController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'درجة الحرارة (Temp)',
                                  hintText: '37.0',
                                  suffixText: '°C',
                                  prefixIcon: Icon(Icons.thermostat, color: AppColors.tempColor),
                                ),
                              ),
                              TextFormField(
                                controller: _sugarController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'سكر الدم (Blood Sugar)',
                                  hintText: '110',
                                  suffixText: 'mg/dL',
                                  prefixIcon: Icon(Icons.water_drop, color: AppColors.sugarColor),
                                ),
                              ),
                              TextFormField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'الوزن (Weight)',
                                  hintText: '75',
                                  suffixText: 'kg',
                                  prefixIcon: Icon(Icons.scale, color: AppColors.weightColor),
                                ),
                              ),
                              TextFormField(
                                controller: _heightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'الطول (Height)',
                                  hintText: '175',
                                  suffixText: 'cm',
                                  prefixIcon: Icon(Icons.height, color: AppColors.weightColor),
                                ),
                              ),
                              TextFormField(
                                controller: _spO2Controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'نسبة الأكسجين (SpO2)',
                                  hintText: '98',
                                  suffixText: '%',
                                  prefixIcon: Icon(Icons.air, color: AppColors.secondary),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Diagnosis
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_user_outlined, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'التشخيص النهائي (Medical Diagnosis) *',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: const InputDecoration(
                          hintText: 'اكتب التشخيص الطبي للحالة...',
                          prefixIcon: Icon(Icons.medical_information_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال التشخيص الطبي' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Electronic Prescription Builder
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.medication_liquid_outlined, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'الوصفة الطبية والعلاج (E-Prescription)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            'عدد الأدوية: ${_prescriptionItems.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Add Medication Inputs
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _medNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'اسم الدواء التجاري / العلمي *',
                                      hintText: 'مثال: Panadol Extra',
                                      prefixIcon: Icon(Icons.medication),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _medDosageController,
                                    decoration: const InputDecoration(
                                      labelText: 'الجرعة والشكل',
                                      hintText: '500mg / قرص واحد',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _medFreqController,
                                    decoration: const InputDecoration(
                                      labelText: 'التكرار والميعاد',
                                      hintText: '3 مرات يومياً بعد الأكل',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _medDurationController,
                                    decoration: const InputDecoration(
                                      labelText: 'مدة العلاج',
                                      hintText: 'لمدة أسبوع',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _medInstructionsController,
                                    decoration: const InputDecoration(
                                      labelText: 'تعليمات خاصة بالدواء',
                                      hintText: 'مثال: مع شرب كميات كافية من الماء',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add_circle_outline, size: 18),
                                  label: const Text('إضافة الدواء'),
                                  onPressed: _addMedication,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // List of Added Medications
                      if (_prescriptionItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _prescriptionItems.length,
                          itemBuilder: (context, index) {
                            final item = _prescriptionItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.primarySubtle,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.medicineName} (${item.dosage})',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          '${item.frequency}  •  ${item.duration}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        if (item.instructions != null)
                                          Text(
                                            'ملاحظة: ${item.instructions}',
                                            style: const TextStyle(fontSize: 11, color: Colors.orange),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.cancelled, size: 20),
                                    onPressed: () => setState(() => _prescriptionItems.removeAt(index)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 6. Lab Tests & Investigations
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.biotech_outlined, color: AppColors.secondary),
                          SizedBox(width: 8),
                          Text(
                            'طلب التحاليل والفحوصات الطبية (Lab & Radiology Requests)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _commonLabTests.map((test) {
                          final isSelected = _selectedLabTests.contains(test);
                          return FilterChip(
                            label: Text(test, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
                            selected: isSelected,
                            selectedColor: AppColors.secondary,
                            checkmarkColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedLabTests.add(test);
                                } else {
                                  _selectedLabTests.remove(test);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customLabTestController,
                              decoration: const InputDecoration(
                                hintText: 'إضافة تحليل أو أشعة أخرى غير موجودة بالقائمة...',
                                prefixIcon: Icon(Icons.add_task),
                              ),
                              onSubmitted: (_) => _addCustomLabTest(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addCustomLabTest,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(backgroundColor: AppColors.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 7. Follow-up Date & Clinical Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.event_repeat_rounded, color: AppColors.accent),
                          SizedBox(width: 8),
                          Text(
                            'موعد الاستشارة والملاحظات العامة (Follow-up & Notes)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('تحديد موعد الاستشارة / الإعادة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today_rounded, size: 16),
                            label: Text(
                              _followUpDate != null
                                  ? Formatters.formatDateArabic(_followUpDate!)
                                  : 'اختر الموعد (بعد أسبوعين مثلاً)',
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 14)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 180)),
                              );
                              if (picked != null) {
                                setState(() => _followUpDate = picked);
                              }
                            },
                          ),
                          if (_followUpDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _followUpDate = null),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'ملاحظات وتوصيات للمريض',
                          hintText: 'توجيهات غذائية، إرشادات دوائية، أو خطة علاجية طويلة الأمد...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Confirmation Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                  label: const Text('حفظ وتسجيل الكشف وإنهاء الزيارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _saveConsultation,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
