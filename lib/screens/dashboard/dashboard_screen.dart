import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../appointments/book_appointment_dialog.dart';
import '../doctor_room/doctor_consultation_screen.dart';
import '../patients/add_edit_patient_dialog.dart';
import '../patients/patient_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final clinic = Provider.of<ClinicProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final doctorId = auth.isDoctorView ? auth.currentDoctor?.id : null;

    final stats = clinic.getTodayStats(doctorId: doctorId);
    final waitingQueue = clinic.getTodayQueue(doctorId: doctorId);
    final todayAppointments = clinic.appointmentsForSelectedDate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome & Quick Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isDoctorView
                            ? 'مرحباً بك يا ${auth.currentDoctor?.name} 🩺'
                            : 'مرحباً بك في نظام إدارة مجمع العيادات 🏥',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        auth.isDoctorView
                            ? '${auth.currentDoctor?.specialty}  •  ${auth.currentDoctor?.roomNumber}  •  لديك ${stats['waiting']} مريض في قائمة الانتظار اليوم'
                            : 'نظام إدارة الكشوفات، سجلات المرضى، المواعيد والمزامنة اللحظية بين الاستقبال والأطباء.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryDark,
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('حجز كشف جديد'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const BookAppointmentDialog(),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                            ),
                            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                            label: const Text('تسجيل مريض جديد'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const AddEditPatientDialog(),
                              );
                            },
                          ),
                          if (auth.isDoctorView && waitingQueue.isNotEmpty)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade400,
                                foregroundColor: Colors.brown.shade900,
                              ),
                              icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                              label: const Text('استدعاء المريض التالي'),
                              onPressed: () {
                                final nextAppt = clinic.callNextPatient(auth.currentDoctor!.id);
                                if (nextAppt != null) {
                                  final patient = clinic.getPatientById(nextAppt.patientId);
                                  if (patient != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DoctorConsultationScreen(
                                          patient: patient,
                                          doctor: auth.currentDoctor!,
                                          appointment: nextAppt,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Metrics Statistics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width > 900 ? 4 : (width > 500 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: 'حجوزات اليوم الكلية',
                    value: stats['total'].toString(),
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    subtitle: 'كشف واستشارة',
                  ),
                  StatCard(
                    title: 'في غرفة الانتظار',
                    value: stats['waiting'].toString(),
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.waiting,
                    subtitle: 'بانتظار الدخول',
                  ),
                  StatCard(
                    title: 'كشوفات مكتملة',
                    value: stats['completed'].toString(),
                    icon: Icons.check_circle_rounded,
                    color: AppColors.completed,
                    subtitle: 'تم الانتهاء منها',
                  ),
                  StatCard(
                    title: 'إيرادات اليوم',
                    value: Formatters.formatCurrency(stats['revenue'] as double),
                    icon: Icons.payments_rounded,
                    color: AppColors.accent,
                    subtitle: 'مدفوعات مؤكدة',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 3. Waiting Queue & Analytics Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waiting Queue Card
                  Expanded(
                    flex: isWide ? 3 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 8,
                            spacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.waitingBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.people_alt_rounded, color: AppColors.waiting),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'قائمة الانتظار الحية (Live Queue)',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (onNavigateTab != null)
                                TextButton(
                                  onPressed: () => onNavigateTab!(1),
                                  child: const Text('عرض الكل'),
                                ),
                            ],
                          ),
                          const Divider(height: 24),
                          if (waitingQueue.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('لا يوجد مرضى في قائمة الانتظار حالياً'),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: waitingQueue.take(4).length,
                              itemBuilder: (context, index) {
                                final appt = waitingQueue[index];
                                final isNext = appt.status == AppointmentStatus.inConsultation;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isNext ? AppColors.inProgressBg : AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isNext ? AppColors.inProgress : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: isNext ? AppColors.inProgress : AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '#${appt.tokenNumber}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appt.patientName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            Text(
                                              '${appt.doctorName} (${appt.specialty}) • ${Formatters.formatTime(appt.dateTime)}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppointmentStatusBadge(status: appt.status),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (isWide) const SizedBox(width: 20),
                  if (!isWide) const SizedBox(height: 20),

                  // Weekly Patients Flow Chart
                  Expanded(
                    flex: isWide ? 2 : 0,
                    child: Container(
                      height: 320,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'حركة الكشوفات خلال الأسبوع',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 25,
                                barTouchData: BarTouchData(enabled: true),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (val, meta) => Text(
                                        val.toInt().toString(),
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (val, meta) {
                                        const days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
                                        if (val.toInt() >= 0 && val.toInt() < days.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              days[val.toInt()],
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (val) => FlLine(
                                    color: AppColors.divider,
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  _makeGroupData(0, 14),
                                  _makeGroupData(1, 18),
                                  _makeGroupData(2, 22),
                                  _makeGroupData(3, 16),
                                  _makeGroupData(4, 19),
                                  _makeGroupData(5, 12),
                                  _makeGroupData(6, 6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 4. Today's Appointments Table
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'مواعيد اليوم بالعيادات',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (onNavigateTab != null)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_month, size: 16),
                        label: const Text('جدول المواعيد الكامل'),
                        onPressed: () => onNavigateTab!(2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (todayAppointments.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد مواعيد مسجلة لليوم')))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.background),
                      columns: const [
                        DataColumn(label: Text('رقم الدور', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('المريض', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الطبيب والعيادة', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الوقت', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('نوع الكشف', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: todayAppointments.map((appt) {
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
                            DataCell(AppointmentStatusBadge(status: appt.status)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                    tooltip: 'عرض الملف الطبي',
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
                                      icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.completed),
                                      tooltip: 'بدء الكشف الطبي',
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
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
