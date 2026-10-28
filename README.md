# Flutter Navigation and Forms with Validation

A Flutter application developed for CSE 464 demonstrating form handling, input validation, multi-step wizards, navigation patterns, and state persistence.

---

## 📱 Projects Overview

The app features a home screen that allows users to navigate between two distinct form implementations:

### 1. Project 1: Single-Page Registration Form
- **All-in-one comprehensive form** built with Material Design 3.
- **Fields & Controls:**
  - Full Name validation (letters and spaces only).
  - Email Address regex validation.
  - Bangladesh Mobile Number validation (11-digit check with valid BD prefixes: 013, 014, 015, 016, 017, 018, 019).
  - Age and National ID (NID) validation (10, 13, or 17 digits).
  - Interactive Date of Birth picker with automatic age calculation.
  - Searchable country picker (`country_picker` package).
  - Gender radio selector.
  - Area of interests multi-select filter chips.
  - Password with real-time dynamic strength meter (Weak / Fair / Good / Strong).
  - Confirm password validation with toggleable visibility.

### 2. Project 2: Multi-Step Form Wizard
- **4-Step Guided Wizard** utilizing Flutter's built-in vertical `Stepper`.
- **Steps:**
  - **Step 1: Personal Information** — Full Name, Date of Birth picker, Age, and Gender selector.
  - **Step 2: Contact Details** — Email Address, Bangladesh Phone Number, and searchable Country picker.
  - **Step 3: Preferences & Settings** — Password with strength meter, Confirm Password, Interests selector, Email Notifications switch, and Newsletter switch.
  - **Step 4: Review & Submit** — Structured summary cards displaying all entered data, with **Edit** buttons next to each section to jump directly back to that step. Includes Terms & Conditions agreement checkbox.
- **Strict Navigation & Validation:** Moving to subsequent steps requires passing validation on the active step; going back is unrestricted.
- **Save Draft Functionality:** Dedicated "Save Draft" action on every step that saves progress in-memory during the session, with an automatic restore prompt when reopening the wizard.
- **Progress Indicator:** Linear progress indicator below the AppBar tracking completion percentage.

---

## 🛠️ Project Structure

```
lib/
├── main.dart                          # App entry point with MaterialApp & routes
├── models/
│   └── wizard_draft.dart              # In-memory session draft state model & manager
├── screens/
│   ├── home_screen.dart               # Project selection dashboard
│   ├── register_screen.dart           # Project 1: Single-page registration form
│   └── multi_step_wizard_screen.dart  # Project 2: Multi-step vertical form wizard
├── utils/
│   └── validators.dart                # Centralized validation rules & password scoring
└── widgets/
    ├── custom_text_field.dart         # Reusable styled text form field
    ├── gender_selector.dart           # Reusable gender radio selector
    ├── interests_selector.dart        # Reusable multi-chip filter selector
    └── password_meter.dart            # Visual password strength indicator
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+ recommended)
- Dart SDK (included with Flutter)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Momotaj-Happy/flutter-navigation-and-forms-with-validation.git
   cd flutter-navigation-and-forms-with-validation
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Run tests:**
   ```bash
   flutter test
   ```
