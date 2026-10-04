import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/empty_state.dart';
import '../appointments/book_appointment_dialog.dart';
import 'add_edit_patient_dialog.dart';
import 'patient_detail_screen.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinic = Provider.of<ClinicProvider>(context);
    final patients = clinic.filteredPatients;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'سجلات وملفات المرضى (EHR)',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إجمالي المرضى المسجلين: ${clinic.patients.length} مريض',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('تسجيل مريض جديد'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddEditPatientDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                onChanged: (val) => clinic.setSearchQuery(val),
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم المريض، رقم الهاتف، كود المريض (PAT-1001)، أو الرقم القومي...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Patients Grid / List
            Expanded(
              child: patients.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.person_search_rounded,
                      title: 'لم يتم العثور على أي مريض',
                      subtitle: 'تأكد من كتابة الاسم أو رقم الهاتف بشكل صحيح، أو أضف مريض جديد',
                      action: ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('إضافة مريض جديد الآن'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddEditPatientDialog(),
                          );
                        },
                      ),
                    )
                  : ListView.builder(
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(patientId: patient.id),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primarySubtle,
                              child: Text(
                                patient.name.characters.first,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  patient.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySubtle,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    patient.patientCode,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Text('📞 ${patient.phone}', style: const TextStyle(fontSize: 12)),
                                    Text('🎂 ${patient.age} سنة (${patient.genderText})', style: const TextStyle(fontSize: 12)),
                                    if (patient.bloodGroup != null)
                                      Text('🩸 ${patient.bloodGroup}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                                    Text('🩺 ${patient.medicalHistory.length} زيارات سابقة', style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                                  ],
                                ),
                                if (patient.chronicDiseases.isNotEmpty || patient.allergies.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      ...patient.chronicDiseases.map(
                                        (c) => Chip(
                                          label: Text('مزمن: $c', style: const TextStyle(fontSize: 10)),
                                          backgroundColor: AppColors.primarySubtle,
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                      ...patient.allergies.map(
                                        (a) => Chip(
                                          label: Text('حساسية: $a', style: const TextStyle(fontSize: 10, color: Colors.deepOrange)),
                                          backgroundColor: Colors.orange.shade50,
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.calendar_month, size: 16),
                                  label: const Text('حجز موعد'),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => BookAppointmentDialog(preselectedPatient: patient),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.folder_shared_outlined, size: 16),
                                  label: const Text('الملف الطبي'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PatientDetailScreen(patientId: patient.id),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
