// ignore_for_file: unrelated_type_equality_checks

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpodtemp/domain/di/injection.dart';
import 'package:riverpodtemp/domain/handlers/http_service.dart';
import 'package:riverpodtemp/domain/iterface/orders.dart';
import 'package:riverpodtemp/infrastructure/models/data/order_active_model.dart';
import 'package:riverpodtemp/infrastructure/models/data/refund_data.dart';
import 'package:riverpodtemp/infrastructure/models/models.dart';
import 'package:riverpodtemp/infrastructure/services/app_constants.dart';
import 'package:riverpodtemp/infrastructure/services/local_storage.dart';
import '../../../domain/handlers/handlers.dart';
import '../models/data/get_calculate_data.dart';

class OrdersRepository implements OrdersRepositoryFacade {
  @override
  Future<ApiResult<OrderActiveModel>> createOrder(
      OrderBodyData orderBody) async {
    try {
      final client = inject<HttpService>().client(requireAuth: true)..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/dashboard/user/orders',
        data: orderBody.toJson(),
      );
      return ApiResult.success(
        data: OrderActiveModel.fromJson(response.data),
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
  Future<ApiResult<OrderPaginateResponse>> getCompletedOrders(int page) async {
    final data = {
      if (LocalStorage.getSelectedCurrency() != null)
        'currency_id': LocalStorage.getSelectedCurrency()?.id,
      'lang': LocalStorage.getLanguage()?.locale,
      'page': page,
      'status': 'completed',
    };
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.get(
        '/api/v1/dashboard/user/orders/paginate',
        queryParameters: data,
      );
      return ApiResult.success(
        data: OrderPaginateResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get completed orders failure: $e');
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
  Future<ApiResult<OrderPaginateResponse>> getActiveOrders(int page) async {
    final data = {
      if (LocalStorage.getSelectedCurrency() != null)
        'currency_id': LocalStorage.getSelectedCurrency()?.id,
      'lang': LocalStorage.getLanguage()?.locale,
      'page': page,
      'statuses[0]': "new",
      "statuses[1]": "accepted",
      "statuses[2]": "cooking",
      "statuses[3]": "ready",
      "statuses[4]": "on_a_way",
      "order_statuses": true,
      "perPage": 10
    };
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.get(
        '/api/v1/dashboard/user/orders/paginate',
        queryParameters: data,
      );
      return ApiResult.success(
        data: OrderPaginateResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get open orders failure: $e');
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
  Future<ApiResult<OrderPaginateResponse>> getHistoryOrders(int page) async {
    final data = {
      if (LocalStorage.getSelectedCurrency() != null)
        'currency_id': LocalStorage.getSelectedCurrency()?.id,
      'lang': LocalStorage.getLanguage()?.locale,
      'statuses[0]': "delivered",
      "statuses[1]": "canceled",
      "order_statuses": true,
      "perPage": 10,
      "page": page
    };
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.get(
        '/api/v1/dashboard/user/orders/paginate',
        queryParameters: data,
      );
      return ApiResult.success(
        data: OrderPaginateResponse.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get canceled orders failure: $e');
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
  Future<ApiResult<OrderActiveModel>> getSingleOrder(num orderId) async {
    final data = {
      if (LocalStorage.getSelectedCurrency() != null)
        'currency_id': LocalStorage.getSelectedCurrency()?.id,
      'lang': LocalStorage.getLanguage()?.locale
    };
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.get(
        '/api/v1/dashboard/user/orders/$orderId',
        queryParameters: data,
      );
      return ApiResult.success(
        data: OrderActiveModel.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get single order failure: $e');
      return ApiResult.failure(
          error: (e as DioException).type == DioExceptionType.badResponse
              ? ((e).response?.data["message"] == "Bad request."
                  ? (e.response?.data["params"] as Map).values.first[0]
                  : e.response?.data["message"])
              : "",
          statusCode: NetworkExceptions.getDioStatus(e));
    }
  }

  @override
  Future<ApiResult<void>> addReview(
    num orderId, {
    required double rating,
    required String comment,
  }) async {
    final data = {'rating': rating, if (comment != "") 'comment': comment};
    try {
      final client = inject<HttpService>().client(requireAuth: true)..options.connectTimeout = const Duration(seconds: 30);
      await client.post(
        '/api/v1/dashboard/user/orders/review/$orderId',
        data: data,
      );
      return const ApiResult.success(data: null);
    } catch (e) {
      debugPrint('==> add order review failure: $e');
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
  Future<ApiResult<String>> process(
      OrderBodyData orderBody, String name) async {
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      var res = await client.get('/api/v1/dashboard/user/order-$name-process',
          data: orderBody.toJson());
      return ApiResult.success(data: res.data["data"]["data"]["url"]);
    } catch (e) {
      debugPrint('==> add order review failure: $e');
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
  Future<ApiResult<String>> tipProcess(
    int? orderId,
    String paymentName,
    int? paymentId,
    num? tips,
  ) async {
    try {
      final client = inject<HttpService>().client(requireAuth: true)..options.connectTimeout = const Duration(seconds: 30);
      if (paymentName.toLowerCase() == 'wallet') {
        var res = await client.post(
          '/api/v1/payments/order/$orderId/transactions',
          data: {
            "tips": tips,
            "payment_sys_id": paymentId ,
          },
        );
        return ApiResult.success(data: res.data["data"].toString());
      } else {
        var res = await client.get(
          '/api/v1/dashboard/user/order-${paymentName.toLowerCase()}-process',
          queryParameters: {
            "order_id": orderId,
            "tips": tips,
          },
        );
        return ApiResult.success(data: res.data["data"]["data"]["url"]);
      }
    } catch (e) {
      debugPrint('==> tip order failure: $e');
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
  Future<ApiResult<CouponResponse>> checkCoupon({
    required String coupon,
    required int shopId,
  }) async {
    final data = {
      'coupon': coupon,
      'shop_id': shopId,
    };
    try {
      final client = inject<HttpService>().client(requireAuth: true)..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/rest/coupons/check',
        data: data,
      );
      return ApiResult.success(data: CouponResponse.fromJson(response.data));
    } catch (e) {
      debugPrint('==> check coupon failure: $e');
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
  Future<ApiResult<CashbackResponse>> checkCashback(
      {required double amount, required int shopId}) async {
    final data = {'amount': amount, "shop_id": shopId};
    try {
      final client = inject<HttpService>().client(requireAuth: false)..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/rest/cashback/check',
        data: data,
      );
      return ApiResult.success(data: CashbackResponse.fromJson(response.data));
    } catch (e) {
      debugPrint('==> check cashback failure: $e');
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
  Future<ApiResult<GetCalculateModel>> getCalculate(
      {required int cartId,
      required double lat,
      required double long,
      required DeliveryTypeEnum type,
      String? coupon}) async {
    final data = {
      'address[latitude]': lat,
      'address[longitude]': long,
      if (LocalStorage.getSelectedCurrency() != null)
        'currency_id': LocalStorage.getSelectedCurrency()?.id,
      "type": type == DeliveryTypeEnum.delivery ? "delivery" : "pickup",
      "coupon": coupon,
    };
    try {
      final client = inject<HttpService>().client(requireAuth: true)..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.post(
        '/api/v1/dashboard/user/cart/calculate/$cartId',
        queryParameters: data,
      );
      return ApiResult.success(
          data: GetCalculateModel.fromJson(response.data["data"]));
    } catch (e) {
      debugPrint('==> check cashback failure: $e');
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
  Future<ApiResult<void>> cancelOrder(num orderId) async {
    try {
      final client = inject<HttpService>().client(requireAuth: true)..options.connectTimeout = const Duration(seconds: 30);
      await client.post(
        '/api/v1/dashboard/user/orders/$orderId/status/change?status=canceled',
      );
      return const ApiResult.success(
        data: null,
      );
    } catch (e) {
      debugPrint('==> get cancel order failure: $e');
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
  Future<ApiResult<void>> refundOrder(num orderId, String title) async {
    try {
      final data = {
        "order_id": orderId,
        "cause": title,
      };
      final client = inject<HttpService>().client(requireAuth: true)..options.connectTimeout = const Duration(seconds: 30);
      await client.post('/api/v1/dashboard/user/order-refunds', data: data);
      return const ApiResult.success(
        data: null,
      );
    } catch (e) {
      debugPrint('==> get cancel order failure: $e');
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
  Future<ApiResult<RefundOrdersModel>> getRefundOrders(int page) async {
    final data = {
      if (LocalStorage.getSelectedCurrency() != null)
        'currency_id': LocalStorage.getSelectedCurrency()?.id,
      'lang': LocalStorage.getLanguage()?.locale,
      "perPage": 10,
      "page": page
    };
    try {
      final client = inject<HttpService>().client(requireAuth: true);
      final response = await client.get(
        '/api/v1/dashboard/user/order-refunds/paginate',
        queryParameters: data,
      );
      return ApiResult.success(
        data: RefundOrdersModel.fromJson(response.data),
      );
    } catch (e) {
      debugPrint('==> get canceled orders failure: $e');
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
  Future<ApiResult<LocalLocation>> getDriverLocation(int deliveryId) async {
    try {
      final client = inject<HttpService>().client(requireAuth: false)..options.connectTimeout = const Duration(seconds: 30);
      final response = await client.get(
        '/api/v1/rest/orders/deliveryman/$deliveryId',
      );
      return ApiResult.success(
        data: LocalLocation.fromJson(
            response.data["data"]["delivery_man_setting"]["location"]),
      );
    } catch (e) {
      debugPrint('==> get driver location failure: $e');
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
