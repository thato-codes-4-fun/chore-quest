import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../models/models.dart';
import '../../../providers/chore_provider.dart';
import '../../../providers/user_provider.dart';

class ChoreManagementScreen extends StatefulWidget {
  const ChoreManagementScreen({super.key});

  @override
  State<ChoreManagementScreen> createState() => _ChoreManagementScreenState();
}

class _ChoreManagementScreenState extends State<ChoreManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final choreProvider = Provider.of<ChoreProvider>(context, listen: false);

    await userProvider.loadFamilyMembers();
    await choreProvider.loadChores(
      userId: userProvider.currentUser?.id,
      userRole: userProvider.currentUser?.role,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chore Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Assigned'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add chore screen
              _showAddChoreDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChoreList(null),
          _buildChoreList(ChoreStatus.assigned),
          _buildChoreList(ChoreStatus.completed),
          _buildChoreList(ChoreStatus.approved),
        ],
      ),
    );
  }

  Widget _buildChoreList(ChoreStatus? status) {
    return Consumer<ChoreProvider>(
      builder: (context, choreProvider, child) {
        List<Chore> chores;

        if (status == null) {
          chores = choreProvider.chores;
        } else {
          chores = choreProvider.getChoresByStatus(status);
        }

        if (chores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cleaning_services_outlined,
                  size: 64,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  status == null ? 'No chores yet' : 'No ${status.name} chores',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: () {
                    _showAddChoreDialog();
                  },
                  child: const Text('Add Your First Chore'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: chores.length,
            itemBuilder: (context, index) {
              final chore = chores[index];
              return _buildChoreCard(chore);
            },
          ),
        );
      },
    );
  }

  Widget _buildChoreCard(Chore chore) {
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
                        chore.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        chore.description,
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
                    color: _getStatusColor(chore.status),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    _getStatusText(chore.status),
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
                    final assignee = userProvider.familyMembers.firstWhere(
                      (user) => user.id == chore.assigneeId,
                      orElse: () => User(
                        id: '',
                        name: 'Unknown',
                        email: '',
                        role: UserRole.kid,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    return Text(
                      assignee.name,
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
                const Spacer(),
                Icon(Icons.star, size: 16, color: AppConstants.secondaryColor),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  '${chore.value} points',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.secondaryColor,
                  ),
                ),
              ],
            ),
            if (chore.status == ChoreStatus.completed) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveChore(chore.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.successColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectChore(chore.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.errorColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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

  Future<void> _approveChore(String choreId) async {
    try {
      final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
      await choreProvider.updateChoreStatus(choreId, ChoreStatus.approved);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chore approved successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve chore: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _rejectChore(String choreId) async {
    try {
      final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
      await choreProvider.updateChoreStatus(choreId, ChoreStatus.rejected);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chore rejected'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject chore: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showAddChoreDialog() {
    final _formKey = GlobalKey<FormState>();
    String choreName = '';
    String choreDescription = '';
    int choreValue = 0;
    String? selectedAssigneeId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Chore'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Chore Name',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Clean bedroom',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a chore name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          choreName = value;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Describe what needs to be done',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          choreDescription = value;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Points',
                          border: OutlineInputBorder(),
                          hintText: 'Points value',
                          prefixIcon: Icon(Icons.star),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter points value';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          choreValue = int.tryParse(value) ?? 0;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'Assign To:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final kidMembers = userProvider.familyMembers
                              .where((member) => member.role == UserRole.kid)
                              .toList();

                          if (kidMembers.isEmpty) {
                            return const Text(
                              'No family members to assign to.',
                            );
                          }

                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingMedium,
                                vertical: AppConstants.paddingSmall,
                              ),
                            ),
                            hint: const Text('Select family member'),
                            value: selectedAssigneeId,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a family member';
                              }
                              return null;
                            },
                            items: kidMembers.map((user) {
                              return DropdownMenuItem<String>(
                                value: user.id,
                                child: Text(user.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedAssigneeId = value;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final choreProvider = Provider.of<ChoreProvider>(
                          context,
                          listen: false,
                        );
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );

                        await choreProvider.createChore(
                          name: choreName,
                          description: choreDescription,
                          value: choreValue.toDouble(),
                          assigneeId: selectedAssigneeId!,
                          assignedById: userProvider.currentUser?.id ?? '',
                        );

                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chore added successfully!'),
                              backgroundColor: AppConstants.successColor,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to add chore: ${e.toString()}',
                              ),
                              backgroundColor: AppConstants.errorColor,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Add Chore'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
