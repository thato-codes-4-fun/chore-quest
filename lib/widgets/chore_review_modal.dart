import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';

class ChoreReviewModal extends StatefulWidget {
  final Chore chore;
  final Function() onApprove;
  final Function(String reason) onReject;

  const ChoreReviewModal({
    super.key,
    required this.chore,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<ChoreReviewModal> createState() => _ChoreReviewModalState();
}

class _ChoreReviewModalState extends State<ChoreReviewModal> {
  bool _isLoading = false;
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChoreInfo(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildProofSection(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildNotesSection(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusLarge),
          topRight: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.rate_review,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          const Expanded(
            child: Text(
              'Review Chore',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoreInfo() {
    return Card(
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
                Icon(
                  Icons.cleaning_services,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    widget.chore.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.chore.value.toInt()} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              widget.chore.description,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Assigned to: ${widget.chore.assigneeId}', // You might want to show the actual name here
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proof of Completion',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        if (widget.chore.proofImageUrl != null && widget.chore.proofImageUrl!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: Border.all(
                color: AppConstants.textSecondaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Container(
                color: AppConstants.textSecondaryColor.withValues(alpha: 0.1),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo,
                        size: 48,
                        color: AppConstants.textSecondaryColor,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Proof Image Submitted',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppConstants.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: Border.all(
                color: AppConstants.errorColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: AppConstants.errorColor,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    'No proof image provided',
                    style: TextStyle(
                      color: AppConstants.errorColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    if (widget.chore.notes == null || widget.chore.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes from Child',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(
              color: AppConstants.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            widget.chore.notes!,
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _approveChore,
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _showRejectionDialog,
                icon: const Icon(Icons.cancel),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _approveChore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onApprove();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chore approved! +${widget.chore.value.toInt()} points awarded.'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving chore: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Chore'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for rejecting this chore. This will help the child understand what needs to be improved.',
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              TextField(
                controller: _rejectionReasonController,
                maxLines: 3,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                decoration: const InputDecoration(
                  hintText: 'Enter rejection reason...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rejectChore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectChore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onReject(_rejectionReasonController.text);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chore rejected. Child can resubmit with improvements.'),
            backgroundColor: AppConstants.warningColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting chore: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
