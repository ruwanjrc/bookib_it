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
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descController = TextEditingController();
  String selectedCategory = 'Salon';
  bool isLoading = false;

  Future<void> createShop() async {
    if (nameController.text.isEmpty || addressController.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('shops').doc(currentUser!.uid).set({
        'ownerId': currentUser!.uid,
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'description': descController.text.trim(),
        'category': selectedCategory,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Dashboard"),
        actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout, color: Colors.red))],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('shops').doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShopHeader(data),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("My Services", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddServiceScreen())),
                        icon: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.add, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildServiceList(),
                ],
              ),
            );
          }

          return _buildCreateShopForm();
        },
      ),
    );
  }

  Widget _buildShopHeader(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8E88FF)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.storefront, size: 48, color: Colors.white),
          const SizedBox(height: 10),
          Text(data['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(data['category'], style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white),
              const SizedBox(width: 5),
              Text(data['address'], style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('shops').doc(currentUser!.uid).collection('services').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No services added yet."));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final item = docs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${item['durationInMinutes']} mins"),
                trailing: Text("Rs. ${item['price']}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateShopForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text("Setup your Business Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          CustomTextField(hintText: "Shop Name", prefixIcon: Icons.store, controller: nameController),
          CustomTextField(hintText: "Address", prefixIcon: Icons.location_on, controller: addressController),
          CustomTextField(hintText: "Description", prefixIcon: Icons.description, controller: descController),
          const SizedBox(height: 30),
          PrimaryButton(text: "Create Shop", isLoading: isLoading, onPressed: createShop),
        ],
      ),
    );
  }
}