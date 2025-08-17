import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chore_provider.dart';
import '../../../providers/reward_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../screens/splash_screen.dart';
import '../../../widgets/chore_card.dart';
import '../../../widgets/reward_card.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    
    await Future.wait([
      choreProvider.loadChores(),
      rewardProvider.loadRewards(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(
                      currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'K',
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
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        Text(
                          currentUser.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
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
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${currentUser.balance.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildProgressBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return Consumer<ChoreProvider>(
      builder: (context, choreProvider, child) {
        final assignedChores = choreProvider.chores.where((chore) => 
          chore.status == ChoreStatus.assigned || chore.status == ChoreStatus.completed
        ).toList();
        
        final completedChores = assignedChores.where((chore) => 
          chore.status == ChoreStatus.completed
        ).length;
        
        final totalChores = assignedChores.length;
        final progress = totalChores > 0 ? completedChores / totalChores : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chore Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                Text(
                  '$completedChores/$totalChores completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppConstants.textSecondaryColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              minHeight: 8,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildChoresTab();
      case 1:
        return _buildRewardsTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildChoresTab();
    }
  }

  Widget _buildChoresTab() {
    return Consumer<ChoreProvider>(
      builder: (context, choreProvider, child) {
        final assignedChores = choreProvider.chores.where((chore) => 
          chore.status == ChoreStatus.assigned || chore.status == ChoreStatus.completed
        ).toList();

        if (assignedChores.isEmpty) {
          return _buildEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No Chores Assigned',
            subtitle: 'Your parent hasn\'t assigned any chores yet.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: assignedChores.length,
          itemBuilder: (context, index) {
            final chore = assignedChores[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              child: ChoreCard(
                chore: chore,
                onTap: () => _showChoreDetails(chore),
                showActions: chore.status == ChoreStatus.assigned,
                onComplete: () => _completeChore(chore),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRewardsTab() {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, child) {
        final availableRewards = rewardProvider.rewards.where((reward) => 
          reward.isActive
        ).toList();

        if (availableRewards.isEmpty) {
          return _buildEmptyState(
            icon: Icons.card_giftcard_outlined,
            title: 'No Rewards Available',
            subtitle: 'Your parent hasn\'t created any rewards yet.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: availableRewards.length,
          itemBuilder: (context, index) {
            final reward = availableRewards[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              child: RewardCard(
                reward: reward,
                onTap: () => _showRewardDetails(reward),
                onRedeem: () => _redeemReward(reward),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.currentUser;
        if (currentUser == null) return const SizedBox.shrink();

        return ListView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          children: [
            _buildProfileCard(currentUser),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildStatsCard(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildActionsCard(),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppConstants.primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'K',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Kid',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: AppConstants.subheadingStyle,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.stars,
                    title: 'Balance',
                    value: '${Provider.of<UserProvider>(context, listen: false).currentUser?.balance.toInt() ?? 0}',
                    color: AppConstants.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    title: 'Completed',
                    value: '${Provider.of<ChoreProvider>(context, listen: false).chores.where((c) => c.status == ChoreStatus.completed).length}',
                    color: AppConstants.successColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.pending,
                    title: 'Pending',
                    value: '${Provider.of<ChoreProvider>(context, listen: false).chores.where((c) => c.status == ChoreStatus.assigned).length}',
                    color: AppConstants.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: AppConstants.subheadingStyle,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ListTile(
              leading: const Icon(Icons.logout, color: AppConstants.errorColor),
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppConstants.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: AppConstants.textSecondaryColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Chores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard),
          label: 'Rewards',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showChoreDetails(Chore chore) {
    // TODO: Implement chore details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chore: ${chore.name}'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  void _completeChore(Chore chore) async {
    try {
      final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
      await choreProvider.completeChore(chore.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chore completed! +${chore.value} points'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing chore: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showRewardDetails(Reward reward) {
    // TODO: Implement reward details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reward: ${reward.name}'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  void _redeemReward(Reward reward) async {
    try {
      final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final currentUser = userProvider.currentUser;
      if (currentUser == null) return;

      if (currentUser.balance < reward.cost) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not enough points! You need ${reward.cost} points.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        return;
      }

      await rewardProvider.redeemReward(reward.id, currentUser.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reward redeemed! -${reward.cost} points'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error redeeming reward: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _signOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      await authProvider.signOut();
      await userProvider.clearAllCache();
      
      if (mounted) {
        // Navigate to splash screen which will handle auth state
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
}
