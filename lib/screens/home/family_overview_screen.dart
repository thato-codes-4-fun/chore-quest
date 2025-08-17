import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/chore_provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/user_provider.dart';

class FamilyOverviewScreen extends StatefulWidget {
  const FamilyOverviewScreen({Key? key}) : super(key: key);

  @override
  State<FamilyOverviewScreen> createState() => _FamilyOverviewScreenState();
}

class _FamilyOverviewScreenState extends State<FamilyOverviewScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    
    await Future.wait([
      userProvider.loadFamilyMembers(),
      choreProvider.loadChores(
        userId: userProvider.currentUser?.id,
        userRole: userProvider.currentUser?.role,
      ),
      rewardProvider.loadRewards(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Family Overview'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildFamilyMembersSection(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildProgressSection(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.currentUser;
        if (currentUser == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'F',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${currentUser.name}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Family Overview',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFamilyMembersSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final familyMembers = userProvider.familyMembers;
        final currentUser = userProvider.currentUser;

        if (familyMembers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.family_restroom_outlined,
            title: 'No Family Members',
            subtitle: 'Family members will appear here once they join.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Members',
              style: AppConstants.headingStyle,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            // Show current user first
            if (currentUser != null) ...[
              _buildFamilyMemberCard(currentUser, isCurrentUser: true),
              const SizedBox(height: AppConstants.paddingMedium),
            ],
            // Show other family members
            ...familyMembers.map((member) => 
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                child: _buildFamilyMemberCard(member),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFamilyMemberCard(User user, {bool isCurrentUser = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: isCurrentUser 
                  ? AppConstants.primaryColor 
                  : (user.role == UserRole.parent ? AppConstants.accentColor : AppConstants.secondaryColor),
              child: Icon(
                user.role == UserRole.parent ? Icons.person : Icons.child_care,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.role == UserRole.parent ? 'Parent' : 'Kid',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: AppConstants.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.balance.toInt()} points',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Consumer2<ChoreProvider, UserProvider>(
      builder: (context, choreProvider, userProvider, child) {
        final chores = choreProvider.chores;
        final familyMembers = userProvider.familyMembers;
        
        if (chores.isEmpty) {
          return _buildEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No Chores Yet',
            subtitle: 'Create some chores to see progress here.',
          );
        }

        final totalChores = chores.length;
        final completedChores = chores.where((c) => c.status == ChoreStatus.approved).length;
        final pendingChores = chores.where((c) => c.status == ChoreStatus.completed).length;
        final progress = totalChores > 0 ? (completedChores / totalChores) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Progress',
              style: AppConstants.headingStyle,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppConstants.textSecondaryColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total',
                            totalChores.toString(),
                            Icons.assignment,
                            AppConstants.textPrimaryColor,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Completed',
                            completedChores.toString(),
                            Icons.check_circle,
                            AppConstants.successColor,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Pending',
                            pendingChores.toString(),
                            Icons.pending,
                            AppConstants.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Consumer<ChoreProvider>(
      builder: (context, choreProvider, child) {
        final recentChores = choreProvider.chores
            .where((c) => c.status == ChoreStatus.completed || c.status == ChoreStatus.approved)
            .take(5)
            .toList();

        if (recentChores.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_outlined,
            title: 'No Recent Activity',
            subtitle: 'Completed chores will appear here.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: AppConstants.headingStyle,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ...recentChores.map((chore) => _buildActivityCard(chore)),
          ],
        );
      },
    );
  }

  Widget _buildActivityCard(Chore chore) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: chore.status == ChoreStatus.approved 
              ? AppConstants.successColor 
              : AppConstants.warningColor,
          child: Icon(
            chore.status == ChoreStatus.approved ? Icons.check : Icons.pending,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          chore.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          chore.status == ChoreStatus.approved 
              ? 'Approved • +${chore.value.toInt()} points'
              : 'Pending approval • ${chore.value.toInt()} points',
        ),
        trailing: Text(
          '${chore.value.toInt()} pts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppConstants.secondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppConstants.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
