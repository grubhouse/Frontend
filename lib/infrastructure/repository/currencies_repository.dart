import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpodtemp/domain/di/injection.dart';
import 'package:riverpodtemp/domain/handlers/http_service.dart';
import 'package:riverpodtemp/domain/iterface/currencies.dart';
import 'package:riverpodtemp/infrastructure/models/models.dart';
import '../../../domain/handlers/handlers.dart';

class CurrenciesRepository implements CurrenciesRepositoryFacade {
  @override
  Future<ApiResult<CurrenciesResponse>> getCurrencies() async {
    try {
      final client = inject<HttpService>().client(requireAuth: false)
        ..options.connectTimeout = const Duration(seconds: 60)
        ..options.receiveTimeout = const Duration(seconds: 60);
      final response = await client.get('/api/v1/rest/currencies/active');
      return ApiResult.success(
        data: CurrenciesResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get currencies failure: $e');
      return ApiResult.failure(error: (e.runtimeType == DioException)
              ? ((e as DioException ).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",statusCode: NetworkExceptions.getDioStatus(e));
    }
  }
}
