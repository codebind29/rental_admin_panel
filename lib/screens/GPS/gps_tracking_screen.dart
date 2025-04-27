import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/car_model.dart';

class VehicleTrackerWithSearch extends StatefulWidget {
  const VehicleTrackerWithSearch({Key? key}) : super(key: key);

  @override
  State<VehicleTrackerWithSearch> createState() => _VehicleTrackerWithSearchState();
}

class _VehicleTrackerWithSearchState extends State<VehicleTrackerWithSearch> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  List<Car> _allCars = [];
  List<Car> _filteredCars = [];
  Car? _selectedCar;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  Future<void> _initTracking() async {
    try {
      await _checkLocationPermissions();
      await _getCurrentLocation();
      _setupFirestoreListener();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Please enable location services';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions denied';
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    setState(() {
      _currentPosition = position;
    });
  }

  void _setupFirestoreListener() {
    FirebaseFirestore.instance.collection('cars').snapshots().listen((snapshot) {
      _allCars = snapshot.docs.map((doc) => Car.fromMap(doc.data(), doc.id)).toList();
      _filteredCars = List.from(_allCars);
      _updateMarkers();
      setState(() => _isLoading = false);
    }, onError: (e) {
      setState(() {
        _errorMessage = 'Data load failed: $e';
        _isLoading = false;
      });
    });
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      for (var car in _filteredCars) {
        _markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(car.latitude ?? 0.0, car.longitude ?? 0.0),
            child: Icon(
              Icons.directions_car,
              color: car.isAvailable ? Colors.green : Colors.grey,
              size: 40,
            ),
          ),
        );
      }
    });
  }

  void _searchCars(String query) {
    setState(() {
      _filteredCars = _allCars.where((car) {
        final model = car.model.toLowerCase();
        final city = car.city.toLowerCase();
        final searchLower = query.toLowerCase();
        return model.contains(searchLower) || city.contains(searchLower);
      }).toList();
      _updateMarkers();
    });
  }

  void _centerOnCar(Car car) {
    _mapController.move(
      LatLng(car.latitude ?? 0.0, car.longitude ?? 0.0),
      15.0,
    );
  }

  void _centerOnLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(0, 0),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),

          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildSearchCard(theme),
          ).animate().fadeIn().slideY(begin: -0.5, end: 0),

          // Bottom Car Cards
          if (_filteredCars.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildCarCardsList(size, theme),
            ).animate().fadeIn().slideY(begin: 0.5, end: 0),

          // Selected Car Details
          if (_selectedCar != null)
            Positioned(
              bottom: size.height * 0.25,
              left: 16,
              right: 16,
              child: _buildSelectedCarCard(theme),
            ).animate().fadeIn(),

          // Loading/Error States
          if (_isLoading)
            const Center(child: CircularProgressIndicator.adaptive())
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(delay: 300.ms, duration: 1800.ms),

          if (_errorMessage != null)
            Center(
              child: _buildErrorCard(theme),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnLocation,
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildSearchCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search cars by model or city...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _searchCars('');
              },
            )
                : null,
          ),
          onChanged: _searchCars,
        ),
      ),
    );
  }

  Widget _buildCarCardsList(Size size, ThemeData theme) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filteredCars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final car = _filteredCars[index];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCar = car;
              _centerOnCar(car);
            }),
            child: _buildCarCard(car, theme),
          );
        },
      ),
    );
  }

  Widget _buildCarCard(Car car, ThemeData theme) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.8),
            theme.primaryColorDark.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/car_background.jpg',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.model,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  car.city,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\₹${car.pricePerHour.toStringAsFixed(2)}/h',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: car.isAvailable
                            ? Colors.green.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        car.isAvailable ? 'AVAILABLE' : 'BOOKED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCarCard(ThemeData theme) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCar!.model,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedCar = null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('City', _selectedCar!.city, theme),
            _buildDetailRow('Price', '\$${_selectedCar!.pricePerHour.toStringAsFixed(2)}/hour', theme),
            _buildDetailRow('Fuel', '${_selectedCar!.fuelCapacity}L', theme),
            _buildDetailRow('Distance', '${_selectedCar!.distance}km', theme),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {},
                child: const Text(
                  'Car',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _initTracking,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
