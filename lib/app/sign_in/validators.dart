abstract class StringValidator {
  bool isValid(String value);
}

abstract class IntValidator {
  bool isValid(int value);
}

class NonEmptyStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class NonPositiveIntValidator implements IntValidator {
  @override
  bool isValid(int value) {
    return value >= 0;
  }
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = NonEmptyStringValidator();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final String invalidEmailErrorText = 'Email can\'t be empty';
  final String invalidPasswordErrorText = 'Password can\'t be empty';
}

class NameAndRatePerHourValidators {
  final StringValidator nameValidator = NonEmptyStringValidator();
  final NonPositiveIntValidator ratePerHourValidator =
      NonPositiveIntValidator();
  final String invalidNameErrorText = 'Name can\'t be empty';
  final String invalidRatePerHourErrorText = 'Rate Per Hour can\'t be empty';
}
