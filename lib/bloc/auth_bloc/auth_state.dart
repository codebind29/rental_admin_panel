import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ✅ Authentication States (Used to manage UI flow)
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

/// ✅ Initial state before checking authentication
class AuthInitial extends AuthState {}

/// ✅ State when admin is logged in
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// ✅ State when admin is logged out or not authenticated
class UnAuthenticated extends AuthState {}

/// ✅ State when there's an error (e.g., wrong password)
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object> get props => [message];
}
