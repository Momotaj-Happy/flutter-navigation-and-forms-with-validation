class WizardDraft {
  String name;
  String dob;
  String gender;
  String age;
  String email;
  String phone;
  String country;
  String password;
  String confirmPassword;
  List<String> interests;
  bool emailNotifications;
  bool newsletter;
  int currentStep;
  DateTime lastSaved;

  WizardDraft({
    this.name = '',
    this.dob = '',
    this.gender = '',
    this.age = '',
    this.email = '',
    this.phone = '',
    this.country = 'Bangladesh',
    this.password = '',
    this.confirmPassword = '',
    List<String>? interests,
    this.emailNotifications = true,
    this.newsletter = false,
    this.currentStep = 0,
    DateTime? lastSaved,
  })  : interests = interests ?? [],
        lastSaved = lastSaved ?? DateTime.now();

  bool get isEmpty =>
      name.isEmpty &&
      dob.isEmpty &&
      gender.isEmpty &&
      age.isEmpty &&
      email.isEmpty &&
      phone.isEmpty &&
      password.isEmpty &&
      interests.isEmpty;
}

/// In-memory singleton store for form drafts during the session.
class DraftManager {
  static final DraftManager _instance = DraftManager._internal();
  factory DraftManager() => _instance;
  DraftManager._internal();

  WizardDraft? _savedDraft;

  bool get hasDraft => _savedDraft != null && !_savedDraft!.isEmpty;

  WizardDraft? get draft => _savedDraft;

  void saveDraft(WizardDraft draft) {
    _savedDraft = WizardDraft(
      name: draft.name,
      dob: draft.dob,
      gender: draft.gender,
      age: draft.age,
      email: draft.email,
      phone: draft.phone,
      country: draft.country,
      password: draft.password,
      confirmPassword: draft.confirmPassword,
      interests: List<String>.from(draft.interests),
      emailNotifications: draft.emailNotifications,
      newsletter: draft.newsletter,
      currentStep: draft.currentStep,
      lastSaved: DateTime.now(),
    );
  }

  void clearDraft() {
    _savedDraft = null;
  }
}
