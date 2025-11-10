import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'parking_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? user = AuthService().currentUser;

    // Make sure we have a user before building the screen
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MU Smart Parking',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1565C0)),
            onPressed: () {
              AuthService().signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Car Parking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ParkingMapScreen(parkingType: 'car'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.motorcycle),
                  label: const Text('Bike Parking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ParkingMapScreen(parkingType: 'motorcycle'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 255, 248, 248)],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Could not find user data."));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            // Get the list of bookings
            final List<dynamic> currentBookings =
                userData['currentBookings'] ?? [];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    // University Logo and Name
                    Image.asset('assets/images/marwadi_logo.png', height: 80),
                    const SizedBox(height: 16),
                    const Text(
                      'MARWADI UNIVERSITY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Smart Parking Management System',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome to our smart parking solution that helps you easily find and book parking spots on campus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color:Color.fromARGB(255, 0, 0, 0)),
                    ),
                    const SizedBox(height: 32),

                    // Booking status card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1), // fixed here
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_parking,
                                color: Color(0xFF1976D2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'YOUR BOOKINGS (${currentBookings.length}/3)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (currentBookings.isNotEmpty)
                            ...currentBookings.map(
                              (spotId) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2E7D32),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Spot: $spotId',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 140, 166, 249),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF1976D2),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'No Active Bookings',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 15, 15, 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
