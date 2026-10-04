import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/appointment.dart';

class AppointmentStatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const AppointmentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case AppointmentStatus.waiting:
        bg = AppColors.waitingBg;
        fg = AppColors.waiting;
        icon = Icons.hourglass_top_rounded;
        break;
      case AppointmentStatus.inConsultation:
        bg = AppColors.inProgressBg;
        fg = AppColors.inProgress;
        icon = Icons.medical_services_rounded;
        break;
      case AppointmentStatus.completed:
        bg = AppColors.completedBg;
        fg = AppColors.completed;
        icon = Icons.check_circle_rounded;
        break;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        bg = AppColors.cancelledBg;
        fg = AppColors.cancelled;
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status.title,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class VisitTypeBadge extends StatelessWidget {
  final VisitType type;

  const VisitTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case VisitType.newVisit:
        color = AppColors.primary;
        break;
      case VisitType.followUp:
        color = AppColors.accent;
        break;
      case VisitType.emergency:
        color = AppColors.cancelled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.title,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
