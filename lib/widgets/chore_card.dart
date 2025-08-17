import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';

class ChoreCard extends StatelessWidget {
  final Chore chore;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onComplete;

  const ChoreCard({
    super.key,
    required this.chore,
    this.onTap,
    this.showActions = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chore.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        if (chore.description != null && chore.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              chore.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(chore.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(chore.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(chore.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${chore.value.toInt()} points',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (showActions && onComplete != null)
                    ElevatedButton(
                      onPressed: onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingSmall,
                        ),
                      ),
                      child: const Text('Complete'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ChoreStatus status) {
    switch (status) {
      case ChoreStatus.assigned:
        return AppConstants.warningColor;
      case ChoreStatus.completed:
        return AppConstants.successColor;
      case ChoreStatus.approved:
        return AppConstants.successColor;
      case ChoreStatus.rejected:
        return AppConstants.errorColor;
    }
  }

  String _getStatusText(ChoreStatus status) {
    switch (status) {
      case ChoreStatus.assigned:
        return 'Assigned';
      case ChoreStatus.completed:
        return 'Completed';
      case ChoreStatus.approved:
        return 'Approved';
      case ChoreStatus.rejected:
        return 'Rejected';
    }
  }
}
