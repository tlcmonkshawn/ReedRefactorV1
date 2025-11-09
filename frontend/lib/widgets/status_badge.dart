import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label) = _getStatusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStatusInfo(String status) {
    switch (status) {
      case 'captured':
        return (Colors.blue, 'Captured');
      case 'submitted':
        return (Colors.orange, 'Submitted');
      case 'researching':
        return (Colors.purple, 'Researching');
      case 'researched':
        return (Colors.green, 'Researched');
      case 'finalized':
        return (Colors.teal, 'Finalized');
      default:
        return (Colors.grey, status);
    }
  }
}

