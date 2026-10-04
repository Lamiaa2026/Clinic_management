import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/consultation.dart';
import '../services/mock_data_service.dart';

class ClinicProvider with ChangeNotifier {
  final _uuid = const Uuid();

  List<Doctor> _doctors = [];
  List<Patient> _patients = [];
  List<Appointment> _appointments = [];

  String _searchPatientQuery = '';
  String? _selectedSpecialtyFilter;
  DateTime _selectedDate = DateTime.now();

  ClinicProvider() {
    _initData();
  }

  void _initData() {
    _doctors = MockDataService.getDoctors();
    _patients = MockDataService.getPatients();
    _appointments = MockDataService.getAppointments();
  }

  // Getters
  List<Doctor> get doctors => List.unmodifiable(_doctors);
  List<Patient> get patients => List.unmodifiable(_patients);
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  String get searchPatientQuery => _searchPatientQuery;
  String? get selectedSpecialtyFilter => _selectedSpecialtyFilter;
  DateTime get selectedDate => _selectedDate;

  List<String> get specialties {
    final list = _doctors.map((d) => d.specialty).toSet().toList();
    list.sort();
    return list;
  }

  // Filtered Patients
  List<Patient> get filteredPatients {
    if (_searchPatientQuery.trim().isEmpty) {
      return _patients;
    }
    final q = _searchPatientQuery.trim().toLowerCase();
    return _patients.where((p) {
      final matchName = p.name.toLowerCase().contains(q);
      final matchPhone = p.phone.contains(q);
      final matchCode = p.patientCode.toLowerCase().contains(q);
      final matchNational = p.nationalId != null && p.nationalId!.contains(q);
      return matchName || matchPhone || matchCode || matchNational;
    }).toList();
  }

  // Filtered Appointments for the selected date
  List<Appointment> get appointmentsForSelectedDate {
    return _appointments.where((a) {
      final isSameDay = a.dateTime.year == _selectedDate.year &&
          a.dateTime.month == _selectedDate.month &&
          a.dateTime.day == _selectedDate.day;
      if (!isSameDay) return false;

      if (_selectedSpecialtyFilter != null &&
          _selectedSpecialtyFilter!.isNotEmpty &&
          _selectedSpecialtyFilter != 'الكل') {
        return a.specialty == _selectedSpecialtyFilter;
      }
      return true;
    }).toList();
  }

  // Today's Waiting Queue across all doctors or for a specific doctor
  List<Appointment> getTodayQueue({String? doctorId}) {
    final now = DateTime.now();
    return _appointments.where((a) {
      final isToday = a.dateTime.year == now.year &&
          a.dateTime.month == now.month &&
          a.dateTime.day == now.day;
      if (!isToday) return false;
      if (doctorId != null && a.doctorId != doctorId) return false;
      return a.status == AppointmentStatus.waiting ||
          a.status == AppointmentStatus.inConsultation;
    }).toList()
      ..sort((a, b) => a.tokenNumber.compareTo(b.tokenNumber));
  }

  // Get Today's Statistics
  Map<String, dynamic> getTodayStats({String? doctorId}) {
    final now = DateTime.now();
    final todayAppts = _appointments.where((a) {
      final isToday = a.dateTime.year == now.year &&
          a.dateTime.month == now.month &&
          a.dateTime.day == now.day;
      if (!isToday) return false;
      if (doctorId != null && a.doctorId != doctorId) return false;
      return true;
    }).toList();

    final total = todayAppts.length;
    final waiting = todayAppts.where((a) => a.status == AppointmentStatus.waiting).length;
    final inConsultation = todayAppts.where((a) => a.status == AppointmentStatus.inConsultation).length;
    final completed = todayAppts.where((a) => a.status == AppointmentStatus.completed).length;
    final cancelled = todayAppts.where((a) => a.status == AppointmentStatus.cancelled).length;
    final revenue = todayAppts
        .where((a) => a.status != AppointmentStatus.cancelled && a.isPaid)
        .fold<double>(0.0, (sum, a) => sum + a.fee);

    return {
      'total': total,
      'waiting': waiting,
      'inConsultation': inConsultation,
      'completed': completed,
      'cancelled': cancelled,
      'revenue': revenue,
    };
  }

  // Actions: Search & Filter
  void setSearchQuery(String query) {
    _searchPatientQuery = query;
    notifyListeners();
  }

  void setSelectedSpecialty(String? specialty) {
    _selectedSpecialtyFilter = specialty;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Patient Actions
  void addPatient(Patient patient) {
    _patients.insert(0, patient);
    notifyListeners();
  }

  void updatePatient(Patient updatedPatient) {
    final index = _patients.indexWhere((p) => p.id == updatedPatient.id);
    if (index != -1) {
      _patients[index] = updatedPatient;
      notifyListeners();
    }
  }

  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Doctor? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  // Appointment Actions
  void bookAppointment({
    required Patient patient,
    required Doctor doctor,
    required DateTime dateTime,
    required VisitType visitType,
    required double fee,
    String? notes,
  }) {
    // Calculate next token number for this doctor on that day
    final existingTokens = _appointments.where((a) {
      return a.doctorId == doctor.id &&
          a.dateTime.year == dateTime.year &&
          a.dateTime.month == dateTime.month &&
          a.dateTime.day == dateTime.day;
    }).map((a) => a.tokenNumber);

    final nextToken = existingTokens.isEmpty
        ? 1
        : (existingTokens.reduce((max, e) => e > max ? e : max) + 1);

    final newAppointment = Appointment(
      id: 'apt_${_uuid.v4().substring(0, 8)}',
      patientId: patient.id,
      patientName: patient.name,
      patientPhone: patient.phone,
      doctorId: doctor.id,
      doctorName: doctor.name,
      specialty: doctor.specialty,
      dateTime: dateTime,
      tokenNumber: nextToken,
      visitType: visitType,
      status: AppointmentStatus.waiting,
      fee: fee,
      isPaid: true,
      notes: notes,
    );

    _appointments.add(newAppointment);
    notifyListeners();
  }

  void updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  // Call Next Patient for a Doctor
  Appointment? callNextPatient(String doctorId) {
    // First finish any currently in-consultation appointment for this doctor
    final currentInConsultation = _appointments.indexWhere(
      (a) => a.doctorId == doctorId && a.status == AppointmentStatus.inConsultation,
    );
    if (currentInConsultation != -1) {
      _appointments[currentInConsultation] = _appointments[currentInConsultation].copyWith(
        status: AppointmentStatus.completed,
      );
    }

    // Find the next waiting patient with the lowest token number
    final waitingList = _appointments.where(
      (a) => a.doctorId == doctorId && a.status == AppointmentStatus.waiting,
    ).toList()
      ..sort((a, b) => a.tokenNumber.compareTo(b.tokenNumber));

    if (waitingList.isNotEmpty) {
      final nextAppt = waitingList.first;
      final nextIndex = _appointments.indexWhere((a) => a.id == nextAppt.id);
      if (nextIndex != -1) {
        _appointments[nextIndex] = _appointments[nextIndex].copyWith(
          status: AppointmentStatus.inConsultation,
        );
        notifyListeners();
        return _appointments[nextIndex];
      }
    }

    notifyListeners();
    return null;
  }

  // Doctor Consultation Recording
  void recordConsultation({
    required String patientId,
    required Consultation consultation,
    String? appointmentId,
  }) {
    final patientIndex = _patients.indexWhere((p) => p.id == patientId);
    if (patientIndex != -1) {
      final currentPatient = _patients[patientIndex];
      final updatedHistory = List<Consultation>.from(currentPatient.medicalHistory)
        ..insert(0, consultation);

      _patients[patientIndex] = currentPatient.copyWith(
        medicalHistory: updatedHistory,
      );

      // If tied to an appointment, mark it completed
      if (appointmentId != null) {
        updateAppointmentStatus(appointmentId, AppointmentStatus.completed);
      } else {
        // Find if there is an inConsultation appointment for this patient
        final apptIndex = _appointments.indexWhere(
          (a) => a.patientId == patientId && a.status == AppointmentStatus.inConsultation,
        );
        if (apptIndex != -1) {
          _appointments[apptIndex] = _appointments[apptIndex].copyWith(
            status: AppointmentStatus.completed,
          );
        }
      }

      notifyListeners();
    }
  }
}
