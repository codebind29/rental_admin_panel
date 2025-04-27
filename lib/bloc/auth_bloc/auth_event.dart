import 'package:equatable/equatable.dart';

/// ✅ Authentication Events (Triggered when user logs in, logs out, or app starts)
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// ✅ Check if admin is already logged in
class AuthCheckEvent extends AuthEvent {}

/// ✅ Login event for admin
class LoginAdminEvent extends AuthEvent {
  final String email;
  final String password;

  LoginAdminEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// ✅ Logout event
class AuthLoggedOut extends AuthEvent {}
// ✅ Checks if admin is logged in

