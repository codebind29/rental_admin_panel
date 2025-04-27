import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/screens/auth/login_screen.dart';
import 'package:admin/screens/auth/forgot_password_screen.dart'; // Import Forgot Password Screen
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/car/car_cubit.dart';
import 'bloc/booking/booking_cubit.dart';// Import AuthBloc
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(AuthCheckEvent())),
        BlocProvider(create: (context) => CarCubit()..fetchCars()),
        BlocProvider(create: (context) => BookingCubit()..fetchBookings()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Car Rental Admin Panel',
        theme: ThemeData.dark(),
        home: AuthWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/admin_dashboard': (context) => MainScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(), // ✅ Added this
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return MainScreen(); // If logged in, go to dashboard
        } else if (state is UnAuthenticated) {
          return LoginScreen(); //  If not logged in, show login
        } else {
          return Center(child: CircularProgressIndicator()); //  Loading state
        }
      },
    );
  }
}


