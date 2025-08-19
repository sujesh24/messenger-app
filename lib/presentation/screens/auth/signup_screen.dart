import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messagener_app/core/common/custom_button.dart';
import 'package:messagener_app/core/common/custom_text_Field.dart';
import 'package:messagener_app/core/utils/ui_snackbar_utils.dart';
import 'package:messagener_app/data/services/service_locator.dart';
import 'package:messagener_app/logic/cubits/auth/auth_cubit.dart';
import 'package:messagener_app/logic/cubits/auth/auth_state.dart';
import 'package:messagener_app/presentation/home/home_screen.dart';
import 'package:messagener_app/router/app_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  // validation
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    // Add more email validation logic if needed
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove all non-digit characters except +
    String cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Basic phone validation - allows international format
    final phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number (8-15 digits)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        await getIt<AuthCubit>().signUp(
          fullName: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),

      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showSnackbar(context, message: state.error!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Create Account",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please fill in the details to create your account",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      focusNode: _nameFocusNode,
                      controller: nameController,
                      validator: _validateName,
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      focusNode: _usernameFocusNode,
                      validator: _validateUsername,
                      prefixIcon: const Icon(Icons.alternate_email_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      focusNode: _emailFocusNode,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,

                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Phone Number',
                      focusNode: _phoneFocusNode,
                      validator: _validatePhone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      focusNode: _passwordFocusNode,
                      validator: _validatePassword,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_isPasswordVisible,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: 'Sign Up',
                      onPressed: _handleSignUp,
                      child: state.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to Sign in screen
                                  // Navigator.of(context).pop();
                                  getIt<AppRouter>().pop();
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
