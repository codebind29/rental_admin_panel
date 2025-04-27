import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

/// 🔹 Authentication Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthCheckEvent extends AuthEvent {} // ✅ Check if admin is logged in
class AuthLoggedOut extends AuthEvent {}  // ✅ Handle logout
class LoginAdminEvent extends AuthEvent {
  final String email;
  final String password;

  LoginAdminEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// 🔹 Authentication States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}   // ✅ Initial state
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class UnAuthenticated extends AuthState {} // ✅ If not logged in
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// 🔹 Authentication Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    /// ✅ Handle Auth Check (Fix for your error)
    on<AuthCheckEvent>((event, emit) async {
      User? user = _auth.currentUser;
      if (user != null) {
        emit(Authenticated(user)); // ✅ If logged in, set state to Authenticated
      } else {
        emit(UnAuthenticated()); // ✅ Otherwise, set state to UnAuthenticated
      }
    });

    /// ✅ Handle Admin Login
    on<LoginAdminEvent>((event, emit) async {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(userCredential.user!));
      } catch (e) {
        emit(AuthError("Invalid Email or Password"));
      }
    });

    /// ✅ Handle Logout
    on<AuthLoggedOut>((event, emit) async {
      await _auth.signOut();
      emit(UnAuthenticated()); // ✅ Show login screen after logout
    });
  }
}




