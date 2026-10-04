import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/patient.dart';
import '../../providers/clinic_provider.dart';

class AddEditPatientDialog extends StatefulWidget {
  final Patient? patientToEdit;

  const AddEditPatientDialog({super.key, this.patientToEdit});

  @override
  State<AddEditPatientDialog> createState() => _AddEditPatientDialogState();
}

class _AddEditPatientDialogState extends State<AddEditPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _notesController = TextEditingController();
  final _chronicController = TextEditingController();
  final _allergyController = TextEditingController();

  Gender _gender = Gender.male;
  String? _bloodGroup = 'O+';
  final List<String> _chronicDiseases = [];
  final List<String> _allergies = [];

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    if (widget.patientToEdit != null) {
      final p = widget.patientToEdit!;
      _nameController.text = p.name;
      _phoneController.text = p.phone;
      _ageController.text = p.age.toString();
      _nationalIdController.text = p.nationalId ?? '';
      _notesController.text = p.notes ?? '';
      _gender = p.gender;
      _bloodGroup = p.bloodGroup ?? 'O+';
      _chronicDiseases.addAll(p.chronicDiseases);
      _allergies.addAll(p.allergies);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _nationalIdController.dispose();
    _notesController.dispose();
    _chronicController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _addChronic() {
    final text = _chronicController.text.trim();
    if (text.isNotEmpty && !_chronicDiseases.contains(text)) {
      setState(() {
        _chronicDiseases.add(text);
        _chronicController.clear();
      });
    }
  }

  void _addAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() {
        _allergies.add(text);
        _allergyController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patientToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 580,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                        child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEdit ? 'تعديل بيانات المريض' : 'تسجيل مريض جديد بالعيادة',
                        style: const TextStyle(
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
                      // Full Name
                      const Text('اسم المريض رباعي *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'مثال: محمد إبراهيم حسن',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال اسم المريض' : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone and Age
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('رقم الهاتف / الواتساب *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    hintText: '01xxxxxxxxx',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('العمر (بالسنوات) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'مثال: 35',
                                    prefixIcon: Icon(Icons.cake_outlined),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'مطلوب';
                                    if (int.tryParse(v) == null) return 'أرقام فقط';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Gender & Blood Group
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('النوع / الجنس', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<Gender>(
                                        title: const Text('ذكر', style: TextStyle(fontSize: 13)),
                                        value: Gender.male,
                                        groupValue: _gender,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (v) => setState(() => _gender = v!),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<Gender>(
                                        title: const Text('أنثى', style: TextStyle(fontSize: 13)),
                                        value: Gender.female,
                                        groupValue: _gender,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (v) => setState(() => _gender = v!),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('فصيلة الدم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _bloodGroup,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.bloodtype_outlined, color: Colors.red),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: _bloodGroups.map((bg) {
                                    return DropdownMenuItem(value: bg, child: Text(bg));
                                  }).toList(),
                                  onChanged: (v) => setState(() => _bloodGroup = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // National ID
                      const Text('الرقم القومي / الهوية (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nationalIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '14 رقم للرقم القومي',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chronic Diseases Section
                      const Text('الأمراض المزمنة (إن وجدت)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chronicController,
                              decoration: const InputDecoration(
                                hintText: 'مثال: السكري، ارتفاع ضغط الدم، الربو...',
                                prefixIcon: Icon(Icons.favorite_border_rounded),
                              ),
                              onSubmitted: (_) => _addChronic(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addChronic,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ],
                      ),
                      if (_chronicDiseases.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _chronicDiseases.map((c) {
                            return Chip(
                              label: Text(c, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primarySubtle,
                              deleteIconColor: AppColors.cancelled,
                              onDeleted: () => setState(() => _chronicDiseases.remove(c)),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Allergies Section
                      const Text('الحساسية الدوائية والغذائية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _allergyController,
                              decoration: const InputDecoration(
                                hintText: 'مثال: حساسية البنسلين، السلفا...',
                                prefixIcon: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                              ),
                              onSubmitted: (_) => _addAllergy(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addAllergy,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(backgroundColor: Colors.orange),
                          ),
                        ],
                      ),
                      if (_allergies.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _allergies.map((a) {
                            return Chip(
                              label: Text(a, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.orange.withValues(alpha: 0.15),
                              deleteIconColor: AppColors.cancelled,
                              onDeleted: () => setState(() => _allergies.remove(a)),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Notes
                      const Text('ملاحظات سريرية إضافية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'أي تفاصيل أخرى تهم الطبيب...',
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
                    icon: Icon(isEdit ? Icons.save_rounded : Icons.check_rounded, size: 18),
                    label: Text(isEdit ? 'حفظ التعديلات' : 'تسجيل المريض وفتح ملف'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final clinic = Provider.of<ClinicProvider>(context, listen: false);

                        if (isEdit) {
                          final updated = widget.patientToEdit!.copyWith(
                            name: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                            age: int.tryParse(_ageController.text.trim()) ?? 0,
                            gender: _gender,
                            nationalId: _nationalIdController.text.trim().isNotEmpty
                                ? _nationalIdController.text.trim()
                                : null,
                            bloodGroup: _bloodGroup,
                            chronicDiseases: _chronicDiseases,
                            allergies: _allergies,
                            notes: _notesController.text.trim().isNotEmpty
                                ? _notesController.text.trim()
                                : null,
                          );
                          clinic.updatePatient(updated);
                        } else {
                          final patientCount = clinic.patients.length + 1001;
                          final newPatient = Patient(
                            id: 'pat_${const Uuid().v4().substring(0, 8)}',
                            patientCode: 'PAT-$patientCount',
                            name: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                            age: int.tryParse(_ageController.text.trim()) ?? 0,
                            gender: _gender,
                            nationalId: _nationalIdController.text.trim().isNotEmpty
                                ? _nationalIdController.text.trim()
                                : null,
                            bloodGroup: _bloodGroup,
                            chronicDiseases: _chronicDiseases,
                            allergies: _allergies,
                            notes: _notesController.text.trim().isNotEmpty
                                ? _notesController.text.trim()
                                : null,
                          );
                          clinic.addPatient(newPatient);
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit ? 'تم تحديث بيانات المريض' : 'تم إضافة المريض بنجاح',
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
