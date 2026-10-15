import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/network/logging_interceptor.dart';
import 'package:geography_geyser/main.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';

enum Method { post, get, put, patch, delete }

typedef E<T> = Future<Either<String, T>>;

class DioManager {
  DioManager._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  )..interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuth = options.extra['skipAuth'] == true;
          if (!skipAuth) {
            final token = await SecureStorageHelper.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
      const LoggingInterceptor(),
    ]);

  static Dio get rawDio => _dio;

  static Future<bool>? _refreshLock;

  // ---------------------------------------------------------------------------
  // API REQUEST
  // ---------------------------------------------------------------------------
  static Future<Either<String, String>> apiRequest({
    required String url,
    required Method method,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    String? name,
    required int statusCode,
    bool skipAuth = false,
  }) async {
    try {
      final options = Options(
        method: method.name.toUpperCase(),
        headers: headers,
        extra: {'skipAuth': skipAuth, 'name': name},
        validateStatus: (status) => status != null && status < 500,
      );

      Response response = await _dio.request(
        url,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );

      // Handle 401 Unauthorized for Token Refresh
      if (response.statusCode == 401 && options.extra?['retry'] != true) {
        AppLogger.log("Token expired, attempting refresh... ($name API)");
        final isRefreshed = await _refreshToken();

        if (isRefreshed) {
          final newToken = await SecureStorageHelper.getToken();
          final retryHeaders = Map<String, dynamic>.from(headers ?? {});
          if (newToken != null && newToken.isNotEmpty) {
            retryHeaders['Authorization'] = 'Bearer $newToken';
          }

          final retryOptions = Options(
            method: method.name.toUpperCase(),
            headers: retryHeaders,
            extra: {'skipAuth': false, 'retry': true, 'name': name},
            validateStatus: (status) => status != null && status < 500,
          );

          response = await _dio.request(
            url,
            data: body,
            queryParameters: queryParameters,
            options: retryOptions,
          );
        } else {
          await _handleSessionExpired();
          return left("Session expired. Please log in again.");
        }
      }

      // Check success code
      final isValidCode = response.statusCode == statusCode ||
          response.statusCode == 200 ||
          response.statusCode == 201;

      if (isValidCode) {
        final responseString = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        return right(responseString);
      } else {
        final errorMsg = _extractFriendlyError(response);
        return left(errorMsg);
      }
    } on DioException catch (e) {
      final friendlyError = _handleDioError(e);
      return left(friendlyError);
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

  // ---------------------------------------------------------------------------
  // MULTIPART REQUEST
  // ---------------------------------------------------------------------------
  static Future<Either<String, String>> multipartRequest({
    required String url,
    required Method method,
    Map<String, String>? headers,
    Map<String, dynamic>? fields,
    List<MultipartFile>? files,
    String? filePath,
    String fileFieldName = 'profile_pic',
    String? name,
    required int statusCode,
    bool skipAuth = false,
  }) async {
    try {
      final formData = FormData();

      // Add text fields
      fields?.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add passed MultipartFiles
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          // If field name is already embedded, use it or default to fileFieldName
          formData.files.add(MapEntry(fileFieldName, file));
        }
      }

      // Add file from path if provided
      if (filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
        final fileName = filePath.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            fileFieldName,
            await MultipartFile.fromFile(filePath, filename: fileName),
          ),
        );
      }

      final options = Options(
        method: method.name.toUpperCase(),
        headers: {
          'accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          ...?headers,
        },
        extra: {'skipAuth': skipAuth, 'name': name},
        validateStatus: (status) => status != null && status < 500,
      );

      Response response = await _dio.request(
        url,
        data: formData,
        options: options,
      );

      // Handle 401 Unauthorized for Token Refresh
      if (response.statusCode == 401 && options.extra?['retry'] != true) {
        AppLogger.log("Token expired during multipart, attempting refresh... ($name API)");
        final isRefreshed = await _refreshToken();

        if (isRefreshed) {
          final newToken = await SecureStorageHelper.getToken();
          final retryHeaders = Map<String, String>.from(headers ?? {});
          if (newToken != null && newToken.isNotEmpty) {
            retryHeaders['Authorization'] = 'Bearer $newToken';
          }

          final retryOptions = Options(
            method: method.name.toUpperCase(),
            headers: {
              'accept': 'application/json',
              'ngrok-skip-browser-warning': 'true',
              ...retryHeaders,
            },
            extra: {'skipAuth': false, 'retry': true, 'name': name},
            validateStatus: (status) => status != null && status < 500,
          );

          response = await _dio.request(
            url,
            data: formData,
            options: retryOptions,
          );
        } else {
          await _handleSessionExpired();
          return left("Session expired. Please log in again.");
        }
      }

      final isValidCode = response.statusCode == statusCode ||
          response.statusCode == 200 ||
          response.statusCode == 201;

      if (isValidCode) {
        final responseString = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        return right(responseString);
      } else {
        final errorMsg = _extractFriendlyError(response);
        return left(errorMsg);
      }
    } on DioException catch (e) {
      final friendlyError = _handleDioError(e);
      return left(friendlyError);
    } catch (e) {
      return left(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // TOKEN REFRESH
  // ---------------------------------------------------------------------------
  static Future<bool> _refreshToken() async {
    if (_refreshLock != null) {
      return await _refreshLock!;
    }

    final completer = Completer<bool>();
    _refreshLock = completer.future;

    try {
      final refreshToken = await SecureStorageHelper.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.log("No refresh token found");
        completer.complete(false);
        _refreshLock = null;
        return false;
      }

      final refreshDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        ApiService.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data as Map<String, dynamic>;

        final newAccessToken = data['access_token'] ?? data['access'];
        final newRefreshToken = data['refresh_token'] ?? data['refresh'];

        if (newAccessToken != null) {
          await SecureStorageHelper.setToken(newAccessToken.toString());
          if (newRefreshToken != null) {
            await SecureStorageHelper.setRefreshToken(newRefreshToken.toString());
          }
          AppLogger.log("Token refreshed successfully via Dio");
          completer.complete(true);
          _refreshLock = null;
          return true;
        }
      }

      completer.complete(false);
      _refreshLock = null;
      return false;
    } catch (e) {
      AppLogger.error("Error during token refresh", e);
      completer.complete(false);
      _refreshLock = null;
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // SESSION EXPIRED HANDLER
  // ---------------------------------------------------------------------------
  static Future<void> _handleSessionExpired() async {
    AppLogger.log("Refresh token failed or session expired. Clearing storage.");
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
  }

  // ---------------------------------------------------------------------------
  // ERROR PARSING
  // ---------------------------------------------------------------------------
  static String _extractFriendlyError(Response response) {
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status >= 500) {
      return "Server error ($status). Please try again later.";
    }

    if (data is Map<String, dynamic>) {
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final firstVal = errors.values.first;
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
          return firstVal.toString();
        } else if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }

      final error = data['error'] ??
          data['message'] ??
          data['detail'] ??
          data['msg'] ??
          data['error_message'];

      if (error != null) {
        if (error is List && error.isNotEmpty) {
          return error.first.toString();
        }
        return error.toString();
      }
    }

    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded['error'] ??
              decoded['message'] ??
              decoded['detail'] ??
              data;
        }
      } catch (_) {
        return data;
      }
    }

    return "Request failed with status $status.";
  }

  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet connection.";
      case DioExceptionType.badResponse:
        if (e.response != null) {
          return _extractFriendlyError(e.response!);
        }
        return "Received invalid response from server.";
      case DioExceptionType.cancel:
        return "Request was cancelled.";
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true ||
            e.message?.contains('Failed host lookup') == true) {
          return "Network offline. Please enable your internet connection to continue (Required for Quizzes).";
        }
        return e.message ?? "An unexpected network error occurred.";
    }
  }
}

/// Backwards compatibility alias for existing code
typedef HttpManager = DioManager;
