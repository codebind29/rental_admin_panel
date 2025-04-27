import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CarManagementScreen extends StatefulWidget {
  @override
  _CarManagementScreenState createState() => _CarManagementScreenState();
}

class _CarManagementScreenState extends State<CarManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Controllers for all car fields
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _fuelCapacityController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerRatingController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _accelerationController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _safetyRatingController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final TextEditingController _securityDepositController = TextEditingController();
  List<String> _featuresList = [];
  String _imageUrl = '';

  @override
  void dispose() {
    _modelController.dispose();
    _cityController.dispose();
    _distanceController.dispose();
    _fuelCapacityController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _ownerNameController.dispose();
    _ownerRatingController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _fuelTypeController.dispose();
    _ratingController.dispose();
    _accelerationController.dispose();
    _seatsController.dispose();
    _safetyRatingController.dispose();
    _typeController.dispose();
    _colorController.dispose();
    _featuresController.dispose();
    _securityDepositController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // Here you would typically upload the image to storage and get the URL
      // For demo purposes, we'll just use a placeholder
      _imageUrl = 'https://via.placeholder.com/150';
    }
  }

  void _addFeature() {
    if (_featuresController.text.isNotEmpty) {
      setState(() {
        _featuresList.add(_featuresController.text);
        _featuresController.clear();
      });
    }
  }

  void _removeFeature(int index) {
    setState(() {
      _featuresList.removeAt(index);
    });
  }

  void _addCar() async {
    await _firestore.collection('cars').add({
      'model': _modelController.text,
      'imageUrl': _imageUrl,
      'city': _cityController.text,
      'distance': double.tryParse(_distanceController.text) ?? 0.0,
      'fuelCapacity': double.tryParse(_fuelCapacityController.text) ?? 0.0,
      'pricePerHour': double.tryParse(_pricePerHourController.text) ?? 0.0,
      'pricePerDay': double.tryParse(_pricePerDayController.text) ??
          (double.tryParse(_pricePerHourController.text) ?? 0.0) * 24,
      'ownerName': _ownerNameController.text,
      'ownerImageUrl': '',
      'ownerRating': double.tryParse(_ownerRatingController.text) ?? 0.0,
      'features': _featuresList,
      'reviews': [],
      'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
      'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
      'fuelType': _fuelTypeController.text,
      'rating': double.tryParse(_ratingController.text) ?? 0.0,
      'acceleration': double.tryParse(_accelerationController.text) ?? 10.0,
      'seats': int.tryParse(_seatsController.text) ?? 5,
      'safetyRating': double.tryParse(_safetyRatingController.text) ?? 4.0,
      'type': _typeController.text,
      'color': _colorController.text,
      'isAvailable': true,
      'securityDeposit': double.tryParse(_securityDepositController.text) ?? 0.0,
    });
    _clearForm();
    Navigator.pop(context);
  }

  void _updateCar(String id) async {
    await _firestore.collection('cars').doc(id).update({
      'model': _modelController.text,
      'imageUrl': _imageUrl,
      'city': _cityController.text,
      'distance': double.tryParse(_distanceController.text) ?? 0.0,
      'fuelCapacity': double.tryParse(_fuelCapacityController.text) ?? 0.0,
      'pricePerHour': double.tryParse(_pricePerHourController.text) ?? 0.0,
      'pricePerDay': double.tryParse(_pricePerDayController.text) ??
          (double.tryParse(_pricePerHourController.text) ?? 0.0) * 24,
      'ownerName': _ownerNameController.text,
      'ownerRating': double.tryParse(_ownerRatingController.text) ?? 0.0,
      'features': _featuresList,
      'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
      'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
      'fuelType': _fuelTypeController.text,
      'rating': double.tryParse(_ratingController.text) ?? 0.0,
      'acceleration': double.tryParse(_accelerationController.text) ?? 10.0,
      'seats': int.tryParse(_seatsController.text) ?? 5,
      'safetyRating': double.tryParse(_safetyRatingController.text) ?? 4.0,
      'type': _typeController.text,
      'color': _colorController.text,
      'securityDeposit': double.tryParse(_securityDepositController.text) ?? 0.0,
    });
    _clearForm();
    Navigator.pop(context);
  }

  void _deleteCar(String id) async {
    await _firestore.collection('cars').doc(id).delete();
  }

  void _toggleAvailability(String id, bool currentStatus) async {
    await _firestore.collection('cars').doc(id).update({
      'isAvailable': !currentStatus,
    });
  }

  void _clearForm() {
    _modelController.clear();
    _cityController.clear();
    _distanceController.clear();
    _fuelCapacityController.clear();
    _pricePerHourController.clear();
    _pricePerDayController.clear();
    _ownerNameController.clear();
    _ownerRatingController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _fuelTypeController.clear();
    _ratingController.clear();
    _accelerationController.clear();
    _seatsController.clear();
    _safetyRatingController.clear();
    _typeController.clear();
    _colorController.clear();
    _featuresController.clear();
    _securityDepositController.clear();
    _featuresList.clear();
    _selectedImage = null;
    _imageUrl = '';
  }

  void _loadCarData(Map<String, dynamic> data) {
    _modelController.text = data['model'] ?? '';
    _cityController.text = data['city'] ?? '';
    _distanceController.text = (data['distance'] ?? 0).toString();
    _fuelCapacityController.text = (data['fuelCapacity'] ?? 0).toString();
    _pricePerHourController.text = (data['pricePerHour'] ?? 0).toString();
    _pricePerDayController.text = (data['pricePerDay'] ?? 0).toString();
    _ownerNameController.text = data['ownerName'] ?? '';
    _ownerRatingController.text = (data['ownerRating'] ?? 0).toString();
    _latitudeController.text = (data['latitude'] ?? 0).toString();
    _longitudeController.text = (data['longitude'] ?? 0).toString();
    _fuelTypeController.text = data['fuelType'] ?? 'Petrol';
    _ratingController.text = (data['rating'] ?? 0).toString();
    _accelerationController.text = (data['acceleration'] ?? 10).toString();
    _seatsController.text = (data['seats'] ?? 5).toString();
    _safetyRatingController.text = (data['safetyRating'] ?? 4).toString();
    _typeController.text = data['type'] ?? 'Sedan';
    _colorController.text = data['color'] ?? 'Black';
    _featuresList = List<String>.from(data['features'] ?? []);
    _imageUrl = data['imageUrl'] ?? '';
    _securityDepositController.text = (data['securityDeposit'] ?? 0).toString();
  }

  void _showCarForm({String? id, Map<String, dynamic>? data}) {
    if (data != null) {
      _loadCarData(data);
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        //padding: EdgeInsets.all(16),
        ),
        child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(
        id == null ? "Add New Car" : "Edit Car",
        style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        ),
        ),
        IconButton(
        icon: Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        ),
        ],
        ),
        Divider(color: Colors.grey[700]),
        SizedBox(height: 10),

        // Image Picker
        Center(
        child: GestureDetector(
        onTap: _pickImage,
        child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
        ),
        child: _selectedImage != null
        ? Image.file(_selectedImage!, fit: BoxFit.cover)
            : _imageUrl.isNotEmpty
        ? Image.network(_imageUrl, fit: BoxFit.cover)
            : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(Icons.camera_alt, color: Colors.grey),
        Text('Add Image', style: TextStyle(color: Colors.grey)),
        ],
        ),
        ),
        ),
        ),
        SizedBox(height: 20),

        // Basic Info Section
        Text('Basic Information', style: TextStyle(color: Colors.tealAccent, fontSize: 16)),
        _buildTextField("Model", _modelController),
        _buildTextField("City", _cityController),
        _buildTextField("Distance (km)", _distanceController, isNumeric: true),
        _buildTextField("Fuel Capacity (L)", _fuelCapacityController, isNumeric: true),

        // Pricing Section
        SizedBox(height: 20),
        Text('Pricing', style: TextStyle(color: Colors.tealAccent, fontSize: 16)),
        // Fixed the problematic Row by wrapping it in Expanded widgets
        Row(
        children: [
        Expanded(child: _buildTextField("Price/Hour", _pricePerHourController, isNumeric: true)),
        SizedBox(width: 10),
        Expanded(child: _buildTextField("Price/Day", _pricePerDayController, isNumeric: true)),
        SizedBox(width: 10),
        Expanded(child: _buildTextField("Security Deposit", _securityDepositController, isNumeric: true)),
        ],
        ),

        // Owner Info Section
        SizedBox(height: 20),
        Text('Owner Information', style: TextStyle(color: Colors.tealAccent, fontSize: 16)),
        _buildTextField("Owner Name", _ownerNameController),
        _buildTextField("Owner Rating", _ownerRatingController, isNumeric: true),

        // Location Section
        SizedBox(height: 20),
        Text('Location', style: TextStyle(color: Colors.tealAccent, fontSize: 16)),
        Row(
        children: [
        Expanded(child: _buildTextField("Latitude", _latitudeController, isNumeric: true)),
        SizedBox(width: 10),
        Expanded(child: _buildTextField("Longitude", _longitudeController, isNumeric: true)),
        ],
        ),

        // Specifications Section
        SizedBox(height: 20),
        Text('Specifications', style: TextStyle(color: Colors.tealAccent, fontSize: 16)),
        _buildTextField("Fuel Type", _fuelTypeController),
        _buildTextField("Rating", _ratingController, isNumeric: true),
        _buildTextField("Acceleration (0-100 km/h)", _accelerationController, isNumeric: true),
        _buildTextField("Seats", _seatsController, isNumeric: true),
        _buildTextField("Safety Rating", _safetyRatingController, isNumeric: true),
        _buildTextField("Type", _typeController),
        _buildTextField("Color", _colorController),

        // Features Section
        SizedBox(height: 20),
        Text('Features', style: TextStyle(color: Colors.tealAccent, fontSize: 16)),
        Row(
        children: [
        Expanded(
        child: TextField(
        controller: _featuresController,
        decoration: InputDecoration(
        labelText: 'Add Feature',
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        style: TextStyle(color: Colors.white),
        ),
        ),
        IconButton(
        icon: Icon(Icons.add, color: Colors.tealAccent),
        onPressed: _addFeature,
        ),
        ],
        ),
        Wrap(
        spacing: 8,
        children: _featuresList.asMap().entries.map((entry) {
        return Chip(
        label: Text(entry.value, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        deleteIcon: Icon(Icons.close, size: 18),
        onDeleted: () => _removeFeature(entry.key),
        );
        }).toList(),
        ),

        // Action Buttons
        SizedBox(height: 30),
        Row(
        children: [
        Expanded(
        child: ElevatedButton(
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text(
        'Cancel',
        style: TextStyle(color: Colors.white),
        ),
        ),
        ),
        SizedBox(width: 10),
        Expanded(
        child: ElevatedButton(
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent,
        padding: EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () => id == null ? _addCar() : _updateCar(id),
        child: Text(
        id == null ? 'Add Car' : 'Update',
        style: TextStyle(color: Colors.black),
        ),
        ),
        ),
        ],
        ),
        ],
        ),
        ),
        );
        },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        inputFormatters: isNumeric ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))] : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCarCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isAvailable = data['isAvailable'] ?? true;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // Car Image and Basic Info
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              image: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(data['imageUrl']),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              padding: EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['model'] ?? 'Unknown Model',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        data['city'] ?? 'Unknown City',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(1, 1),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Car Details
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(Icons.speed, '${data['distance']?.toStringAsFixed(1) ?? '0'} km'),
                    _buildDetailItem(Icons.local_gas_station, '${data['fuelCapacity']?.toStringAsFixed(1) ?? '0'} L'),
                    _buildDetailItem(Icons.people, '${data['seats'] ?? '5'} seats'),
                    _buildDetailItem(Icons.star, '${data['rating']?.toStringAsFixed(1) ?? '0'}'),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${data['pricePerHour']?.toStringAsFixed(0) ?? '0'}/hour',
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${data['pricePerDay']?.toStringAsFixed(0) ?? '0'}/day',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Icon(Icons.security, size: 16, color: Colors.grey[400]),
                        SizedBox(width: 4),
                        Text(
                          '₹${data['securityDeposit']?.toStringAsFixed(0) ?? '0'} deposit',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.teal[800] : Colors.red[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Booked',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.tealAccent),
                  onPressed: () => _showCarForm(id: doc.id, data: data),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteCar(doc.id),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (value) => _toggleAvailability(doc.id, isAvailable),
                  activeColor: Colors.tealAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Car Management", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () => _showCarForm(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 60, color: Colors.grey[600]),
                  SizedBox(height: 16),
                  Text(
                    'No Cars Available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first car to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.only(bottom: 80),
            children: snapshot.data!.docs.map((doc) => _buildCarCard(doc)).toList(),
          );
        },
      ),
    );
  }
}