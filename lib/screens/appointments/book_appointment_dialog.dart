import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/patient.dart';
import '../../providers/clinic_provider.dart';

class BookAppointmentDialog extends StatefulWidget {
  final Patient? preselectedPatient;

  const BookAppointmentDialog({super.key, this.preselectedPatient});

  @override
  State<BookAppointmentDialog> createState() => _BookAppointmentDialogState();
}

class _BookAppointmentDialogState extends State<BookAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  Patient? _selectedPatient;
  Doctor? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 17, minute: 0);
  VisitType _visitType = VisitType.newVisit;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.preselectedPatient;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _currentFee {
    if (_selectedDoctor == null) return 0.0;
    return _visitType == VisitType.followUp
        ? _selectedDoctor!.followUpFee
        : _selectedDoctor!.consultationFee;
  }

  @override
  Widget build(BuildContext context) {
    final clinic = Provider.of<ClinicProvider>(context);
    final patients = clinic.patients;
    final doctors = clinic.doctors;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'حجز موعد جديد',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Select Patient
                      const Text(
                        'المريض',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Patient>(
                        initialValue: _selectedPatient,
                        decoration: InputDecoration(
                          hintText: 'اختر المريض من السجل',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: patients.map((p) {
                          return DropdownMenuItem<Patient>(
                            value: p,
                            child: Text('${p.name} (${p.patientCode} - ${p.phone})'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPatient = val),
                        validator: (val) => val == null ? 'يرجى اختيار المريض' : null,
                      ),
                      const SizedBox(height: 18),

                      // 2. Select Doctor
                      const Text(
                        'الطبيب / العيادة',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Doctor>(
                        initialValue: _selectedDoctor,
                        decoration: InputDecoration(
                          hintText: 'اختر الطبيب والتخصص',
                          prefixIcon: const Icon(Icons.medical_services_outlined),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: doctors.map((d) {
                          return DropdownMenuItem<Doctor>(
                            value: d,
                            child: Text('${d.name} - ${d.specialty} (${d.roomNumber})'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedDoctor = val),
                        validator: (val) => val == null ? 'يرجى اختيار الطبيب' : null,
                      ),
                      const SizedBox(height: 18),

                      // 3. Visit Type
                      const Text(
                        'نوع الكشف',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<VisitType>(
                              title: const Text('كشف جديد', style: TextStyle(fontSize: 13)),
                              value: VisitType.newVisit,
                              groupValue: _visitType,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => setState(() => _visitType = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<VisitType>(
                              title: const Text('استشارة / إعادة', style: TextStyle(fontSize: 13)),
                              value: VisitType.followUp,
                              groupValue: _visitType,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => setState(() => _visitType = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<VisitType>(
                              title: const Text('طارئ', style: TextStyle(fontSize: 13)),
                              value: VisitType.emergency,
                              groupValue: _visitType,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => setState(() => _visitType = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4. Date and Time Pickers
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('تاريخ الكشف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                      lastDate: DateTime.now().add(const Duration(days: 90)),
                                    );
                                    if (picked != null) {
                                      setState(() => _selectedDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(Formatters.formatDate(_selectedDate)),
                                        const Icon(Icons.event, size: 18, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('الوقت المتوقع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: _selectedTime,
                                    );
                                    if (picked != null) {
                                      setState(() => _selectedTime = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_selectedTime.format(context)),
                                        const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Fee Display Card
                      if (_selectedDoctor != null)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.payments_outlined, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'رسوم ${_visitType.title}:',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                Formatters.formatCurrency(_currentFee),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),

                      // Notes
                      const Text(
                        'ملاحظات إضافية (اختياري)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'سبب الحجز، أو أي توجيهات خاصة...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('تأكيد الحجز وطباعة التذكرة'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final apptDateTime = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        );

                        clinic.bookAppointment(
                          patient: _selectedPatient!,
                          doctor: _selectedDoctor!,
                          dateTime: apptDateTime,
                          visitType: _visitType,
                          fee: _currentFee,
                          notes: _notesController.text.trim().isNotEmpty
                              ? _notesController.text.trim()
                              : null,
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم حجز الموعد بنجاح للمريض ${_selectedPatient!.name}',
                            ),
                            backgroundColor: AppColors.completed,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
