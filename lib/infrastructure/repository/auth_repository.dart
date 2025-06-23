import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpodtemp/domain/handlers/http_service.dart';
import 'package:riverpodtemp/infrastructure/models/data/login.dart';
import 'package:riverpodtemp/infrastructure/models/data/user.dart';
import 'package:riverpodtemp/infrastructure/models/request/sign_up_request.dart';

import '../../../domain/handlers/handlers.dart';
import '../../domain/di/injection.dart';
import '../../domain/iterface/auth.dart';
import '../models/models.dart';

class AuthRepository implements AuthRepositoryFacade {
  @override
  Future<ApiResult<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    log("a7aaaaa$email");
    final data =
        LoginModel(email: email.replaceAll('+', ""), password: password)
            .toJson();
    try {
      log("a7aaaaa$data");

      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/auth/login',
        data: data,
      );
      return ApiResult.success(
        data: LoginResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> login failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<LoginResponse>> loginWithGoogle(
      {required String email,
      required String displayName,
      required String id,
      required String avatar}) async {
    final data = {
      'email': email,
      'name': displayName,
      'id': id,
      "avatar": avatar
    };
    debugPrint('===> login request $data');
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/auth/google/callback',
        queryParameters: data,
      );
      return ApiResult.success(data: LoginResponse.fromJson(response.data));
    } catch (e) {
      debugPrint('==> login with google failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<LoginResponse>> loginWithApple(
      {required String email,
      required String displayName,
      required String id,
      required String avatar}) async {
    final data = {
      'email': email,
      'name': displayName,
      'id': id,
      "avatar": avatar
    };
    debugPrint('===> login request $data');
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/auth/apple/callback',
        queryParameters: data,
      );
      return ApiResult.success(data: LoginResponse.fromJson(response.data));
    } catch (e) {
      debugPrint('==> login with google failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<RegisterResponse>> sendOtp({required String phone}) async {
    final data = {'phone': phone.replaceAll('+', ""), "type": "firebase"};
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/auth/register',
        data: data,
      );
      return ApiResult.success(data: RegisterResponse.fromJson(response.data));
    } catch (e) {
      debugPrint('==> send otp failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<VerifyPhoneResponse>> verifyEmail({
    required String verifyCode,
  }) async {
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.get(
        '/api/v1/auth/verify/$verifyCode',
      );
      return ApiResult.success(
          data: VerifyPhoneResponse.fromJson(response.data));
    } catch (e) {
      log(((e as DioException).response?.data.toString() ?? ""));
      debugPrint('==> verify email failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<RegisterResponse>> forgotPassword({
    required String email,
  }) async {
    final data = {'email': email.replaceAll('+', "")};
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/auth/forgot/email-password',
        queryParameters: data,
      );
      return ApiResult.success(data: RegisterResponse.fromJson(response.data));
    } catch (e) {
      debugPrint('==> forgot password failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<VerifyData>> forgotPasswordConfirm({
    required String verifyCode,
    required String email,
  }) async {
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/auth/forgot/email-password/$verifyCode?email=${email.replaceAll('+', "")}',
      );

      return ApiResult.success(
        data: VerifyData.fromJson(response.data["data"]),
      );
    } catch (e) {
      debugPrint('==> forgot password confirm failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<VerifyData>> forgotPasswordConfirmWithPhone({
    required String phone,
  }) async {
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post('/api/v1/auth/forgot/password/confirm',
          data: {"phone": phone.replaceAll('+', ""), "type": "firebase"});

      return ApiResult.success(
        data: VerifyData.fromJson(response.data["data"]),
      );
    } catch (e) {
      debugPrint('==> forgot password confirm failure: $e');
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<dynamic>> sigUp({
    required String email,
  }) async {
    final data = SignUpRequest(
      email: email.contains("+") ? email.replaceAll('+', "") : email,
    );
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/auth/register',
        queryParameters: data.toJson(),
      );
      debugPrint('===> register request ${response.data}');
      return ApiResult.success(
        data: response.data,
      );
    } catch (e) {
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<VerifyData>> sigUpWithData({required UserModel user}) async {
    final data = {
      "firstname": user.firstname,
      "lastname": user.lastname,
      "phone": user.phone?.replaceAll('+', ""),
      "email": user.email,
      "password": user.password,
      "password_conformation": user.conPassword,
      if (user.referral?.isNotEmpty ?? false) 'referral': user.referral
    };
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      var res = await client.post(
        '/api/v1/auth/after-verify',
        data: data,
      );
      return ApiResult.success(
        data: VerifyData.fromJson(res.data["data"]),
      );
    } catch (e) {
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<VerifyData>> sigUpWithPhone(
      {required UserModel user}) async {
    final data = {
      "firstname": user.firstname,
      "lastname": user.lastname,
      "phone": user.phone?.replaceAll('+', ""),
      "email": user.email,
      "password": user.password,
      "password_conformation": user.conPassword,
      "type": "firebase",
      if (user.referral?.isNotEmpty ?? false) 'referral': user.referral
    };
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 30);
      var res = await client.post(
        '/api/v1/auth/verify/phone',
        data: data,
      );
      return ApiResult.success(
        data: VerifyData.fromJson(res.data["data"]),
      );
    } catch (e) {
      return ApiResult.failure(
          error: (e.runtimeType == DioException)
              ? ((e as DioException).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }
}
