

class PregnancyValidationService {
  static const int minimumPregnancyDays = 180; // Minimum 180 days between confirmation and due date
  static const int maximumPregnancyDays = 300; // Maximum reasonable pregnancy duration
  static const int typicalPregnancyDays = 280; // Standard 40 weeks

  /// Validates pregnancy confirmation date
  /// Must be in the past or today
  static ValidationResult validateConfirmationDate(DateTime? confirmationDate) {
    if (confirmationDate == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Pregnancy confirmation date is required',
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final confirmationDateOnly = DateTime(
      confirmationDate.year,
      confirmationDate.month,
      confirmationDate.day,
    );

    if (confirmationDateOnly.isAfter(today)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Pregnancy confirmation date cannot be in the future',
      );
    }

    // Check if confirmation date is too far in the past (more than 42 weeks ago)
    final maxPastDate = today.subtract(const Duration(days: 294)); // 42 weeks
    if (confirmationDateOnly.isBefore(maxPastDate)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Pregnancy confirmation date seems too far in the past',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Validates due date
  /// Must have minimum 180 days between confirmation and due date
  static ValidationResult validateDueDate(
    DateTime? dueDate,
    DateTime? confirmationDate,
  ) {
    if (dueDate == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Due date is required',
      );
    }

    if (confirmationDate == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Confirmation date is required to validate due date',
      );
    }

    final daysBetween = dueDate.difference(confirmationDate).inDays;

    if (daysBetween < minimumPregnancyDays) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Due date must be at least $minimumPregnancyDays days after confirmation date',
      );
    }

    if (daysBetween > maximumPregnancyDays) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Due date seems too far from confirmation date',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Validates last menstrual period date
  /// Should be reasonable for pregnancy calculation
  static ValidationResult validateLastMenstrualPeriod(DateTime? lmpDate) {
    if (lmpDate == null) {
      return ValidationResult(isValid: true); // LMP is optional
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lmpDateOnly = DateTime(lmpDate.year, lmpDate.month, lmpDate.day);

    if (lmpDateOnly.isAfter(today)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Last menstrual period date cannot be in the future',
      );
    }

    // Check if LMP is too far in the past (more than 44 weeks ago)
    final maxPastDate = today.subtract(const Duration(days: 308)); // 44 weeks
    if (lmpDateOnly.isBefore(maxPastDate)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Last menstrual period date seems too far in the past',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Comprehensive validation for pregnancy data
  static PregnancyValidationResult validatePregnancyData({
    DateTime? confirmationDate,
    DateTime? dueDate,
    DateTime? lastMenstrualPeriod,
    String? babyName,
  }) {
    final List<String> errors = [];
    final List<String> warnings = [];

    // Validate confirmation date
    final confirmationValidation = validateConfirmationDate(confirmationDate);
    if (!confirmationValidation.isValid) {
      errors.add(confirmationValidation.errorMessage!);
    }

    // Validate due date
    final dueDateValidation = validateDueDate(dueDate, confirmationDate);
    if (!dueDateValidation.isValid) {
      errors.add(dueDateValidation.errorMessage!);
    }

    // Validate LMP
    final lmpValidation = validateLastMenstrualPeriod(lastMenstrualPeriod);
    if (!lmpValidation.isValid) {
      errors.add(lmpValidation.errorMessage!);
    }

    // Cross-validation between dates
    if (confirmationDate != null && lastMenstrualPeriod != null) {
      final daysBetween = confirmationDate.difference(lastMenstrualPeriod).inDays;
      if (daysBetween < 14) {
        warnings.add('Confirmation date seems very close to last menstrual period');
      } else if (daysBetween > 84) { // 12 weeks
        warnings.add('Long gap between last menstrual period and confirmation');
      }
    }

    // Validate baby name (optional but should be reasonable if provided)
    if (babyName != null && babyName.trim().isEmpty) {
      warnings.add('Baby name should not be empty if provided');
    }

    return PregnancyValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Calculate automatic fallback values when validation fails
  static PregnancyFallbackData calculateFallbackData({
    DateTime? confirmationDate,
    DateTime? dueDate,
    DateTime? lastMenstrualPeriod,
  }) {
    final now = DateTime.now();
    
    // If confirmation date is invalid, use today
    final safeConfirmationDate = confirmationDate ?? now;
    
    // If due date is invalid, calculate from confirmation date (assume 8 weeks confirmation)
    DateTime safeDueDate;
    if (dueDate == null || 
        confirmationDate == null ||
        dueDate.difference(confirmationDate).inDays < minimumPregnancyDays) {
      // Assume confirmation happened at 8 weeks, so 32 weeks remaining
      safeDueDate = safeConfirmationDate.add(const Duration(days: 224)); // 32 weeks
    } else {
      safeDueDate = dueDate;
    }

    // Calculate LMP if not provided (assume confirmation at 8 weeks)
    final safeLMP = lastMenstrualPeriod ?? 
        safeConfirmationDate.subtract(const Duration(days: 56)); // 8 weeks before

    return PregnancyFallbackData(
      confirmationDate: safeConfirmationDate,
      dueDate: safeDueDate,
      lastMenstrualPeriod: safeLMP,
      wasAdjusted: confirmationDate == null || 
                   dueDate == null || 
                   lastMenstrualPeriod == null,
    );
  }

  /// Check if pregnancy is overdue
  static bool isPregnancyOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    return today.isAfter(dueDateOnly);
  }

  /// Calculate days overdue
  static int getDaysOverdue(DateTime? dueDate) {
    if (dueDate == null) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (today.isAfter(dueDateOnly)) {
      return today.difference(dueDateOnly).inDays;
    }
    
    return 0;
  }

  /// Validate and suggest corrections for user input
  static InputSuggestion getSuggestionForInput(
    String fieldName,
    dynamic value,
    Map<String, dynamic> context,
  ) {
    switch (fieldName.toLowerCase()) {
      case 'confirmationdate':
        if (value is DateTime) {
          final validation = validateConfirmationDate(value);
          if (!validation.isValid) {
            return InputSuggestion(
              isValid: false,
              suggestion: 'Try using today\'s date or a recent past date',
              errorMessage: validation.errorMessage,
            );
          }
        }
        break;
        
      case 'duedate':
        if (value is DateTime && context['confirmationDate'] is DateTime) {
          final validation = validateDueDate(value, context['confirmationDate']);
          if (!validation.isValid) {
            final confirmationDate = context['confirmationDate'] as DateTime;
            final suggestedDueDate = confirmationDate.add(const Duration(days: 224));
            return InputSuggestion(
              isValid: false,
              suggestion: 'Try ${_formatDate(suggestedDueDate)} (32 weeks from confirmation)',
              errorMessage: validation.errorMessage,
            );
          }
        }
        break;
        
      case 'lastmenstrualperiod':
        if (value is DateTime) {
          final validation = validateLastMenstrualPeriod(value);
          if (!validation.isValid) {
            return InputSuggestion(
              isValid: false,
              suggestion: 'Use a date within the last 44 weeks',
              errorMessage: validation.errorMessage,
            );
          }
        }
        break;
    }

    return InputSuggestion(isValid: true);
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

class PregnancyValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  PregnancyValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

class PregnancyFallbackData {
  final DateTime confirmationDate;
  final DateTime dueDate;
  final DateTime lastMenstrualPeriod;
  final bool wasAdjusted;

  PregnancyFallbackData({
    required this.confirmationDate,
    required this.dueDate,
    required this.lastMenstrualPeriod,
    required this.wasAdjusted,
  });
}

class InputSuggestion {
  final bool isValid;
  final String? suggestion;
  final String? errorMessage;

  InputSuggestion({
    required this.isValid,
    this.suggestion,
    this.errorMessage,
  });
}
