import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'http_client.dart';

class _ApiService {
  static _ApiService? _instance;

  // Base服务器 - 业务API（JSON）
  late final HttpClient _baseHttpClient;

  // Auth服务器 - 认证API（JSON）
  late final HttpClient _authHttpClient;

  // File服务器 - 文件管理API（JSON）
  late final HttpClient _fileHttpClient;

  // Upload客户端 - 直接上传到S3/OSS（Upload）
  late final HttpClient _uploadClient;

  _ApiService._() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
    final authUrl = dotenv.env['API_AUTH_URL'] ?? baseUrl;
    final fileUrl = dotenv.env['API_FILE_URL'] ?? baseUrl;

    // 初始化Base服务器（JSON）
    _baseHttpClient = HttpClient.json(baseUrl: baseUrl);
    _addErrorInterceptor(_baseHttpClient.dio);
    _addCommonResponseInterceptor(_baseHttpClient.dio);

    // 初始化Auth服务器（JSON）
    _authHttpClient = HttpClient.json(baseUrl: authUrl);
    _addErrorInterceptor(_authHttpClient.dio);

    // 初始化File服务器（JSON）
    _fileHttpClient = HttpClient.json(baseUrl: fileUrl);
    _addErrorInterceptor(_fileHttpClient.dio);

    // 初始化Upload客户端（S3/OSS上传，无baseURL）
    _uploadClient = HttpClient.upload();
    _addErrorInterceptor(_uploadClient.dio);
  }

  void _addCommonResponseInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          final payload = response.data;
          if (payload is! Map) {
            handler.next(response);
            return;
          }

          final envelope = Map<String, dynamic>.from(payload);
          if (!envelope.containsKey('code') ||
              !envelope.containsKey('message') ||
              !envelope.containsKey('data')) {
            handler.next(response);
            return;
          }

          final rawCode = envelope['code'];
          final parsedCode = switch (rawCode) {
            num value => value.toInt(),
            String value => int.tryParse(value),
            _ => null,
          };
          if (parsedCode == null) {
            handler.next(response);
            return;
          }

          final message = envelope['message']?.toString();
          if (parsedCode == 0) {
            response.data = envelope['data'];
            handler.next(response);
            return;
          }

          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: message?.trim().isNotEmpty == true ? message : '请求失败',
            ),
          );
        },
      ),
    );
  }

  String? _tryExtractErrorMessage(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is String) {
      final trimmed = data.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final errorObj = map['error'];
      if (errorObj != null) {
        final message = _tryExtractErrorMessage(errorObj);
        if (message != null) {
          return message;
        }
      }

      final messageField = map['message'];
      if (messageField != null) {
        final message = messageField.toString().trim();
        return message.isEmpty ? null : message;
      }
    }

    return null;
  }

  // 添加统一错误处理拦截器
  void _addErrorInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          try {
            // 1. 网络层错误（客户端处理）
            switch (error.type) {
              case DioExceptionType.connectionTimeout:
              case DioExceptionType.sendTimeout:
              case DioExceptionType.receiveTimeout:
                handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: '连接超时，请重试',
                    type: error.type,
                  ),
                );
                return;

              case DioExceptionType.connectionError:
                handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: '网络错误，请检查网络连接',
                    type: error.type,
                  ),
                );
                return;

              case DioExceptionType.badResponse:
                // 继续处理业务错误
                break;

              default:
                handler.next(error);
                return;
            }

            // 2. 业务错误（服务端返回）
            if (error.response != null) {
              final data = error.response?.data;

              // 服务端返回了结构化错误 {error: {code, message}}
              final extractedMessage = _tryExtractErrorMessage(data);
              if (extractedMessage != null) {
                handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: extractedMessage,
                    response: error.response,
                    type: error.type,
                  ),
                );
                return;
              }

              // 服务端没有返回结构化错误，使用HTTP状态码fallback
              final statusCode = error.response?.statusCode;
              final fallbackMessage = _getStatusCodeMessage(statusCode);

              if (fallbackMessage != null) {
                handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: fallbackMessage,
                    response: error.response,
                    type: error.type,
                  ),
                );
                return;
              }
            }

            // 3. 其他未处理的错误，原样传递
            handler.next(error);
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
  }

  // HTTP状态码对应的通用错误消息
  String? _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '无权访问';
      case 404:
        return '资源不存在';
      case 409:
        return '资源冲突';
      case 413:
        return '文件过大';
      case 415:
        return '不支持的文件类型';
      case 422:
        return '验证失败';
      case 500:
        return '服务器错误，请稍后重试';
      default:
        return null;
    }
  }

  // TODO: 可选 - 国际化翻译函数
  // String _translateError(String? code, String defaultMessage) {
  //   if (code == null) return defaultMessage;
  //
  //   // 从国际化文件读取翻译
  //   // 例如使用 easy_localization 或 flutter_i18n
  //   return defaultMessage;
  // }

  static _ApiService get instance {
    _instance ??= _ApiService._();
    return _instance!;
  }

  // Getters - 只暴露HttpClient
  HttpClient get baseHttpClient => _baseHttpClient;
  HttpClient get authHttpClient => _authHttpClient;
  HttpClient get fileHttpClient => _fileHttpClient;
  HttpClient get uploadClient => _uploadClient;
}

// Global instances - 只暴露HttpClient，Dio完全封装
// Base服务器 - 业务API（默认）
final httpClient = _ApiService.instance.baseHttpClient;

// Auth服务器 - 认证API
final authHttpClient = _ApiService.instance.authHttpClient;

// File服务器 - 文件管理API
final fileHttpClient = _ApiService.instance.fileHttpClient;

// Upload客户端 - S3/OSS直接上传
final uploadClient = _ApiService.instance.uploadClient;
