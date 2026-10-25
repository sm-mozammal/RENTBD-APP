import 'package:equatable/equatable.dart';

/// Base Failure class in Clean Architecture Domain layer.
/// Used to represent user-friendly errors across Use Cases and Presentation layers.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again later.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please verify credentials.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to access local cached data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Please correct the invalid inputs.']);
}
