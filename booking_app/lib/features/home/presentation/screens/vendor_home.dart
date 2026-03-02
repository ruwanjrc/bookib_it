import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/primary_button.dart';
import 'add_service_screen.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  // --- [STATUS UPDATE FUNCTION] ---
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': newStatus});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking $newStatus successfully!")),
        );
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildMainContent(),
      _buildBookingsScreen(),
      _buildProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
            _showLogoutDialog();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: "My Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('shops').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return _buildCreateShopForm();
        final data = snapshot.data!.data() as Map<String, dynamic>;
        return _buildDashboard(data);
      },
    );
  }

  Widget _buildDashboard(Map<String, dynamic> data) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8E88FF)]),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Text(data['name'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(data['category'], style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("My Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddServiceScreen())),
                  icon: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.add, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildServiceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('shops').doc(currentUser!.uid).collection('services').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final services = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              title: Text(services[index]['name']),
              trailing: Text("Rs. ${services[index]['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text("Recent Bookings"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('vendorId', isEqualTo: currentUser!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ලොජික් එක වෙනස් කළා: දත්ත තියෙනවා නම් කෙලින්ම ලිස්ට් එක පෙන්වන්න
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("No bookings yet.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final String bookingId = docs[index].id;
                final booking = docs[index].data() as Map<String, dynamic>;
                final String status = booking['status'] ?? 'pending';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(booking['customerName'] ?? "Customer", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${booking['serviceName']} \n${booking['date']} at ${booking['time']}"),
                          trailing: _buildStatusBadge(status),
                        ),
                        if (status == 'pending')
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => updateBookingStatus(bookingId, 'rejected'),
                                  child: const Text("Reject", style: TextStyle(color: Colors.red)),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => updateBookingStatus(bookingId, 'approved'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text("Approve", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } 
          
          // දත්ත නැතිනම් සහ Error එකක් නැතිනම් පමණක් ලෝඩර් එක පෙන්වන්න
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProfileScreen() => const Center(child: Text("Vendor Profile"));
  
  Widget _buildCreateShopForm() => const Center(child: Text("Please complete your Shop Profile first."));

  void _showLogoutDialog() {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text("Logout"), actions: [TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text("Yes"))]));
  }
}