class Validate {
  // This class used to validate the names, emails, passwords etc... before submitting them.

  static String validateUsername(String value) {
    if (value.isEmpty) return "Username can't be empty";

    if(value.trim().contains(' ') )
    return "Username can't contain any spaces";

    if (value.length < 2) return "Username must be at least 2 characters long";

    if (value.length > 30) return "Username must be less 30 characters or less";
    return null;
  }

  static String validateEmail(String value) {
    if (value.isEmpty) {
      return "Email can't be empty";
    }
    return null;
  }

  static String validateName(String value) {
    if (value.isEmpty) return "Name can't be empty";

    if (value.length < 2) return "Name must be at least 2 characters long";

    if (value.length > 30) return "Name must be less 30 characters or less";
    return null;
  }

  static String validateBirthDate(String value) {
    if (value.isEmpty) {
      return "Birth date can't be empty";
    }
    if (!RegExp(
            r'^([0-9]{4}[-/]?((0[13-9]|1[012])[-/]?(0[1-9]|[12][0-9]|30)|(0[13578]|1[02])[-/]?31|02[-/]?(0[1-9]|1[0-9]|2[0-8]))|([0-9]{2}(([2468][048]|[02468][48])|[13579][26])|([13579][26]|[02468][048]|0[0-9]|1[0-6])00)[-/]?02[-/]?29)$')
        .hasMatch(value)) return "Enter a Valid date";

    return null;
  }

  static String validatePassword(String value) {
    if (value.isEmpty) {
      return "Password can't be empty";
    }

    if (value.length < 6 || value.length > 15)
      return 'Password must be 6 - 15 characters';

    return null;
  }
}
