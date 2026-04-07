// Test data fixtures for authentication tests

class TestUser {
  final String email;
  final String password;
  final String username;
  final String month;
  final String day;
  final String year;
  final String gender;

  TestUser({
    required this.email,
    required this.password,
    required this.username,
    required this.month,
    required this.day,
    required this.year,
    required this.gender,
  });
}

class InvalidPassword {
  final String password;
  final String reason;
  final String errorKey;

  InvalidPassword({
    required this.password,
    required this.reason,
    required this.errorKey,
  });
}

// Valid test user for login
const String validEmail = 'bassel@rythmify.com';
const String validPassword = 'Biso1234';

// New user for registration
final TestUser newUser = TestUser(
  email: 'newuser@rythmify.com',
  password: 'NewUser1234',
  username: 'newuser',
  month: 'March',
  day: '3',
  year: '2013',
  gender: 'Female',
);

// Existing user 
final TestUser existingUser = TestUser(
  email: 'bassel@rythmify.com',
  password: 'Biso1234',
  username: 'user-002',
  month: 'March',
  day: '5',
  year: '2013',
  gender: 'Male',
);

// User with restricted age (below 13)
final TestUser ageRestrictedUser = TestUser(
  email: 'invalidage@rythmify.com',
  password: 'InvalidAge123',
  username: 'invalidage',
  month: 'March',
  day: '3',
  year: '2020',
  gender: 'Female',
);

// Invalid password scenarios
final List<InvalidPassword> invalidPasswords = [
  InvalidPassword(
    password: 'Ab1',
    reason: 'too short',
    errorKey: 'ERROR_PASSWORD_TOO_SHORT',
  ),
  InvalidPassword(
    password: 'alllowercase1',
    reason: 'no uppercase',
    errorKey: 'ERROR_PASSWORD_NO_UPPERCASE',
  ),
  InvalidPassword(
    password: 'ALLUPPERCASE1',
    reason: 'no lowercase',
    errorKey: 'ERROR_PASSWORD_NO_LOWERCASE',
  ),
  InvalidPassword(
    password: 'NoNumberHere',
    reason: 'no number',
    errorKey: 'ERROR_PASSWORD_NO_NUMBER',
  ),
];

// Scroll test values
class ScrollValues {
  static const String days = '31';
  static const String years = '1982';
}

// Mock social auth user
class MockSocialUser {
  static const String googleEmail = 'google.user@gmail.com';
  static const String facebookEmail = 'facebook.user@facebook.com';
  static const String appleEmail = 'apple.user@icloud.com';
}
