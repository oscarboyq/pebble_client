import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/auth_service.dart';
import 'package:pebble_type/feature/auth/widgets/register_form.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final GlobalKey<FormState> _step1FormKey, _step2FormKey, _step3FormKey;

  late final TextEditingController _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _passwordCtrl,
      _phoneCtrl;

  late final TextEditingController _addressCtrl,
      _address2Ctrl,
      _cityCtrl,
      _stateCtrl,
      _zipCtrl;

  String _selectedCountry = 'United States';

  bool _termsAccepted = false;
  int _currentStep = 1;

  String? _selectedGender;
  DateTime? _selectedBirthday;
  bool _newsletterOptIn = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _address2Ctrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _zipCtrl = TextEditingController();
    _step1FormKey = GlobalKey<FormState>();
    _step2FormKey = GlobalKey<FormState>();
    _step3FormKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    final currentKey = switch (_currentStep) {
      1 => _step1FormKey,
      2 => _step2FormKey,
      3 => _step3FormKey,
      _ => throw Exception('Invalid step'),
    };

    if (!(currentKey.currentState?.validate() ?? false)) return;

    if (_currentStep == 1 && !_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await AuthService.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        gender: _selectedGender ?? '',
        birthday: _selectedBirthday,
        newsletterOptIn: _newsletterOptIn,
        addressLine1: _addressCtrl.text.trim(),
        addressLine2: _address2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        zipCode: _zipCtrl.text.trim(),
        country: _selectedCountry,
      );

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } on DioException catch (e) {
      final errors = e.response?.data;
      String message = 'Registration failed. Please try again.';
      if (errors is Map) {
        final firstKey = errors.keys.first;
        final firstError = errors[firstKey];
        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: RegisterForm(
                formKey: switch (_currentStep) {
                  1 => _step1FormKey,
                  2 => _step2FormKey,
                  3 => _step3FormKey,
                  _ => throw Exception('Invalid step'),
                },
                firstNameCtrl: _firstNameCtrl,
                lastNameCtrl: _lastNameCtrl,
                emailCtrl: _emailCtrl,
                passwordCtrl: _passwordCtrl,
                phoneCtrl: _phoneCtrl,
                termsAccepted: _termsAccepted,
                currentStep: _currentStep,
                addressCtrl: _addressCtrl,
                address2Ctrl: _address2Ctrl,
                cityCtrl: _cityCtrl,
                stateCtrl: _stateCtrl,
                zipCtrl: _zipCtrl,
                selectedCountry: _selectedCountry,
                onCountryChanged: (value) {
                  setState(() {
                    _selectedCountry = value ?? 'United States';
                  });
                },
                onTermsChanged: (value) {
                  setState(() {
                    _termsAccepted = value ?? false;
                  });
                },
                selectedGender: _selectedGender,
                selectedBirthday: _selectedBirthday,
                newsletterOptIn: _newsletterOptIn,
                isLoading: _isLoading,
                onBirthdayChanged: (date) {
                  setState(() {
                    _selectedBirthday = date;
                  });
                },
                onGenderChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                onNewsletterChanged: (value) {
                  setState(() {
                    _newsletterOptIn = value ?? _newsletterOptIn;
                  });
                },
                onNext: _goNext,
                onBack: _goBack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
