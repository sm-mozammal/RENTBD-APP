import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading({this.message});
  final String? message;

  @override
  List<Object?> get props => [message];
}

class OtpSentState extends AuthState {
  const OtpSentState({required this.phoneNumber});
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class Authenticated extends AuthState {
  const Authenticated({required this.user});
  final UserProfile user;

  @override
  List<Object?> get props => [user];
}

class PasswordChangeSuccessState extends AuthState {
  const PasswordChangeSuccessState({required this.user});
  final UserProfile user;

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
