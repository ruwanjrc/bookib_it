import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class BookingScreen extends StatefulWidget {
  final String shopId;
  final String shopName;
  final Map<String, dynamic> serviceData;

  const BookingScreen({super.key, required this.shopId, required this.shopName, required this.serviceData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isLoading = false;

  Future<void> confirmBooking() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    final String dateStr = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
    final String timeStr = selectedTime.format(context);

    try {
      // --- [IMPORTANT: CONFLICT CHECK] ---
      // මෙම නගරයේ, මෙම කඩේ, මෙම දිනය සහ වෙලාවට දැනටමත් APPROVED බුකින් එකක් තිබේදැයි බලයි.
      final existingBooking = await FirebaseFirestore.instance
          .collection('bookings')
          .where('vendorId', isEqualTo: widget.shopId)
          .where('date', isEqualTo: dateStr)
          .where('time', isEqualTo: timeStr)
          .where('status', isEqualTo: 'approved')
          .get();

      if (existingBooking.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This time slot is already booked and approved. Please pick another time."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // බුකින් එක සේව් නොකර මෙතනින් නවතියි.
      }

      // --- [SAVE BOOKING] ---
      await FirebaseFirestore.instance.collection('bookings').add({
        'vendorId': widget.shopId,
        'customerId': user!.uid,
        'customerName': user.email,
        'shopName': widget.shopName,
        'serviceName': widget.serviceData['name'],
        'price': widget.serviceData['price'],
        'date': dateStr,
        'time': timeStr,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Success!"),
            content: const Text("Your booking has been placed. Waiting for vendor approval."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Booking Screen
                  Navigator.pop(context); // Shop Details
                }, 
                child: const Text("OK")
              )
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Booking Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.serviceData['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text(widget.shopName, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Divider(height: 50),
            
            _buildPickerTile("Date", "${selectedDate.toLocal()}".split(' ')[0], Icons.calendar_month, () async {
              final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2027));
              if (picked != null) setState(() => selectedDate = picked);
            }),
            
            const SizedBox(height: 15),
            
            _buildPickerTile("Time", selectedTime.format(context), Icons.access_time, () async {
              final picked = await showTimePicker(context: context, initialTime: selectedTime);
              if (picked != null) setState(() => selectedTime = picked);
            }),

            const Spacer(),
            PrimaryButton(text: "Confirm Booking - Rs. ${widget.serviceData['price']}", isLoading: isLoading, onPressed: confirmBooking),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile(String title, String value, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)), 
        subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
        trailing: Icon(icon, color: AppColors.primary), 
        onTap: onTap
      ),
    );
  }
}