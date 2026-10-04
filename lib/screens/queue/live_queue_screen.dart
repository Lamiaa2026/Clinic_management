import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../doctor_room/doctor_consultation_screen.dart';
import '../patients/patient_detail_screen.dart';

class LiveQueueScreen extends StatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> {
  String? _selectedDoctorId;

  @override
  Widget build(BuildContext context) {
    final clinic = Provider.of<ClinicProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // If doctor view, enforce doctor filter
    final activeDoctorId = auth.isDoctorView ? auth.currentDoctor?.id : _selectedDoctorId;
    final queue = clinic.getTodayQueue(doctorId: activeDoctorId);
    final currentInConsultation = queue.where((a) => a.status == AppointmentStatus.inConsultation).toList();
    final waitingList = queue.where((a) => a.status == AppointmentStatus.waiting).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar & Doctor Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.hourglass_top_rounded, color: AppColors.waiting, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'شاشة قائمة الانتظار الحية (Waiting Room)',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'متابعة لحظية لحركة المرضى داخل العيادات وتنظيم أدوار الكشف',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (!auth.isDoctorView)
                  Container(
                    width: 260,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedDoctorId,
                        isExpanded: true,
                        hint: const Text('جميع الأطباء والعيادات'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('جميع الأطباء والعيادات'),
                          ),
                          ...clinic.doctors.map(
                            (d) => DropdownMenuItem<String?>(
                              value: d.id,
                              child: Text('${d.name} (${d.roomNumber})'),
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => _selectedDoctorId = val),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Status Overview Cards
            Row(
              children: [
                // 1. Current In Consultation Banner
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.inProgressBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.inProgress.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AppColors.inProgress,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'المرضى داخل الكشف الآن',
                                style: TextStyle(fontSize: 13, color: AppColors.inProgress, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currentInConsultation.length} مريض',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Waiting In Line Banner
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.waitingBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.waiting.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AppColors.waiting,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_outline_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'في انتظار الدخول (قيد الانتظار)',
                                style: TextStyle(fontSize: 13, color: Colors.brown, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${waitingList.length} مريض',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Main Queue Section
            if (queue.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: EmptyStateWidget(
                  icon: Icons.hourglass_empty_rounded,
                  title: 'لا يوجد أي مريض في قائمة الانتظار حالياً',
                  subtitle: 'يمكنك إضافة حجز جديد أو تغيير فلتر الطبيب المحدد',
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المرضى في صالة الانتظار حسب الدور',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final appt = queue[index];
                      final isInConsultation = appt.status == AppointmentStatus.inConsultation;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isInConsultation ? AppColors.inProgressBg.withValues(alpha: 0.4) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isInConsultation ? AppColors.inProgress : AppColors.cardBorder,
                            width: isInConsultation ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Big Token Number Badge
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: isInConsultation ? AppColors.inProgress : AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('دور', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                  Text(
                                    '#${appt.tokenNumber}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Patient and Doctor Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PatientDetailScreen(patientId: appt.patientId),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          appt.patientName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      VisitTypeBadge(type: appt.visitType),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'الهاتف: ${appt.patientPhone}  •  الطبيب: ${appt.doctorName} (${appt.specialty})  •  الموعد: ${Formatters.formatTime(appt.dateTime)}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                  if (appt.notes != null) ...[
                                    const SizedBox(height: 4),
                                    Text('ملاحظات: ${appt.notes}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ],
                              ),
                            ),

                            // Status Badge
                            AppointmentStatusBadge(status: appt.status),
                            const SizedBox(width: 16),

                            // Action Buttons
                            Row(
                              children: [
                                if (appt.status == AppointmentStatus.waiting) ...[
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.login_rounded, size: 16),
                                    label: const Text('دخول الكشف'),
                                    onPressed: () {
                                      final patient = clinic.getPatientById(appt.patientId);
                                      final doctor = clinic.getDoctorById(appt.doctorId);
                                      if (patient != null && doctor != null) {
                                        clinic.updateAppointmentStatus(appt.id, AppointmentStatus.inConsultation);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DoctorConsultationScreen(
                                              patient: patient,
                                              doctor: doctor,
                                              appointment: appt,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ] else if (appt.status == AppointmentStatus.inConsultation) ...[
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.completed),
                                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                                    label: const Text('إنهاء الكشف'),
                                    onPressed: () {
                                      clinic.updateAppointmentStatus(appt.id, AppointmentStatus.completed);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                                  onSelected: (val) {
                                    if (val == 'open_ehr') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PatientDetailScreen(patientId: appt.patientId),
                                        ),
                                      );
                                    } else if (val == 'no_show') {
                                      clinic.updateAppointmentStatus(appt.id, AppointmentStatus.noShow);
                                    } else if (val == 'cancel') {
                                      clinic.updateAppointmentStatus(appt.id, AppointmentStatus.cancelled);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'open_ehr',
                                      child: Text('فتح الملف الطبي الكامل (EHR)'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'no_show',
                                      child: Text('تسجيل المريض كـ (لم يحضر)'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'cancel',
                                      child: Text('إلغاء الموعد', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
