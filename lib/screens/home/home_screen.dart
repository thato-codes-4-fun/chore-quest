import 'package:chore_quest/models/chore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/chore_provider.dart';
import '../../providers/reward_provider.dart';
import '../auth/login_screen.dart';
import 'parent/chore_management_screen.dart';
import 'parent/reward_management_screen.dart';
import 'family_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ParentDashboard(),
    const ChoreManagementScreen(),
    const RewardManagementScreen(),
    const FamilyOverviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Chores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Family',
          ),
        ],
      ),
    );
  }
}

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);

    await userProvider.loadFamilyMembers();
    await choreProvider.loadChores(
      userId: userProvider.currentUser?.id,
      userRole: userProvider.currentUser?.role,
    );
    await rewardProvider.loadRewards(createdById: userProvider.currentUser?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChoreQuest'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: AppConstants.paddingLarge),

              // Quick Stats
              _buildQuickStats(),
              const SizedBox(height: AppConstants.paddingLarge),

              // Recent Activity
              _buildRecentActivity(),
              const SizedBox(height: AppConstants.paddingLarge),

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.currentUser;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppConstants.primaryColor,
                      child: Text(
                        currentUser?.name.substring(0, 1).toUpperCase() ?? 'P',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${currentUser?.name ?? 'Parent'}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Let\'s make chores fun for the whole family',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<ChoreProvider, UserProvider>(
      builder: (context, choreProvider, userProvider, child) {
        final pendingChores = choreProvider
            .getChoresByStatus(ChoreStatus.completed)
            .length;
        final totalKids = userProvider.familyMembers.length;
        final activeRewards = 0; // TODO: Implement reward counting

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending Approvals',
                pendingChores.toString(),
                Icons.pending_actions,
                AppConstants.warningColor,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard(
                'Family Members',
                totalKids.toString(),
                Icons.family_restroom,
                AppConstants.accentColor,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard(
                'Active Rewards',
                activeRewards.toString(),
                Icons.card_giftcard,
                AppConstants.secondaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full activity log
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Consumer<ChoreProvider>(
              builder: (context, choreProvider, child) {
                final recentChores = choreProvider.chores.take(3).toList();

                if (recentChores.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      child: Text(
                        'No recent activity',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: recentChores.map((chore) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(chore.status),
                        child: Icon(
                          _getStatusIcon(chore.status),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(chore.name),
                      subtitle: Text('${chore.value} points'),
                      trailing: Text(
                        _getStatusText(chore.status),
                        style: TextStyle(
                          color: _getStatusColor(chore.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Add Chore',
                    Icons.add_task,
                    AppConstants.primaryColor,
                    () {
                      // TODO: Navigate to add chore screen
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildActionButton(
                    'Add Reward',
                    Icons.card_giftcard,
                    AppConstants.secondaryColor,
                    () {
                      // TODO: Navigate to add reward screen
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Review Chores',
                    Icons.pending_actions,
                    AppConstants.warningColor,
                    () {
                      // TODO: Navigate to review chores screen
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildActionButton(
                    'Family Settings',
                    Icons.settings,
                    AppConstants.accentColor,
                    () {
                      // TODO: Navigate to family settings screen
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ChoreStatus status) {
    switch (status) {
      case ChoreStatus.assigned:
        return AppConstants.accentColor;
      case ChoreStatus.completed:
        return AppConstants.warningColor;
      case ChoreStatus.approved:
        return AppConstants.successColor;
      case ChoreStatus.rejected:
        return AppConstants.errorColor;
      default:
        return AppConstants.accentColor;
    }
  }

  IconData _getStatusIcon(ChoreStatus status) {
    switch (status) {
      case ChoreStatus.assigned:
        return Icons.assignment;
      case ChoreStatus.completed:
        return Icons.pending_actions;
      case ChoreStatus.approved:
        return Icons.check_circle;
      case ChoreStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusText(ChoreStatus status) {
    switch (status) {
      case ChoreStatus.assigned:
        return 'Assigned';
      case ChoreStatus.completed:
        return 'Pending';
      case ChoreStatus.approved:
        return 'Approved';
      case ChoreStatus.rejected:
        return 'Rejected';
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
