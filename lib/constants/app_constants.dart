import 'package:flutter/material.dart';

class AppConstants {
  // App Colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color accentColor = Color(0xFF2196F3); // Blue
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  // App Strings
  static const String appName = 'ChoreQuest';
  static const String appTagline = 'Making chores fun for the whole family!';
  
  // Placeholder text
  static const String placeholderChoreName = 'Enter chore name';
  static const String placeholderChoreDescription = 'Enter chore description';
  static const String placeholderRewardName = 'Enter reward name';
  static const String placeholderRewardDescription = 'Enter reward description';
  
  // Button text
  static const String addChore = 'Add Chore';
  static const String addReward = 'Add Reward';
  static const String completeChore = 'Complete';
  static const String approveChore = 'Approve';
  static const String rejectChore = 'Reject';
  static const String redeemReward = 'Redeem';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  
  // Status messages
  static const String choreCompleted = 'Chore completed!';
  static const String choreApproved = 'Chore approved!';
  static const String choreRejected = 'Chore rejected';
  static const String rewardRedeemed = 'Reward redeemed!';
  static const String pointsEarned = 'Points earned!';
  static const String pointsSpent = 'Points spent';
  
  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorInvalidInput = 'Please check your input and try again.';
  static const String errorInsufficientPoints = 'Insufficient points for this reward.';
  
  // Success messages
  static const String successChoreAdded = 'Chore added successfully!';
  static const String successRewardAdded = 'Reward added successfully!';
  static const String successProfileUpdated = 'Profile updated successfully!';
  
  // Navigation labels
  static const String homeLabel = 'Home';
  static const String choresLabel = 'Chores';
  static const String rewardsLabel = 'Rewards';
  static const String profileLabel = 'Profile';
  static const String settingsLabel = 'Settings';
  
  // Currency
  static const String currencySymbol = 'R';
  static const String pointsLabel = 'Points';
  
  // Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
}
