// // lib/services/auth_service.dart
// import 'dart:async';

// class AuthResult {
//   final bool success;
//   final String? message;

//   AuthResult({required this.success, this.message});
// }

// class AuthService {
//   // Mock data - replace with actual API calls in a real app
//   static const String validEmail = 'ismail554@gmail.com';
//   static const String validPassword = '586908';

//   /// Simulates a network login request.
//   Future<AuthResult> login(String email, String password) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(seconds: 2));

//     if (email.trim().isEmpty || password.trim().isEmpty) {
//       return AuthResult(success: false, message: 'Please fill in all fields');
//     }

//     if (email.trim() == validEmail && password.trim() == validPassword) {
//       // Success case
//       return AuthResult(success: true);
//     } else if (email.trim() != validEmail) {
//       // Invalid email case
//       return AuthResult(success: false, message: 'Invalid email address');
//     } else {
//       // Invalid password case
//       return AuthResult(success: false, message: 'Invalid password');
//     }
//   }
// }