import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/primary_button.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final cityController = TextEditingController();
  final serviceTypeController = TextEditingController();
  bool isLoading = false;

  Future<void> addServiceType() async {
    if (serviceTypeController.text.isEmpty) return;
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('service_types').add({
      'name': serviceTypeController.text.trim(),
    });
    serviceTypeController.clear();
    setState(() => isLoading = false);
  }

  Future<void> addLocation() async {
    if (cityController.text.isEmpty) return;
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('locations').add({
      'name': cityController.text.trim(),
    });
    cityController.clear();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Super Admin Panel")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Service Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CustomTextField(hintText: "E.g. Salon, Spa, Gym", prefixIcon: Icons.category, controller: serviceTypeController),
            PrimaryButton(text: "Add Type", isLoading: isLoading, onPressed: addServiceType),
            _buildChips('service_types'),
            
            const Divider(height: 40),
            
            const Text("Add City", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CustomTextField(hintText: "E.g. Colombo, Kandy", prefixIcon: Icons.location_city, controller: cityController),
            PrimaryButton(text: "Add City", isLoading: isLoading, onPressed: addLocation),
            _buildChips('locations'),
          ],
        ),
      ),
    );
  }

  Widget _buildChips(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Wrap(
          spacing: 8,
          children: snapshot.data!.docs.map((doc) => Chip(
            label: Text(doc['name']),
            onDeleted: () => FirebaseFirestore.instance.collection(collection).doc(doc.id).delete(),
          )).toList(),
        );
      },
    );
  }
}