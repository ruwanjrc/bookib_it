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
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(user!.uid)
          .collection('services')
          .add({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'durationInMinutes': int.parse(durationController.text.trim()),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
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
            CustomTextField(hintText: "Service Name", prefixIcon: Icons.handyman, controller: nameController),
            CustomTextField(hintText: "Price (Rs.)", prefixIcon: Icons.attach_money, controller: priceController, keyboardType: TextInputType.number),
            CustomTextField(hintText: "Duration (Minutes)", prefixIcon: Icons.timer, controller: durationController, keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            PrimaryButton(text: "Save Service", isLoading: isLoading, onPressed: saveService),
          ],
        ),
      ),
    );
  }
}