// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
class NetworkExceptions with _$NetworkExceptions {
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;

  const factory NetworkExceptions.unauthorisedRequest() = UnauthorisedRequest;

  const factory NetworkExceptions.badRequest() = BadRequest;

  const factory NetworkExceptions.notFound(String reason) = NotFound;

  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;

  const factory NetworkExceptions.notAcceptable() = NotAcceptable;

  const factory NetworkExceptions.requestTimeout() = RequestTimeout;

  const factory NetworkExceptions.sendTimeout() = SendTimeout;

  const factory NetworkExceptions.conflict() = Conflict;

  const factory NetworkExceptions.internalServerError() = InternalServerError;

  const factory NetworkExceptions.notImplemented() = NotImplemented;

  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;

  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;

  const factory NetworkExceptions.formatException() = FormatException;

  const factory NetworkExceptions.unableToProcess() = UnableToProcess;

  const factory NetworkExceptions.defaultError(String error) = DefaultError;

  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static NetworkExceptions getDioException(dynamic error) {
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            // --- All cases are now handled ---
            case DioExceptionType.cancel:
              return const NetworkExceptions.requestCancelled();
            case DioExceptionType.connectionTimeout:
              return const NetworkExceptions.requestTimeout();
            case DioExceptionType.sendTimeout:
              return const NetworkExceptions.sendTimeout();
            case DioExceptionType.receiveTimeout:
              return const NetworkExceptions.requestTimeout();

            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 400:
                  return const NetworkExceptions.badRequest();
                case 401:
                  return const NetworkExceptions.unauthorisedRequest();
                case 403:
                  return const NetworkExceptions.unauthorisedRequest();
                case 404:
                  return NetworkExceptions.notFound(
                      error.response?.statusMessage ?? "Not Found");
                case 408:
                  return const NetworkExceptions.requestTimeout();
                case 409:
                  return const NetworkExceptions.conflict();
                case 422:
                   return const NetworkExceptions.unableToProcess();
                case 500:
                  return const NetworkExceptions.internalServerError();
                case 503:
                  return const NetworkExceptions.serviceUnavailable();
                default:
                  var responseCode = error.response!.statusCode;
                  return NetworkExceptions.defaultError(
                    "Received invalid status code: $responseCode",
                  );
              }

            case DioExceptionType.unknown:
              // Handles cases where there's no internet connection
              if (error.error is SocketException) {
                return const NetworkExceptions.noInternetConnection();
              }
              return const NetworkExceptions.unexpectedError();
              
            case DioExceptionType.badCertificate:
              return const NetworkExceptions.unauthorisedRequest();

            case DioExceptionType.connectionError:
              return const NetworkExceptions.noInternetConnection();
          }
        } else if (error is SocketException) {
          return const NetworkExceptions.noInternetConnection();
        } else {
          return const NetworkExceptions.unexpectedError();
        }
      } on FormatException catch (_) {
        return const NetworkExceptions.formatException();
      } catch (_) {
        return const NetworkExceptions.unexpectedError();
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return const NetworkExceptions.unableToProcess();
      } else {
        return const NetworkExceptions.unexpectedError();
      }
    }
  }
  
  // This method is now redundant since the information can be derived from getDioException,
  // but I've completed it as requested.
  static int getDioStatus(error) {
    if (error is Exception) {
      if (error is DioException) {
        if (error.response != null) {
          return error.response!.statusCode ?? 500;
        }
      }
    }
    return 500; // Default to 500 for non-dio errors or unknown cases
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    var errorMessage = "";
    networkExceptions.when(
      notImplemented: () {
        errorMessage = "Not Implemented";
      },
      requestCancelled: () {
        errorMessage = "Request Cancelled";
      },
      internalServerError: () {
        errorMessage = "Internal Server Error";
      },
      notFound: (String reason) {
        errorMessage = reason;
      },
      serviceUnavailable: () {
        errorMessage = "Service unavailable";
      },
      methodNotAllowed: () {
        // Corrected typo from "Allowed" to "Not Allowed"
        errorMessage = "Method Not Allowed";
      },
      badRequest: () {
        errorMessage = "Bad request";
      },
      unauthorisedRequest: () {
        errorMessage = "Unauthorised request";
      },
      unexpectedError: () {
        errorMessage = "Unexpected error occurred";
      },
      requestTimeout: () {
        errorMessage = "Connection request timeout";
      },
      noInternetConnection: () {
        errorMessage = "No internet connection";
      },
      conflict: () {
        errorMessage = "Error due to a conflict";
      },
      sendTimeout: () {
        errorMessage = "Send timeout in connection with API server";
      },
      unableToProcess: () {
        errorMessage = "Unable to process the data";
      },
      defaultError: (String error) {
        errorMessage = error;
      },
      formatException: () {
        errorMessage = "Unexpected error occurred (Format Exception)";
      },
      notAcceptable: () {
        errorMessage = "Not acceptable";
      },
    );
    return errorMessage;
  }
}