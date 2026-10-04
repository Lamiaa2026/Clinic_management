import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/patient.dart';
import '../../models/vital_signs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/vital_card.dart';
import '../appointments/book_appointment_dialog.dart';
import '../doctor_room/doctor_consultation_screen.dart';
import '../doctor_room/prescription_preview_dialog.dart';
import 'add_edit_patient_dialog.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinic = Provider.of<ClinicProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final patient = clinic.getPatientById(widget.patientId);

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الملف الطبي')),
        body: const Center(child: Text('لم يتم العثور على ملف المريض')),
      );
    }

    final latestVitals = patient.medicalHistory.isNotEmpty ? patient.medicalHistory.first.vitals : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الطبي - ${patient.name}'),
        actions: [
          IconButton(
            tooltip: 'تعديل البيانات',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddEditPatientDialog(patientToEdit: patient),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Patient Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primarySubtle,
                      child: Text(
                        patient.name.characters.first,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                                patient.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  patient.patientCode,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 16,
                            runSpacing: 6,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(patient.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cake_outlined, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text('${patient.age} سنة (${patient.genderText})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                              if (patient.bloodGroup != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bloodtype_outlined, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text('فصيلة الدم: ${patient.bloodGroup}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              if (patient.nationalId != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.badge_outlined, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('الرقم القومي: ${patient.nationalId}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  ],
                                ),
                            ],
                          ),
                          if (patient.chronicDiseases.isNotEmpty || patient.allergies.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ...patient.chronicDiseases.map(
                                  (c) => Chip(
                                    avatar: const Icon(Icons.favorite, size: 14, color: AppColors.primary),
                                    label: Text('مزمن: $c', style: const TextStyle(fontSize: 11)),
                                    backgroundColor: AppColors.primarySubtle,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                ...patient.allergies.map(
                                  (a) => Chip(
                                    avatar: const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.deepOrange),
                                    label: Text('حساسية: $a', style: const TextStyle(fontSize: 11, color: Colors.deepOrange)),
                                    backgroundColor: Colors.orange.shade50,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Action Buttons
                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('حجز موعد'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => BookAppointmentDialog(preselectedPatient: patient),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.medical_services_outlined, size: 18),
                          label: const Text('كشف سريري فوري'),
                          onPressed: () {
                            final doctor = auth.currentDoctor ?? clinic.doctors.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorConsultationScreen(
                                  patient: patient,
                                  doctor: doctor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. Navigation Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(
                  icon: const Icon(Icons.history_edu_rounded),
                  text: 'سجل الزيارات والتشخيصات (${patient.medicalHistory.length})',
                ),
                const Tab(
                  icon: Icon(Icons.monitor_heart_outlined),
                  text: 'العلامات الحيوية والمؤشرات',
                ),
                const Tab(
                  icon: Icon(Icons.receipt_long_rounded),
                  text: 'أرشيف الروشتات والعلاجات',
                ),
              ],
            ),
          ),

          // 3. Tab Views Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Medical Visits Timeline
                _buildVisitsTimeline(context, patient),

                // Tab 2: Vitals History & Latest
                _buildVitalsHistory(context, patient, latestVitals),

                // Tab 3: Prescriptions Archive
                _buildPrescriptionsArchive(context, patient),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTimeline(BuildContext context, Patient patient) {
    if (patient.medicalHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد كشوفات سابقة مسجلة لهذا المريض',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك بدء كشف طبي جديد لتسجيل التشخيص والأدوية',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: patient.medicalHistory.length,
      itemBuilder: (context, index) {
        final visit = patient.medicalHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Visit Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.medical_services_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit.doctorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              visit.doctorSpecialty,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        Formatters.formatDateArabic(visit.date),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Chief Complaint
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الشكوى: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                    Expanded(
                      child: Text(visit.chiefComplaint, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Diagnosis
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 18, color: AppColors.primaryDark),
                      const SizedBox(width: 8),
                      const Text('التشخيص: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
                      Expanded(
                        child: Text(
                          visit.diagnosis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),

                // Clinical Examination if exists
                if (visit.clinicalExamination != null) ...[
                  const SizedBox(height: 8),
                  Text('الفحص السريري: ${visit.clinicalExamination!}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],

                // Vitals Snapshot
                if (visit.vitals != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (visit.vitals!.systolicBp != null)
                        _vitalBadge('الضغط: ${visit.vitals!.bloodPressure} mmHg', Icons.speed, AppColors.bpColor),
                      if (visit.vitals!.pulse != null)
                        _vitalBadge('النبض: ${visit.vitals!.pulse} bpm', Icons.favorite, AppColors.pulseColor),
                      if (visit.vitals!.temperature != null)
                        _vitalBadge('الحرارة: ${visit.vitals!.temperature} °C', Icons.thermostat, AppColors.tempColor),
                      if (visit.vitals!.bloodSugar != null)
                        _vitalBadge('السكر: ${visit.vitals!.bloodSugar} mg/dL', Icons.water_drop, AppColors.sugarColor),
                    ],
                  ),
                ],

                // Prescription & Lab Tests Footer
                if (visit.prescription != null || visit.labTestsRequested.isNotEmpty) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (visit.prescription != null)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.receipt_long_rounded, size: 16),
                          label: Text('معاينة الروشتة (${visit.prescription!.items.length} أدوية)'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => PrescriptionPreviewDialog(
                                prescription: visit.prescription!,
                                labTests: visit.labTestsRequested,
                              ),
                            );
                          },
                        )
                      else
                        const SizedBox.shrink(),
                      if (visit.followUpDate != null)
                        Text(
                          'موعد الإعادة: ${Formatters.formatDate(visit.followUpDate!)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVitalsHistory(BuildContext context, Patient patient, VitalSigns? latest) {
    if (latest == null) {
      return const Center(child: Text('لا توجد قياسات حيوية مسجلة بعد'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'آخر المؤشرات الحيوية المسجلة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.3,
            children: [
              VitalCard(
                label: 'ضغط الدم',
                value: latest.bloodPressure,
                unit: 'mmHg',
                icon: Icons.speed,
                color: AppColors.bpColor,
              ),
              VitalCard(
                label: 'نبضات القلب',
                value: latest.pulse ?? '-',
                unit: 'bpm',
                icon: Icons.favorite,
                color: AppColors.pulseColor,
              ),
              VitalCard(
                label: 'درجة الحرارة',
                value: latest.temperature ?? '-',
                unit: '°C',
                icon: Icons.thermostat,
                color: AppColors.tempColor,
              ),
              VitalCard(
                label: 'سكر الدم',
                value: latest.bloodSugar ?? '-',
                unit: 'mg/dL',
                icon: Icons.water_drop,
                color: AppColors.sugarColor,
              ),
              VitalCard(
                label: 'الوزن',
                value: latest.weight ?? '-',
                unit: 'kg',
                icon: Icons.scale,
                color: AppColors.weightColor,
              ),
              VitalCard(
                label: 'نسبة الأكسجين SpO2',
                value: latest.spO2 ?? '-',
                unit: '%',
                icon: Icons.air,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'سجل القياسات عبر الزيارات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('تاريخ الزيارة', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('الضغط', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('النبض', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('السكر', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('الحرارة', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('الوزن', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: patient.medicalHistory
                  .where((c) => c.vitals != null)
                  .map((c) {
                final v = c.vitals!;
                return DataRow(
                  cells: [
                    DataCell(Text(Formatters.formatDate(c.date))),
                    DataCell(Text(v.bloodPressure)),
                    DataCell(Text(v.pulse ?? '-')),
                    DataCell(Text(v.bloodSugar ?? '-')),
                    DataCell(Text(v.temperature ?? '-')),
                    DataCell(Text(v.weight ?? '-')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsArchive(BuildContext context, Patient patient) {
    final rxList = patient.medicalHistory.where((c) => c.prescription != null).map((c) => c.prescription!).toList();

    if (rxList.isEmpty) {
      return const Center(child: Text('لا توجد روشتات مسجلة في الأرشيف'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: rxList.length,
      itemBuilder: (context, index) {
        final rx = rxList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: AppColors.primarySubtle,
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            ),
            title: Text(
              'روشتة بواسطة: ${rx.doctorName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${Formatters.formatDateArabic(rx.date)} • ${rx.items.length} أصناف دوائية',
            ),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.print, size: 16),
              label: const Text('معاينة وطباعة'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => PrescriptionPreviewDialog(prescription: rx),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _vitalBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
