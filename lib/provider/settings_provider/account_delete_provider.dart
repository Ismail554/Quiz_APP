import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/models/delete_account.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;


class AccountDeleteProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<bool> deleteAccount(String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(ApiService.deleteAccount);

    
    // Create the request model
    final requestBody = DeleteAccountRequest(password: password);

    try {
      // token from SharedPreferences or SecureStorage
      final token = await SecureStorageHelper.getToken(); 

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode(requestBody.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account deleted successfully")),
          );
          // Navigate to Login or Splash screen
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
        return true;
      } else {
        // Handle API errors (e.g., wrong password)
        final errorData = jsonDecode(response.body);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? "Failed to delete account")),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}