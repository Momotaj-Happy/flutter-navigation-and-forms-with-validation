import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gender_selector.dart';
import '../widgets/interests_selector.dart';
import '../widgets/password_meter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _nidController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedCountry;
  String? _selectedGender;
  final List<String> _selectedInterests = [];
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _nidController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      final calculatedAge = now.year - picked.year -
          ((now.month < picked.month || (now.month == picked.month && now.day < picked.day)) ? 1 : 0);
      _ageController.text = calculatedAge.toString();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full Name
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'e.g. Tanvir Hasan',
                prefixIcon: Icons.person_outline,
                validator: Validators.nameValidator,
              ),
              const SizedBox(height: 12),

              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'name@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.emailValidation,
              ),
              const SizedBox(height: 12),

              // Bangladesh Phone
              CustomTextField(
                controller: _phoneController,
                label: 'BD Phone Number',
                hint: '017XXXXXXXX',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.bangladeshNumberValidator,
              ),
              const SizedBox(height: 12),

              // Age & NID
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _ageController,
                      label: 'Age',
                      hint: '18+',
                      prefixIcon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      validator: Validators.ageValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _nidController,
                      label: 'NID',
                      hint: '10, 13 or 17 digits',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      validator: Validators.nidValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Birth Date Picker
              CustomTextField(
                controller: _dobController,
                label: 'Birth Date',
                hint: 'Select your birth date',
                prefixIcon: Icons.cake_outlined,
                readOnly: true,
                onTap: _pickDate,
                validator: (v) => Validators.requiredValidator(v, 'Birth date'),
              ),
              const SizedBox(height: 12),

              // Searchable Country Picker
              FormField<String>(
                validator: (v) => Validators.requiredValidator(_selectedCountry, 'Country'),
                builder: (state) => InkWell(
                  onTap: () => showCountryPicker(
                    context: context,
                    showSearch: true,
                    onSelect: (Country country) {
                      setState(() => _selectedCountry = country.displayNameNoCountryCode);
                      state.didChange(_selectedCountry);
                    },
                  ),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Country',
                      prefixIcon: const Icon(Icons.public_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      errorText: state.errorText,
                    ),
                    child: Text(_selectedCountry ?? 'Select Country'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender Radios
              GenderSelector(
                selectedGender: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 16),

              // Interests Checkboxes
              InterestsSelector(
                available: _interestOptions,
                selected: _selectedInterests,
                onSelectionChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Password with Strength Meter
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '8+ chars (upper, lower, digit, symbol)',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                onChanged: (val) {
                  setState(() => _passwordStrength = Validators.getPasswordStrength(val));
                },
                validator: Validators.passwordValidator,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              PasswordStrengthMeter(strength: _passwordStrength),
              const SizedBox(height: 12),

              // Confirm Password
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _obscureConfirm,
                validator: (val) => Validators.confirmPasswordValidator(_passwordController.text, val),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}