// --------------- Exceptions ---------------

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class PermissionException extends AppException {
  const PermissionException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

// --------------- Failure (for repository returns) ---------------

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
