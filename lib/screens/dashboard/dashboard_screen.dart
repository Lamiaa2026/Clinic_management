import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../appointments/book_appointment_dialog.dart';
import '../patients/add_edit_patient_dialog.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;
  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final clinic = Provider.of<ClinicProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final doctorId = auth.isDoctorView? auth.currentDoctor?.id : null;
    final stats = clinic.getTodayStats(doctorId: doctorId);
    final waitingQueue = clinic.getTodayQueue(doctorId: doctorId);
    final todayAppointments = clinic.appointmentsForSelectedDate;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(auth.isDoctorView? 'مرحباً بك يا ${auth.currentDoctor?.name} 🩺' : 'مرحباً بك في مجمع العيادات 🏥', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(auth.isDoctorView? '${auth.currentDoctor?.specialty} • ${auth.currentDoctor?.roomNumber} • لديك ${stats['waiting']} مريض في الانتظار' : 'إدارة الكشوفات، المرضى، والمواعيد لحظياً بين الاستقبال والأطباء.', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark), icon: const Icon(Icons.add_circle_outline, size: 18), label: const Text('حجز كشف'), onPressed: () => showDialog(context: context, builder: (_) => const BookAppointmentDialog())),
              OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)), icon: const Icon(Icons.person_add_alt_1_outlined, size: 18), label: const Text('مريض جديد'), onPressed: () => showDialog(context: context, builder: (_) => const AddEditPatientDialog())),
            ]),
          ])),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final isMobile = c.maxWidth < 600;
            return GridView.count(crossAxisCount: isMobile? 2 : 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: isMobile? 1.4 : 1.5, children: [
              StatCard(title: 'حجوزات اليوم', value: stats['total'].toString(), icon: Icons.calendar_today_rounded, color: AppColors.primary, subtitle: 'كشف واستشارة'),
              StatCard(title: 'الانتظار', value: stats['waiting'].toString(), icon: Icons.hourglass_top_rounded, color: AppColors.waiting, subtitle: 'بانتظار الدخول'),
              StatCard(title: 'مكتملة', value: stats['completed'].toString(), icon: Icons.check_circle_rounded, color: AppColors.completed, subtitle: 'تم الانتهاء'),
              StatCard(title: 'إيرادات اليوم', value: Formatters.formatCurrency(stats['revenue'] as double), icon: Icons.payments_rounded, color: AppColors.accent, subtitle: 'مدفوعات'),
            ]);
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final isWide = c.maxWidth > 850;
            if (isWide) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: _buildQueueCard(waitingQueue, onNavigateTab)), const SizedBox(width: 16), Expanded(flex: 2, child: _buildChartCard())]);
            } else {
              return Column(children: [_buildQueueCard(waitingQueue, onNavigateTab), const SizedBox(height: 16), _buildChartCard()]);
            }
          }),
          const SizedBox(height: 20),
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Flexible(child: Text('مواعيد اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), if (onNavigateTab!= null) OutlinedButton.icon(icon: const Icon(Icons.calendar_month, size: 16), label: const Text('الجدول الكامل', style: TextStyle(fontSize: 12)), onPressed: () => onNavigateTab!(2))]),
            const SizedBox(height: 12),
            if (todayAppointments.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد مواعيد اليوم'))) else SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(headingRowColor: WidgetStateProperty.all(AppColors.background), columns: const [DataColumn(label: Text('الدور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), DataColumn(label: Text('المريض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), DataColumn(label: Text('الطبيب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), DataColumn(label: Text('الوقت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))], rows: todayAppointments.map((appt) => DataRow(cells: [DataCell(CircleAvatar(radius: 12, child: Text('#${appt.tokenNumber}', style: const TextStyle(fontSize: 10)))), DataCell(Text(appt.patientName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))), DataCell(Text(appt.doctorName, style: const TextStyle(fontSize: 12))), DataCell(Text(Formatters.formatTime(appt.dateTime), style: const TextStyle(fontSize: 12))), DataCell(AppointmentStatusBadge(status: appt.status))])).toList())),
          ])),
        ]),
      ),
    );
  }

  Widget _buildQueueCard(List waitingQueue, Function(int)? onNavigateTab) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Flexible(child: Text('قائمة الانتظار الحية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), if (onNavigateTab!= null) TextButton(onPressed: () => onNavigateTab(1), child: const Text('عرض الكل'))]),
      const Divider(height: 20),
      if (waitingQueue.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لا يوجد مرضى في الانتظار'))) else ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: waitingQueue.take(4).length, itemBuilder: (context, index) {
        final appt = waitingQueue[index];
        return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)), child: Row(children: [CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: Text('#${appt.tokenNumber}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 1), Text('${appt.doctorName} • ${Formatters.formatTime(appt.dateTime)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 1)])), const SizedBox(width: 8), AppointmentStatusBadge(status: appt.status)]));
      }),
    ]));
  }

  Widget _buildChartCard() {
    return Container(height: 300, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20), SizedBox(width: 8), Text('حركة الأسبوع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 20),
      Expanded(child: BarChart(BarChartData(maxY: 25, clipData: const FlClipData.all(), barTouchData: BarTouchData(enabled: true), titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, m) { const days = ['سبت','أحد','اثنين','ثلاثاء','أربعاء','خميس','جمعة']; if (v.toInt() >= days.length) return const SizedBox(); return SideTitleWidget(axisSide: m.axisSide, child: Text(days[v.toInt()], style: const TextStyle(fontSize: 9))); })), gridData: FlGridData(show: true, drawVerticalLine: false), borderData: FlBorderData(show: false), barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: [14,18,22,16,19,12,6][i].toDouble(), color: AppColors.primary, width: 12, borderRadius: BorderRadius.circular(4))]))))),
    ]));
  }
}