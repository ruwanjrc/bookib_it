import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/primary_button.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  bool isLoading = false;

  Future<void> saveService() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;

    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      // කඩේ (Shop) ඇතුළේ 'services' කියලා collection එකකට සේව් කරනවා
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(user!.uid)
          .collection('services')
          .add({
        'name': nameController.text.trim(),
        'price': priceController.text.trim(),
        'durationInMinutes': durationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // සේව් වුණාම කලින් පේජ් එකට යනවා
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Service Added!")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Service")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(hintText: "Service Name (e.g. Hair Cut)", prefixIcon: Icons.design_services, controller: nameController),
            const SizedBox(height: 15),
            CustomTextField(hintText: "Price (Rs.)", prefixIcon: Icons.payments, controller: priceController),
            const SizedBox(height: 15),
            CustomTextField(hintText: "Duration (Minutes)", prefixIcon: Icons.timer, controller: durationController),
            const SizedBox(height: 30),
            PrimaryButton(text: "Save Service", isLoading: isLoading, onPressed: saveService),
          ],
        ),
      ),
    );
  }
}