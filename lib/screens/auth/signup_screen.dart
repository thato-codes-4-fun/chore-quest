import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.parent;
  String? _selectedParentId;
  List<User> _availableParents = [];
  
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _buttonController;
  
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadParents();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _loadParents() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select()
          .eq('role', UserRole.parent.name);
      
      setState(() {
        _availableParents = response.map((json) => User.fromJson(json)).toList();
      });
    } catch (e) {
      // Handle error silently - parents list is optional
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for kid signup
    if (_selectedRole == UserRole.kid) {
      if (_selectedParentId == null || _selectedParentId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a parent for your account'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      if (_availableParents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No parents available. Please ask a parent to create an account first.'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Show loading feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              const Text('Creating your account...'),
            ],
          ),
          backgroundColor: AppConstants.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Sign up with Supabase Auth
      final authResponse = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole.name,
      );

      print('Auth response: ${authResponse?.user?.id}');
      print('Auth session: ${authResponse?.session?.accessToken}');
      print('Auth error: ${authResponse?.user?.appMetadata}');

      // Wait a moment for auth state to settle
      await Future.delayed(const Duration(milliseconds: 2000));

      // Create user profile in database using the auth response directly
      if (authResponse?.user != null) {
        print('Creating user profile for: ${authResponse!.user!.id}');
        try {
          await userProvider.createUserWithId(
            userId: authResponse!.user!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: _selectedRole,
          parentId: _selectedRole == UserRole.kid ? _selectedParentId : null,
        );
        } catch (e) {
          print('Error creating user profile: $e');
          rethrow;
        }

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: AppConstants.paddingMedium),
                  const Text('Account created successfully!'),
                ],
              ),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Auth response is null - this means signup failed
        throw Exception('Failed to create account. Please check your email and password and try again.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text('Signup failed: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            duration: const Duration(seconds: 4),
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length < 8) {
      return 'Consider using a longer password for better security';
    }
    return null;
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    
    double strength = 0.0;
    
    // Length contribution
    strength += (password.length / 12.0).clamp(0.0, 0.3);
    
    // Character variety contribution
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;
    
    return strength.clamp(0.0, 1.0);
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return AppConstants.errorColor;
    if (strength < 0.6) return AppConstants.warningColor;
    return AppConstants.successColor;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateParentSelection(String? value) {
    if (_selectedRole == UserRole.kid && (value == null || value.isEmpty)) {
      return 'Please select a parent';
    }
    return null;
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Container(
            width: 100,
            height: 100,
                    decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
              Icons.cleaning_services_rounded,
              size: 50,
                      color: Colors.white,
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(prefixIcon, color: AppConstants.primaryColor),
                  suffixIcon: isPassword || isConfirmPassword
                      ? IconButton(
                          icon: Icon(
                            (isPassword ? _obscurePassword : _obscureConfirmPassword)
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                      color: AppConstants.textSecondaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isPassword) {
                                _obscurePassword = !_obscurePassword;
                              } else {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              }
                            });
                          },
                        )
                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                borderSide: const BorderSide(
                                  color: AppConstants.primaryColor,
                                  width: 2,
                                ),
                              ),
                  errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                borderSide: const BorderSide(
                      color: AppConstants.errorColor,
                      width: 1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingMedium,
                  ),
                ),
                obscureText: (isPassword && _obscurePassword) || (isConfirmPassword && _obscureConfirmPassword),
                keyboardType: keyboardType,
                validator: validator,
                textInputAction: textInputAction,
                onChanged: (value) {
                  // Trigger validation on change for better UX
                  if (_formKey.currentState != null) {
                    _formKey.currentState!.validate();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleSelection() {
    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                          Text(
                            'I am a:',
                            style: AppConstants.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Row(
                            children: [
                              Expanded(
                        child: _buildRoleCard(
                          role: UserRole.parent,
                          title: 'Parent',
                          subtitle: 'Manage family chores',
                          icon: Icons.family_restroom_rounded,
                          isSelected: _selectedRole == UserRole.parent,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                              Expanded(
                        child: _buildRoleCard(
                          role: UserRole.kid,
                          title: 'Kid',
                          subtitle: 'Complete chores',
                          icon: Icons.child_care_rounded,
                          isSelected: _selectedRole == UserRole.kid,
                                ),
                              ),
                            ],
                          ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedRole = role;
          if (role == UserRole.parent) {
            _selectedParentId = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : AppConstants.textSecondaryColor.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppConstants.primaryColor,
              size: 32,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppConstants.textPrimaryColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentSelection() {
    if (_selectedRole != UserRole.kid) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _formAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _formAnimation.value)),
          child: Opacity(
            opacity: _formAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Parent',
                  prefixIcon: const Icon(Icons.family_restroom_rounded, color: AppConstants.primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                  borderSide: const BorderSide(
                                    color: AppConstants.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingMedium,
                  ),
                              ),
                              value: _selectedParentId,
                              validator: _validateParentSelection,
                              items: _availableParents.map((parent) {
                                return DropdownMenuItem<String>(
                                  value: parent.id,
                                  child: Text(parent.name),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedParentId = value;
                                });
                              },
                            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignupButton() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonAnimation.value,
          child: Container(
            width: double.infinity,
                            height: 56,
            margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                            child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  HapticFeedback.mediumImpact();
                  _handleSignup();
                },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                ),
                elevation: 4,
                shadowColor: AppConstants.primaryColor.withValues(alpha: 0.3),
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
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Logo and Title
                _buildAnimatedLogo(),

                          const SizedBox(height: AppConstants.paddingLarge),
                
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingSmall),
                
                Text(
                  'Join the family!',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),

                // Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: AppConstants.subheadingStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Form Fields
                      _buildFormField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: _validateName,
                        textInputAction: TextInputAction.next,
                      ),

                      _buildFormField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email address',
                        prefixIcon: Icons.email_outlined,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),

                      // Password Field with Strength Indicator
                      AnimatedBuilder(
                        animation: _formAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - _formAnimation.value)),
                            child: Opacity(
                              opacity: _formAnimation.value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppConstants.primaryColor),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                            color: AppConstants.textSecondaryColor,
                                          ),
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                          borderSide: const BorderSide(
                                            color: AppConstants.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                          borderSide: const BorderSide(
                                            color: AppConstants.errorColor,
                                            width: 1,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: AppConstants.paddingMedium,
                                          vertical: AppConstants.paddingMedium,
                                        ),
                                      ),
                                      obscureText: _obscurePassword,
                                      validator: _validatePassword,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (value) {
                                        setState(() {});
                                        if (_formKey.currentState != null) {
                                          _formKey.currentState!.validate();
                                        }
                                      },
                                    ),
                                  ),
                                  // Password Strength Indicator
                                  if (_passwordController.text.isNotEmpty) ...[
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppConstants.textSecondaryColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _getPasswordStrength(_passwordController.text),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getPasswordStrengthColor(_getPasswordStrength(_passwordController.text)),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getPasswordStrength(_passwordController.text) < 0.3 ? 'Weak' :
                                      _getPasswordStrength(_passwordController.text) < 0.6 ? 'Fair' : 'Strong',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getPasswordStrengthColor(_getPasswordStrength(_passwordController.text)),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      _buildFormField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: _validateConfirmPassword,
                        isConfirmPassword: true,
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Role Selection
                      _buildRoleSelection(),

                      // Parent Selection
                      _buildParentSelection(),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Signup Button
                      _buildSignupButton(),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
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
        ),
      ),
    );
  }
}
