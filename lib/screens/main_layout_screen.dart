import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/clinic_provider.dart';
import 'appointments/appointments_screen.dart';
import 'appointments/book_appointment_dialog.dart';
import 'dashboard/dashboard_screen.dart';
import 'doctors/doctors_list_screen.dart';
import 'patients/add_edit_patient_dialog.dart';
import 'patients/patients_list_screen.dart';
import 'queue/live_queue_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});
  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, title: 'لوحة التحكم'),
    NavItem(icon: Icons.hourglass_top_outlined, activeIcon: Icons.hourglass_top_rounded, title: 'الانتظار'),
    NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, title: 'المواعيد'),
    NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_alt_rounded, title: 'المرضى'),
    NavItem(icon: Icons.medical_services_outlined, activeIcon: Icons.medical_services_rounded, title: 'الأطباء'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final clinic = Provider.of<ClinicProvider>(context);

    final pages = [
      DashboardScreen(onNavigateTab: (index) => setState(() => _currentIndex = index)),
      const LiveQueueScreen(),
      const AppointmentsScreen(),
      const PatientsListScreen(),
      const DoctorsListScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Row(
              children: [
                if (isWide) _buildSidebar(context, auth, clinic),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopAppBar(context, auth, clinic),
                      const Divider(height: 1, thickness: 1),
                      // التعديل المهم: شيلنا IndexedStack وحطينا الصفحة الحالية بس
                      Expanded(
                        child: pages[_currentIndex],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:!isWide
             ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.textMuted,
                  selectedFontSize: 11,
                  unselectedFontSize: 10,
                  items: _navItems.map((item) {
                    return BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      activeIcon: Icon(item.activeIcon),
                      label: item.title,
                    );
                  }).toList(),
                )
              : null,
        );
      },
    );
  }

  Widget _buildTopAppBar(BuildContext context, AuthProvider auth, ClinicProvider clinic) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primarySubtle, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('مجمع العيادات التخصصية',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text('${Formatters.formatDateArabic(now)} • ${Formatters.formatTime(now)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (MediaQuery.of(context).size.width < 600)...[
                IconButton(icon: const Icon(Icons.person_add_alt_1_outlined, size: 20), onPressed: () => showDialog(context: context, builder: (_) => const AddEditPatientDialog())),
                IconButton(icon: const Icon(Icons.add, size: 20), onPressed: () => showDialog(context: context, builder: (_) => const BookAppointmentDialog())),
              ] else...[
                OutlinedButton.icon(icon: const Icon(Icons.person_add_alt_1_outlined, size: 15), label: const Text('مريض جديد', style: TextStyle(fontSize: 12)), onPressed: () => showDialog(context: context, builder: (_) => const AddEditPatientDialog())),
                const SizedBox(width: 8),
                ElevatedButton.icon(icon: const Icon(Icons.add, size: 15), label: const Text('حجز كشف', style: TextStyle(fontSize: 12)), onPressed: () => showDialog(context: context, builder: (_) => const BookAppointmentDialog())),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AuthProvider auth, ClinicProvider clinic) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مجمع العيادات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text('نظام الإدارة الطبية', style: TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)])),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(color: isSelected? AppColors.primarySubtle : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(isSelected? item.activeIcon : item.icon, color: isSelected? AppColors.primaryDark : AppColors.textSecondary),
                    title: Text(item.title, style: TextStyle(fontSize: 14, fontWeight: isSelected? FontWeight.bold : FontWeight.w500, color: isSelected? AppColors.primaryDark : AppColors.textSecondary)),
                    onTap: () => setState(() => _currentIndex = index),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(color: AppColors.cardBorder))),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: auth.isDoctorView? AppColors.secondaryLight : AppColors.primarySubtle, child: Icon(auth.isDoctorView? Icons.medical_services_rounded : Icons.person_rounded, color: auth.isDoctorView? AppColors.secondary : AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(auth.isDoctorView? auth.currentDoctor!.name : 'موظف الاستقبال', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis), Text(auth.isDoctorView? auth.currentDoctor!.specialty : 'إدارة وحجز', style: const TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  const NavItem({required this.icon, required this.activeIcon, required this.title});
}