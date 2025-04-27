class Car {
  final String id;
  final String city;
  final double distance;
  final double fuelCapacity;
  final String model;
  final double pricePerHour;
  final bool isAvailable;
  final double latitude; // Add this
  final double longitude;// ✅ Add this field

  Car({
    required this.id,
    required this.city,
    required this.distance,
    required this.fuelCapacity,
    required this.model,
    required this.pricePerHour,
    required this.isAvailable, // ✅ Ensure it's required
    required this.latitude, // Add this
    required this.longitude,
  });

  factory Car.fromMap(Map<String, dynamic> data, String id) {
    return Car(
      id: id,
      city: data['city'] ?? '',
      distance: (data['distance'] ?? 0).toDouble(),
      fuelCapacity: (data['fuelCapacity'] ?? 0).toDouble(),
      model: data['model'] ?? '',
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      isAvailable: (data.containsKey('isAvailable')) ? data['isAvailable'] as bool : true,
      latitude: (data['latitude'] ?? 0).toDouble(), // Add this
      longitude: (data['longitude'] ?? 0).toDouble(),// ✅ Default to true if missing
    );
  }
}


