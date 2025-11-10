import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/parking_spot_model.dart';
import '../services/auth_service.dart';

class ParkingMapScreen extends StatelessWidget {
  final String parkingType; // 'car' or 'motorcycle'

  const ParkingMapScreen({super.key, required this.parkingType});

  String get backgroundImage {
    return parkingType == 'car'
        ? 'assets/car_parking_map.png'
        : 'assets/motorcycle_parking_map.png';
  }

  String get title {
    return parkingType == 'car' ? 'Car Parking' : 'Motorcycle Parking';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1565C0)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        child: InteractiveViewer(
          // Allows zoom and pan
          minScale: 0.8,
          maxScale: 4.0,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('parkingSpots')
                .where('type', isEqualTo: parkingType)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1976D2),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Color(0xFF1976D2),
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Map Firestore documents to ParkingSpot objects
              final spots = snapshot.data!.docs
                  .map((doc) => ParkingSpot.fromFirestore(doc))
                  .toList();

              return Stack(
                children: [
                  // Background parking map image
                  Image.asset(backgroundImage),

                  // Overlay each parking spot
                  ...spots.map((spot) {
                    return Positioned(
                      left: spot.x,
                      top: spot.y,
                      child: GestureDetector(
                        onTap: () => _handleSpotTap(context, spot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: parkingType == 'car' ? 40 : 55,
                          height: parkingType == 'car' ? 40 : 35,
                          decoration: BoxDecoration(
                            color: spot.status == 'available'
                                ? const Color(0xFF4CAF50).withOpacity(0.9)
                                : const Color(0xFFE53935).withOpacity(0.9),
                            border: Border.all(color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              if (spot.status == 'available')
                                const Center(
                                  child: Icon(
                                    Icons.local_parking,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              if (spot.status == 'booked')
                                const Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Text(
                                  spot.id.split('-').last,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Handle tap on a parking spot
  void _handleSpotTap(BuildContext context, ParkingSpot spot) async {
    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to interact with spots.')),
      );
      return;
    }

    // Get the latest user data to check their current bookings
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>;
    final List<dynamic> currentBookings = userData['currentBookings'] ?? [];

    // SCENARIO 1: Spot is booked by the CURRENT user (Allow Cancellation)
    if (spot.bookedBy == user.uid) {
      _showCancelDialog(context, spot, user.uid);
    }
    // SCENARIO 2: Spot is available AND user has NOT reached the limit
    else if (spot.status == 'available' && currentBookings.length < 3) {
      _showBookDialog(context, spot, user.uid);
    }
    // SCENARIO 3: User has reached the limit
    else if (spot.status == 'available' && currentBookings.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You have reached the maximum booking limit of 3 spots.',
          ),
        ),
      );
    }
    // SCENARIO 4: Spot is taken by someone else
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This spot is already taken by another user.'),
        ),
      );
    }
  }

  // Function to show the BOOKING confirmation dialog
  void _showBookDialog(BuildContext context, ParkingSpot spot, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book Spot ${spot.id}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                WriteBatch batch = FirebaseFirestore.instance.batch();

                // Update spot
                DocumentReference spotRef = FirebaseFirestore.instance
                    .collection('parkingSpots')
                    .doc(spot.id);
                batch.update(spotRef, {
                  'status': 'booked',
                  'bookedBy': userId,
                  'bookingTimestamp':
                      FieldValue.serverTimestamp(), // Add timestamp for timer
                });

                // Add spot to user's booking array
                DocumentReference userRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId);
                batch.update(userRef, {
                  'currentBookings': FieldValue.arrayUnion([
                    spot.id,
                  ]), // Use arrayUnion
                });

                await batch.commit();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show the CANCELLATION confirmation dialog
  void _showCancelDialog(
    BuildContext context,
    ParkingSpot spot,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking for ${spot.id}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Confirm Cancellation'),
              onPressed: () async {
                WriteBatch batch = FirebaseFirestore.instance.batch();

                // Update spot
                DocumentReference spotRef = FirebaseFirestore.instance
                    .collection('parkingSpots')
                    .doc(spot.id);
                batch.update(spotRef, {
                  'status': 'available',
                  'bookedBy': null,
                  'bookingTimestamp': null, // Clear timestamp
                });

                // Remove spot from user's booking array
                DocumentReference userRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId);
                batch.update(userRef, {
                  'currentBookings': FieldValue.arrayRemove([
                    spot.id,
                  ]), // Use arrayRemove
                });

                await batch.commit();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
