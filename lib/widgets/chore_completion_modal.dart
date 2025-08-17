import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/constants.dart';
import '../models/models.dart';

class ChoreCompletionModal extends StatefulWidget {
  final Chore chore;
  final Function(String imageUrl) onComplete;

  const ChoreCompletionModal({
    super.key,
    required this.chore,
    required this.onComplete,
  });

  @override
  State<ChoreCompletionModal> createState() => _ChoreCompletionModalState();
}

class _ChoreCompletionModalState extends State<ChoreCompletionModal> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _notes;

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
                    _buildPhotoSection(),
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
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          const Expanded(
            child: Text(
              'Complete Chore',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo Proof',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          'Take a photo to show that you completed this chore',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        if (_selectedImage != null) ...[
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
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake Photo'),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Photo'),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppConstants.textSecondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: Border.all(
                color: AppConstants.textSecondaryColor.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: AppConstants.textSecondaryColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'No photo selected',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Photo'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextField(
          maxLines: 3,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: 'Add any notes about how you completed this chore...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: const BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading || _selectedImage == null ? null : _completeChore,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Complete Chore'),
          ),
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _completeChore() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // For now, we'll use a placeholder image URL
      // In a real app, you'd upload the image to Supabase Storage
      final imageUrl = 'placeholder_image_url_${DateTime.now().millisecondsSinceEpoch}';
      
      // Call the completion callback
      await widget.onComplete(imageUrl);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chore submitted! Waiting for parent approval.'),
            backgroundColor: AppConstants.warningColor,
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
