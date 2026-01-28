/// Exceção base para a aplicação
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Exceção de rede/HTTP
class NetworkException extends AppException {
  NetworkException({
    super.message = 'Erro de conexão',
    String? code,
    super.originalException,
  }) : super(
    code: code ?? 'NETWORK_ERROR',
  );
}

/// Exceção de autenticação
class AuthException extends AppException {
  AuthException({
    super.message = 'Erro de autenticação',
    String? code,
    super.originalException,
  }) : super(
    code: code ?? 'AUTH_ERROR',
  );
}

/// Exceção de validação
class ValidationException extends AppException {
  ValidationException({
    super.message = 'Erro de validação',
    String? code,
    super.originalException,
  }) : super(
    code: code ?? 'VALIDATION_ERROR',
  );
}

/// Exceção de recurso não encontrado
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Recurso não encontrado',
    String? code,
    super.originalException,
  }) : super(
    code: code ?? 'NOT_FOUND',
  );
}

/// Exceção genérica de servidor
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    super.message = 'Erro do servidor',
    String? code,
    this.statusCode,
    super.originalException,
  }) : super(
    code: code ?? 'SERVER_ERROR',
  );
}

/// Exceção de operação não suportada
class UnsupportedException extends AppException {
  UnsupportedException({
    super.message = 'Operação não suportada',
    String? code,
    super.originalException,
  }) : super(
    code: code ?? 'UNSUPPORTED_OPERATION',
  );
}

/// Exceção genérica da aplicação
class GeneralException extends AppException {
  GeneralException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(
    code: code ?? 'GENERAL_ERROR',
  );
}
