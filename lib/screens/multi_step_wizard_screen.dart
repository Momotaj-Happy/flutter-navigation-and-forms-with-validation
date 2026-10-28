import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/wizard_draft.dart';
import '../utils/validators.dart';
import '../widgets/gender_selector.dart';
import '../widgets/interests_selector.dart';
import '../widgets/password_meter.dart';

class MultiStepWizardScreen extends StatefulWidget {
  const MultiStepWizardScreen({super.key});

  @override
  State<MultiStepWizardScreen> createState() => _MultiStepWizardScreenState();
}

class _MultiStepWizardScreenState extends State<MultiStepWizardScreen> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form keys for validation per step
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  String? _selectedGender;
  String? _selectedCountry = 'Bangladesh';
  final List<String> _selectedInterests = [];
  bool _emailNotifications = true;
  bool _newsletter = false;
  bool _agreeToTerms = false;
  bool _termsError = false;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0.0;

  final List<String> _interestOptions = [
    'Technology',
    'Mobile Dev',
    'AI & ML',
    'UI/UX Design',
    'Gaming',
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);

    // If draft exists, show a simple SnackBar on load allowing restore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (DraftManager().hasDraft) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Found a saved draft from this session.'),
            action: SnackBarAction(
              label: 'Restore',
              onPressed: _restoreDraft,
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = Validators.getPasswordStrength(_passwordController.text);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      final calculatedAge = now.year -
          picked.year -
          ((now.month < picked.month ||
                  (now.month == picked.month && now.day < picked.day))
              ? 1
              : 0);
      _ageController.text = calculatedAge.toString();
      setState(() {});
    }
  }

  void _saveDraft() {
    final draft = WizardDraft(
      name: _nameController.text,
      dob: _dobController.text,
      gender: _selectedGender ?? '',
      age: _ageController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      country: _selectedCountry ?? 'Bangladesh',
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      interests: _selectedInterests,
      emailNotifications: _emailNotifications,
      newsletter: _newsletter,
      currentStep: _currentStep,
      lastSaved: DateTime.now(),
    );

    DraftManager().saveDraft(draft);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Draft saved at Step ${_currentStep + 1}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _restoreDraft() {
    final draft = DraftManager().draft;
    if (draft == null) return;

    setState(() {
      _nameController.text = draft.name;
      _dobController.text = draft.dob;
      _ageController.text = draft.age;
      _selectedGender = draft.gender.isNotEmpty ? draft.gender : null;
      _emailController.text = draft.email;
      _phoneController.text = draft.phone;
      _selectedCountry = draft.country.isNotEmpty ? draft.country : 'Bangladesh';
      _passwordController.text = draft.password;
      _confirmPasswordController.text = draft.confirmPassword;
      _selectedInterests.clear();
      _selectedInterests.addAll(draft.interests);
      _emailNotifications = draft.emailNotifications;
      _newsletter = draft.newsletter;
      _currentStep = draft.currentStep.clamp(0, 3);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Draft restored to Step ${_currentStep + 1}'),
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1Key.currentState?.validate() ?? false;
      case 1:
        return _step2Key.currentState?.validate() ?? false;
      case 2:
        return _step3Key.currentState?.validate() ?? false;
      case 3:
        if (!_agreeToTerms) {
          setState(() => _termsError = true);
          return false;
        }
        setState(() => _termsError = false);
        return true;
      default:
        return false;
    }
  }

  void _onStepContinue() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep += 1);
      } else {
        _submitForm();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onStepTapped(int step) {
    if (step < _currentStep) {
      setState(() => _currentStep = step);
    } else if (step == _currentStep + 1 && _validateCurrentStep()) {
      setState(() => _currentStep = step);
    }
  }

  void _jumpToStep(int step) {
    setState(() => _currentStep = step);
  }

  void _submitForm() {
    if (!_validateCurrentStep()) return;

    DraftManager().clearDraft();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Form Submitted Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_nameController.text}'),
            const SizedBox(height: 4),
            Text('Email: ${_emailController.text}'),
            const SizedBox(height: 4),
            Text('Phone: ${_phoneController.text}'),
            const SizedBox(height: 4),
            Text('Country: ${_selectedCountry ?? 'Bangladesh'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Step Form Wizard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Draft',
            onPressed: _saveDraft,
          ),
        ],
      ),
      body: Column(
        children: [
          // Simple Progress Indicator
          LinearProgressIndicator(value: progress),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${(progress * 100).toInt()}%'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Vertical Stepper
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              onStepTapped: _onStepTapped,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(
                          _currentStep == _totalSteps - 1 ? 'Submit' : 'Continue',
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _saveDraft,
                        child: const Text('Save Draft'),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                // STEP 1
                Step(
                  title: const Text('Personal Information'),
                  subtitle: const Text('Name, Date of Birth, Gender, Age'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: Form(
                    key: _step1Key,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your name',
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.nameValidator,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: _pickDate,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            hintText: 'Select date of birth',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (v) =>
                              Validators.requiredValidator(v, 'Date of birth'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            hintText: 'Enter your age',
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.ageValidator,
                        ),
                        const SizedBox(height: 12),
                        GenderSelector(
                          selectedGender: _selectedGender,
                          onChanged: (val) => setState(() => _selectedGender = val),
                        ),
                      ],
                    ),
                  ),
                ),

                // STEP 2
                Step(
                  title: const Text('Contact Details'),
                  subtitle: const Text('Email, Phone, Country'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: Form(
                    key: _step2Key,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.emailValidation,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '017XXXXXXXX',
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.bangladeshNumberValidator,
                        ),
                        const SizedBox(height: 12),
                        FormField<String>(
                          validator: (v) =>
                              Validators.requiredValidator(_selectedCountry, 'Country'),
                          builder: (state) => InkWell(
                            onTap: () => showCountryPicker(
                              context: context,
                              showSearch: true,
                              onSelect: (Country country) {
                                setState(() => _selectedCountry = country.name);
                                state.didChange(_selectedCountry);
                              },
                            ),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Country',
                                border: const OutlineInputBorder(),
                                errorText: state.errorText,
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                              child: Text(_selectedCountry ?? 'Select Country'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // STEP 3
                Step(
                  title: const Text('Preferences & Settings'),
                  subtitle: const Text('Password, Interests, Notifications'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                  content: Form(
                    key: _step3Key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Min 8 characters',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: Validators.passwordValidator,
                        ),
                        PasswordStrengthMeter(strength: _passwordStrength),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) => Validators.confirmPasswordValidator(
                            _passwordController.text,
                            v,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InterestsSelector(
                          available: _interestOptions,
                          selected: _selectedInterests,
                          onSelectionChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Email Notifications'),
                          value: _emailNotifications,
                          onChanged: (val) =>
                              setState(() => _emailNotifications = val),
                        ),
                        SwitchListTile(
                          title: const Text('Newsletter Updates'),
                          value: _newsletter,
                          onChanged: (val) => setState(() => _newsletter = val),
                        ),
                      ],
                    ),
                  ),
                ),

                // STEP 4
                Step(
                  title: const Text('Review & Submit'),
                  subtitle: const Text('Verify information before submitting'),
                  isActive: _currentStep >= 3,
                  state: StepState.indexed,
                  content: Form(
                    key: _step4Key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Section 1 Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Personal Information',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                      onPressed: () => _jumpToStep(0),
                                      child: const Text('Edit'),
                                    ),
                                  ],
                                ),
                                Text('Name: ${_nameController.text}'),
                                Text('Date of Birth: ${_dobController.text}'),
                                Text('Age: ${_ageController.text}'),
                                Text(
                                    'Gender: ${_selectedGender ?? 'Not specified'}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Section 2 Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Contact Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                      onPressed: () => _jumpToStep(1),
                                      child: const Text('Edit'),
                                    ),
                                  ],
                                ),
                                Text('Email: ${_emailController.text}'),
                                Text('Phone: ${_phoneController.text}'),
                                Text(
                                    'Country: ${_selectedCountry ?? 'Bangladesh'}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Section 3 Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Preferences',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                      onPressed: () => _jumpToStep(2),
                                      child: const Text('Edit'),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Interests: ${_selectedInterests.isEmpty ? 'None' : _selectedInterests.join(', ')}',
                                ),
                                Text(
                                  'Notifications: ${_emailNotifications ? 'Yes' : 'No'}',
                                ),
                                Text(
                                  'Newsletter: ${_newsletter ? 'Yes' : 'No'}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Terms
                        CheckboxListTile(
                          title: const Text(
                            'I agree to the Terms and Conditions',
                            style: TextStyle(fontSize: 13),
                          ),
                          value: _agreeToTerms,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() {
                              _agreeToTerms = val ?? false;
                              if (_agreeToTerms) _termsError = false;
                            });
                          },
                        ),
                        if (_termsError)
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Please agree to the terms to submit',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
