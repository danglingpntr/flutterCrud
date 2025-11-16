class Validators {
  Validators._();

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(text)) {
      return 'Enter a valid email';
    }
    if (!text.toLowerCase().endsWith('.edu')) {
      return 'Use your student (.edu) email';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

