import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
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
    _emailController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
              const Text('Signing you in...'),
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

      await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted && authProvider.isAuthenticated) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppConstants.paddingMedium),
                const Text('Welcome back!'),
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

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
                  child: Text('Login failed: ${e.toString()}'),
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
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
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
                  suffixIcon: isPassword
                      ? IconButton(
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
                obscureText: isPassword && _obscurePassword,
                keyboardType: keyboardType,
                validator: validator,
                textInputAction: textInputAction,
                onFieldSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
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

  Widget _buildLoginButton() {
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
                _handleLogin();
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
                      'Sign In',
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
                    'Welcome back!',
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
                        'Sign In',
                        style: AppConstants.subheadingStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Form Fields
                      _buildFormField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email address',
                        prefixIcon: Icons.email_outlined,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),

                      _buildFormField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outlined,
                        validator: _validatePassword,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: _handleLogin,
                  ),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Navigate to forgot password screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forgot password feature coming soon!'),
                                backgroundColor: AppConstants.primaryColor,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                          color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Login Button
                      _buildLoginButton(),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
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
