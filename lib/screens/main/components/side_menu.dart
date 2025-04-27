import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../GPS/gps_tracking_screen.dart';
import '../../auth/login_screen.dart';
import '../../cars/car_management_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../subscription_management_screen.dart';
import '../../users/user_management_screen.dart';

class SidebarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: Column(
        children: [
          /// ✅ Drawer Header with Lottie Animation
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(bottom: BorderSide(color: Colors.tealAccent, width: 2)),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: Lottie.asset(
                      "assets/animations/car.json",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  "Car Rental Admin",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),

          /// ✅ Menu Options
          DrawerListTile(title: "Dashboard", icon: Icons.dashboard, press: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
          }),
          DrawerListTile(title: "Car Management", icon: Icons.directions_car, press: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CarManagementScreen()));
          }),
          DrawerListTile(title: "User Management", icon: Icons.people, press: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserManagementScreen()));
          }),
          DrawerListTile(title: "Subscription Plans", icon: Icons.subscriptions, press: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SubscriptionManagementScreen()));
          }),
          DrawerListTile(
            title: "Live Car Tracking",
            icon: Icons.location_on,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleTrackerWithSearch()));
            },
          ),

          Spacer(),

          /// ✅ Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text("Logout", style: TextStyle(color: Colors.white)),
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Logout Function
  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(AuthLoggedOut());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }
}

/// ✅ Custom Drawer Tile
class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback press;

  DrawerListTile({required this.title, required this.icon, required this.press});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.tealAccent),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: press,
      hoverColor: Colors.tealAccent.withOpacity(0.2),
    );
  }
}