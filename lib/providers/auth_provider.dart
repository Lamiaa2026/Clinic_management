import 'package:flutter/material.dart';
import '../models/doctor.dart';

enum UserRole {
  receptionist,
  doctor,
}

class AuthProvider with ChangeNotifier {
  UserRole _currentRole = UserRole.receptionist;
  Doctor? _currentDoctor;

  UserRole get currentRole => _currentRole;
  Doctor? get currentDoctor => _currentDoctor;
  bool get isDoctorView => _currentRole == UserRole.doctor;
  bool get isReceptionView => _currentRole == UserRole.receptionist;

  void setReceptionistRole() {
    _currentRole = UserRole.receptionist;
    _currentDoctor = null;
    notifyListeners();
  }

  void setDoctorRole(Doctor doctor) {
    _currentRole = UserRole.doctor;
    _currentDoctor = doctor;
    notifyListeners();
  }
}
