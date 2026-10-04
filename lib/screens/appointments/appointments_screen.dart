import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../doctor_room/doctor_consultation_screen.dart';
import '../patients/patient_detail_screen.dart';
import 'book_appointment_dialog.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinic = Provider.of<ClinicProvider>(context);
    final appointments = clinic.appointmentsForSelectedDate;
    final selectedDate = clinic.selectedDate;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'جدول المواعيد والحجوزات',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مواعيد يوم ${Formatters.formatDateArabic(selectedDate)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('حجز موعد جديد'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const BookAppointmentDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Selection Strip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      clinic.setSelectedDate(selectedDate.subtract(const Duration(days: 1)));
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.today, size: 16),
                    label: const Text('اليوم'),
                    onPressed: () => clinic.setSelectedDate(DateTime.now()),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        clinic.setSelectedDate(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.formatDateArabic(selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      clinic.setSelectedDate(selectedDate.add(const Duration(days: 1)));
                    },
                  ),
                  const Spacer(),
                  // Specialty Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('جميع التخصصات'),
                          selected: clinic.selectedSpecialtyFilter == null || clinic.selectedSpecialtyFilter == 'الكل',
                          onSelected: (_) => clinic.setSelectedSpecialty(null),
                        ),
                        const SizedBox(width: 8),
                        ...clinic.specialties.map((spec) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(spec),
                              selected: clinic.selectedSpecialtyFilter == spec,
                              onSelected: (_) => clinic.setSelectedSpecialty(spec),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appointments List / Table
            if (appointments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: EmptyStateWidget(
                  icon: Icons.event_busy_rounded,
                  title: 'لا توجد مواعيد مسجلة لهذا اليوم',
                  subtitle: 'يمكنك اختيار تاريخ آخر أو إضافة حجز جديد',
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.background),
                    columns: const [
                      DataColumn(label: Text('رقم الدور', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('المريض', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('الطبيب والتخصص', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('التوقيت', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('الرسوم', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('خيارات', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: appointments.map((appt) {
                      return DataRow(
                        cells: [
                          DataCell(
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primarySubtle,
                              child: Text(
                                '#${appt.tokenNumber}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                          DataCell(
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
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ),
                          DataCell(Text(appt.patientPhone)),
                          DataCell(Text('${appt.doctorName} (${appt.specialty})')),
                          DataCell(Text(Formatters.formatTime(appt.dateTime))),
                          DataCell(VisitTypeBadge(type: appt.visitType)),
                          DataCell(Text(Formatters.formatCurrency(appt.fee), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(AppointmentStatusBadge(status: appt.status)),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.folder_shared_outlined, size: 18, color: AppColors.primary),
                                  tooltip: 'الملف الطبي',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PatientDetailScreen(patientId: appt.patientId),
                                      ),
                                    );
                                  },
                                ),
                                if (appt.status == AppointmentStatus.waiting)
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_outline, size: 18, color: AppColors.completed),
                                    tooltip: 'بدء الكشف',
                                    onPressed: () {
                                      final patient = clinic.getPatientById(appt.patientId);
                                      final doctor = clinic.getDoctorById(appt.doctorId);
                                      if (patient != null && doctor != null) {
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
                                PopupMenuButton<AppointmentStatus>(
                                  icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
                                  onSelected: (status) {
                                    clinic.updateAppointmentStatus(appt.id, status);
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: AppointmentStatus.waiting,
                                      child: Text('في الانتظار'),
                                    ),
                                    const PopupMenuItem(
                                      value: AppointmentStatus.inConsultation,
                                      child: Text('داخل الكشف'),
                                    ),
                                    const PopupMenuItem(
                                      value: AppointmentStatus.completed,
                                      child: Text('تم الكشف'),
                                    ),
                                    const PopupMenuItem(
                                      value: AppointmentStatus.cancelled,
                                      child: Text('إلغاء الموعد', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
