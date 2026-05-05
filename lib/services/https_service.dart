import 'dart:convert';
import 'dart:developer';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geography_geyser/main.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';

enum Method { post, get, put, patch, delete }

typedef E<T> = Future<Either<String, T>>;

class HttpManager {
  static E apiRequest({
    required String url,
    required Method method,
    Map? headers,
    Map? body,
    Map<String, dynamic>? queryParameters,
    String? name,
    required int statusCode,
  }) async {
    final token = await SecureStorageHelper.getToken();

    final headersDefault = headers?.cast<String, String>() ?? {}
      ..addAll({
        'content-type': 'application/json',
        'accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

    if (token != null && token.isNotEmpty) {
      headersDefault['Authorization'] = 'Bearer $token';
    }

    try {
      Uri uri = Uri.parse(url).replace(queryParameters: queryParameters);
      log(
        uri.toString(),
        name:
            "********** ${method.name.toUpperCase()}${name != null ? ' *** $name API **********' : " ********** "}",
      );
      if (body != null) {
        log(jsonEncode(body), name: "********** BODY **********");
      }
      if (queryParameters != null) {
        log(jsonEncode(queryParameters), name: "********** PARAMS **********");
      }

      http.Response response = await _getResponse(
        method: method,
        uri: uri,
        body: body,
        headers: headersDefault,
      );

      // Handle 401 Unauthorized for Token Refresh
      if (response.statusCode == 401) {
        log("Token expired, attempting refresh...", name: "HttpManager");
        final isRefreshed = await _refreshToken();

        if (isRefreshed) {
          final newToken = await SecureStorageHelper.getToken();
          if (newToken != null) {
            headersDefault['Authorization'] = 'Bearer $newToken';
          }

          // Retry the original request
          response = await _getResponse(
            method: method,
            uri: uri,
            body: body,
            headers: headersDefault,
          );
        } else {
          log("Refresh token failed or not found. Clearing storage.",
              name: "HttpManager");
          await SecureStorageHelper.clearAll();

          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            CustomSnackBar.show(
              context,
              message: "Your session expired. Please login again",
              isError: true,
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }

          return left("Session expired. Please log in again.");
        }
      }

      log(
        response.statusCode.toString(),
        name: "********** STATUS CODE **********",
      );
      if (response.statusCode == statusCode || response.statusCode == 201 || response.statusCode == 200) {
        log(
          utf8.decode(response.bodyBytes),
          name: "********** RESULT **********",
        );

        return right(utf8.decode(response.bodyBytes));
      } else {
        log(response.body, name: "${response.statusCode}");
        final responseData = jsonDecode(response.body);
        final error = responseData['error'] ??
            responseData['message'] ??
            responseData['detail'] ??
            "An unknown error occurred";
        return left(error.toString());
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return left(
          "Network offline. Please enable your internet connection to continue (Required for Quizzes).",
        );
      }
      return left(e.toString());
    }
  }

  static E multipartRequest({
    required String url,
    required Method method,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    String? name,
    required int statusCode,
  }) async {
    final token = await SecureStorageHelper.getToken();

    final headersDefault = headers ?? {}
      ..addAll({
        'accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

    if (token != null && token.isNotEmpty) {
      headersDefault['Authorization'] = 'Bearer $token';
    }

    try {
      Uri uri = Uri.parse(url);
      log(
        uri.toString(),
        name:
            "********** MULTIPART ${method.name.toUpperCase()}${name != null ? ' *** $name API **********' : " ********** "}",
      );

      http.Response response = await _getMultipartResponse(
        method: method,
        uri: uri,
        headers: headersDefault,
        fields: fields,
        files: files,
      );

      // Handle 401 Unauthorized for Token Refresh
      if (response.statusCode == 401) {
        log("Token expired, attempting refresh...", name: "HttpManager");
        final isRefreshed = await _refreshToken();

        if (isRefreshed) {
          final newToken = await SecureStorageHelper.getToken();
          if (newToken != null) {
            headersDefault['Authorization'] = 'Bearer $newToken';
          }

          // Retry the original request
          response = await _getMultipartResponse(
            method: method,
            uri: uri,
            headers: headersDefault,
            fields: fields,
            files: files,
          );
        } else {
          log("Refresh token failed or not found. Clearing storage.",
              name: "HttpManager");
          await SecureStorageHelper.clearAll();

          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            CustomSnackBar.show(
              context,
              message: "Your session expired. Please login again",
              isError: true,
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }

          return left("Session expired. Please log in again.");
        }
      }

      log(
        response.statusCode.toString(),
        name: "********** STATUS CODE **********",
      );
      if (response.statusCode == statusCode || response.statusCode == 200 || response.statusCode == 201) {
        log(
          utf8.decode(response.bodyBytes),
          name: "********** RESULT **********",
        );

        return right(utf8.decode(response.bodyBytes));
      } else {
        log(response.body, name: "${response.statusCode}");
        final responseData = jsonDecode(response.body);
        final error = responseData['error'] ??
            responseData['message'] ??
            responseData['detail'] ??
            "An unknown error occurred";
        return left(error.toString());
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorageHelper.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log("No refresh token found", name: "HttpManager");
        return false;
      }

      final response = await http.post(
        Uri.parse(ApiService.refreshToken),
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({"refresh_token": refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken != null) {
          await SecureStorageHelper.setToken(newAccessToken);
          if (newRefreshToken != null) {
            await SecureStorageHelper.setRefreshToken(newRefreshToken);
          }
          log("Token refreshed successfully", name: "HttpManager");
          return true;
        }
      }

      return false;
    } catch (e) {
      log("Error during token refresh: $e", name: "HttpManager");
      return false;
    }
  }
}

Future<http.Response> _getResponse({
  required Uri uri,
  required Method method,
  final headers,
  Map? body,
}) async {
  switch (method) {
    case Method.get:
      return await http.get(uri, headers: headers);
    case Method.post:
      return await http.post(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    case Method.delete:
      return await http.delete(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    case Method.patch:
      return await http.patch(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
    case Method.put:
      return await http.put(
        uri,
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      );
  }
}

Future<http.Response> _getMultipartResponse({
  required Uri uri,
  required Method method,
  required Map<String, String> headers,
  Map<String, String>? fields,
  List<http.MultipartFile>? files,
}) async {
  var request = http.MultipartRequest(method.name.toUpperCase(), uri);
  request.headers.addAll(headers);
  if (fields != null) {
    request.fields.addAll(fields);
  }
  if (files != null) {
    request.files.addAll(files);
  }
  var streamedResponse = await request.send();
  return await http.Response.fromStream(streamedResponse);
}
