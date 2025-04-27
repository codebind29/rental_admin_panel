import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/screens/main/main_screen.dart';

class Car {
  final String id;
  final String name;
  final String model;
  final String fuelType;
  final String transmission;
  final double dailyPrice;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;

  Car({
    required this.id,
    required this.name,
    required this.model,
    required this.fuelType,
    required this.transmission,
    required this.dailyPrice,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
  });

  factory Car.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Car(
      id: doc.id,
      name: data['name'] ?? '',
      model: data['model'] ?? '',
      fuelType: data['fuelType'] ?? '',
      transmission: data['transmission'] ?? '',
      dailyPrice: (data['dailyPrice'] ?? 0).toDouble(),
      monthlyPrice: (data['monthlyPrice'] ?? 0).toDouble(),
      yearlyPrice: (data['yearlyPrice'] ?? 0).toDouble(),
      features: List<String>.from(data['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'model': model,
      'fuelType': fuelType,
      'transmission': transmission,
      'dailyPrice': dailyPrice,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'features': features,
    };
  }
}

class SubscriptionManagementScreen extends StatefulWidget {
  @override
  _SubscriptionManagementScreenState createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _monthlyPriceController = TextEditingController();
  final TextEditingController _yearlyPriceController = TextEditingController();
  final List<TextEditingController> _featureControllers = [];

  void _addFeatureField() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeatureField(int index) {
    setState(() {
      _featureControllers.removeAt(index);
    });
  }

  Future<void> _addSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    final features = _featureControllers
        .where((controller) => controller.text.isNotEmpty)
        .map((controller) => controller.text)
        .toList();

    final car = Car(
      id: '',
      name: _nameController.text,
      model: _modelController.text,
      fuelType: _fuelTypeController.text,
      transmission: _transmissionController.text,
      dailyPrice: double.tryParse(_dailyPriceController.text) ?? 0,
      monthlyPrice: double.tryParse(_monthlyPriceController.text) ?? 0,
      yearlyPrice: double.tryParse(_yearlyPriceController.text) ?? 0,
      features: features,
    );

    await _firestore.collection('subscriptions').add(car.toMap());
    _clearForm();
    Navigator.pop(context);
  }

  Future<void> _updateSubscription(String id) async {
    if (!_formKey.currentState!.validate()) return;

    final features = _featureControllers
        .where((controller) => controller.text.isNotEmpty)
        .map((controller) => controller.text)
        .toList();

    final car = Car(
      id: id,
      name: _nameController.text,
      model: _modelController.text,
      fuelType: _fuelTypeController.text,
      transmission: _transmissionController.text,
      dailyPrice: double.tryParse(_dailyPriceController.text) ?? 0,
      monthlyPrice: double.tryParse(_monthlyPriceController.text) ?? 0,
      yearlyPrice: double.tryParse(_yearlyPriceController.text) ?? 0,
      features: features,
    );

    await _firestore.collection('subscriptions').doc(id).update(car.toMap());
    _clearForm();
    Navigator.pop(context);
  }

  Future<void> _deleteSubscription(String id) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this subscription?',
            style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () {
              _firestore.collection('subscriptions').doc(id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Subscription deleted'),
                  backgroundColor: Colors.grey[800],
                ),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _modelController.clear();
    _fuelTypeController.clear();
    _transmissionController.clear();
    _dailyPriceController.clear();
    _monthlyPriceController.clear();
    _yearlyPriceController.clear();
    _featureControllers.forEach((controller) => controller.clear());
    _featureControllers.clear();
  }

  void _showSubscriptionForm({String? id, Car? car}) {
    if (car != null) {
      _nameController.text = car.name;
      _modelController.text = car.model;
      _fuelTypeController.text = car.fuelType;
      _transmissionController.text = car.transmission;
      _dailyPriceController.text = car.dailyPrice.toString();
      _monthlyPriceController.text = car.monthlyPrice.toString();
      _yearlyPriceController.text = car.yearlyPrice.toString();

      _featureControllers.clear();
      for (var feature in car.features) {
        _featureControllers.add(TextEditingController(text: feature));
      }
    } else {
      _clearForm();
      _addFeatureField();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            id == null ? "Add New Car" : "Edit Car",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildDarkTextField("Car Name", _nameController),
                          _buildDarkTextField("Model", _modelController),
                          _buildDarkTextField("Fuel Type", _fuelTypeController),
                          _buildDarkTextField("Transmission", _transmissionController),
                          _buildDarkNumberField("Daily Price", _dailyPriceController),
                          _buildDarkNumberField("Monthly Price", _monthlyPriceController),
                          _buildDarkNumberField("Yearly Price", _yearlyPriceController),

                          SizedBox(height: 16),
                          Text(
                            "Features:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          ..._buildDarkFeatureFields(setState),

                          IconButton(
                            icon: Icon(Icons.add, color: Colors.tealAccent),
                            onPressed: () {
                              setState(() => _addFeatureField());
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.tealAccent,
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => id == null ? _addSubscription() : _updateSubscription(id),
                                child: Text(id == null ? 'Add' : 'Update'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildDarkFeatureFields(StateSetter setState) {
    return List<Widget>.generate(_featureControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: _buildDarkTextField("Feature ${index + 1}", _featureControllers[index]),
            ),
            IconButton(
              icon: Icon(Icons.remove, color: Colors.redAccent),
              onPressed: () {
                setState(() => _removeFeatureField(index));
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDarkTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent),
          ),
          filled: true,
          fillColor: Colors.grey[800],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter this field';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDarkNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixText: '\₹ ',
          prefixStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent),
          ),
          filled: true,
          fillColor: Colors.grey[800],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a price';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          "Manage Subscriptions",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          ),
        ),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[850]!, Colors.grey[900]!],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('subscriptions').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.tealAccent));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.redAccent),
                ),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No subscriptions available',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final car = Car.fromFirestore(doc);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[800]!, Colors.grey[850]!],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '${car.name} ${car.model}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          '${car.fuelType} • ${car.transmission}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Daily: \₹${car.dailyPrice.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.tealAccent),
                            ),
                            Text(
                              'Monthly: \₹${car.monthlyPrice.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.tealAccent),
                            ),
                            Text(
                              'Yearly: \₹${car.yearlyPrice.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.tealAccent),
                            ),
                          ],
                        ),
                        if (car.features.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            'Features:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                            ),
                          ),
                          ...car.features.map((f) => Text(
                            '• $f',
                            style: TextStyle(color: Colors.grey[400]),
                          )).toList(),
                        ],
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.tealAccent),
                            onPressed: () => _showSubscriptionForm(id: doc.id, car: car),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteSubscription(doc.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () => _showSubscriptionForm(),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _fuelTypeController.dispose();
    _transmissionController.dispose();
    _dailyPriceController.dispose();
    _monthlyPriceController.dispose();
    _yearlyPriceController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}