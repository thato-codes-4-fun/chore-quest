import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';

class RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback? onTap;
  final VoidCallback? onRedeem;

  const RewardCard({
    super.key,
    required this.reward,
    this.onTap,
    this.onRedeem,
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
                          reward.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        if (reward.description != null && reward.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              reward.description!,
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
                      color: _getTypeColor(reward.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTypeText(reward.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(reward.type),
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
                        color: AppConstants.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.cost.toInt()} points',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (onRedeem != null)
                    ElevatedButton(
                      onPressed: onRedeem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingSmall,
                        ),
                      ),
                      child: const Text('Redeem'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(RewardType type) {
    switch (type) {
      case RewardType.shortTerm:
        return AppConstants.primaryColor;
      case RewardType.longTerm:
        return AppConstants.secondaryColor;
    }
  }

  String _getTypeText(RewardType type) {
    switch (type) {
      case RewardType.shortTerm:
        return 'Short Term';
      case RewardType.longTerm:
        return 'Long Term';
    }
  }
}
