import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../models/models.dart';
import '../../../providers/reward_provider.dart';
import '../../../providers/user_provider.dart';

class RewardManagementScreen extends StatefulWidget {
  const RewardManagementScreen({super.key});

  @override
  State<RewardManagementScreen> createState() => _RewardManagementScreenState();
}

class _RewardManagementScreenState extends State<RewardManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);

    await userProvider.loadFamilyMembers();
    await rewardProvider.loadRewards(
      createdById: userProvider.currentUser?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Short Term'),
            Tab(text: 'Long Term'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddRewardDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRewardList(RewardType.shortTerm),
          _buildRewardList(RewardType.longTerm),
        ],
      ),
    );
  }

  Widget _buildRewardList(RewardType type) {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, child) {
        final rewards = rewardProvider.getRewardsByType(type);

        if (rewards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == RewardType.shortTerm 
                      ? Icons.card_giftcard_outlined
                      : Icons.flag_outlined,
                  size: 64,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  type == RewardType.shortTerm 
                      ? 'No short-term rewards yet'
                      : 'No long-term rewards yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: () {
                    _showAddRewardDialog();
                  },
                  child: Text('Add ${type == RewardType.shortTerm ? 'Short-term' : 'Long-term'} Reward'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return _buildRewardCard(reward);
            },
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
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
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        reward.description,
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
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
                    color: reward.isActive 
                        ? AppConstants.successColor 
                        : AppConstants.textSecondaryColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    reward.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final kid = userProvider.familyMembers
                        .firstWhere((user) => user.id == reward.kidId,
                            orElse: () => User(
                              id: '',
                              name: 'Unknown',
                              email: '',
                              role: UserRole.kid,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ));
                    return Text(
                      kid.name,
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
                const Spacer(),
                Icon(
                  Icons.star,
                  size: 16,
                  color: AppConstants.secondaryColor,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  '${reward.cost} points',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.secondaryColor,
                  ),
                ),
              ],
            ),
            if (reward.type == RewardType.longTerm && reward.progress != null) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      Text(
                        '${(reward.progress! * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  LinearProgressIndicator(
                    value: reward.progress,
                    backgroundColor: AppConstants.textSecondaryColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleRewardActive(reward.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: reward.isActive 
                          ? AppConstants.errorColor 
                          : AppConstants.successColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(reward.isActive ? 'Deactivate' : 'Activate'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editReward(reward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.accentColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRewardActive(String rewardId) async {
    try {
      final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
      await rewardProvider.toggleRewardActive(rewardId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward status updated successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update reward: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _editReward(Reward reward) {
    // TODO: Implement edit reward dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit reward feature coming soon!'),
      ),
    );
  }

  void _showAddRewardDialog() {
    // TODO: Implement add reward dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add reward feature coming soon!'),
      ),
    );
  }
}
