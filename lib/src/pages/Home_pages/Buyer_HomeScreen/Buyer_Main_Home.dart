import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Landing_pages/welcome.dart';
import 'BuyerCropDetails.dart';

class BuyerMainHome extends StatefulWidget {
  const BuyerMainHome({super.key});

  @override
  State<BuyerMainHome> createState() => _BuyerMainHomeState();
}

class _BuyerMainHomeState extends State<BuyerMainHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buyer Dashboard",
          style: TextStyle(
            fontFamily: 'Poppins-SemiBold',
            color: Color.fromRGBO(51, 114, 51, 1.0),
          ),
        ),
        titleSpacing: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.home, color: Color.fromRGBO(51, 114, 51, 1.0)),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            /// ================= HEADER =================
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color.fromRGBO(51, 114, 51, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Color.fromRGBO(51, 114, 51, 1.0),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// User Name
                    Text(
                      "Ramesh Singh", // fetch from Firebase
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins-SemiBold',
                        fontSize: 16,
                      ),
                    ),

                    /// User Email
                    Text(
                      "rameshk34@gmail.com", // fetch from Firebase
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins-Regular',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ================= MENU ITEMS =================
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                "About CropKart",
                style: TextStyle(fontFamily: 'Poppins-Medium'),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to About Page
              },
            ),

            ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text(
                "Privacy Policy",
                style: TextStyle(fontFamily: 'Poppins-Medium'),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text(
                "Help & Support",
                style: TextStyle(fontFamily: 'Poppins-Medium'),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Divider(),

            /// ================= FOOTER =================
            Spacer(),

            /// App Version
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Poppins-Regular',
                ),
              ),
            ),

            /// Logout Button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text(
                    "Logout",
                    style: TextStyle(fontFamily: 'Poppins-SemiBold'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => welcome()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('CropMain').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something Went Wrong"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No crops available"));
          } else {
            var cropDocs = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: cropDocs.length,
                itemBuilder: (context, index) {
                  var crop = cropDocs[index].data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CropDetailsPage(cropDetails: crop),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              crop["Product"] ?? "Unknown Product",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color.fromRGBO(51, 114, 51, 1.0),
                              ),
                            ),
                            Text(
                              "CostPerKg: ₹${crop["CostPerKg"] ?? "N/A"}",
                              style: const TextStyle(color: Colors.black),
                            ),
                            Text(
                              "CropRating: ₹${crop["CropRating"] ?? "N/A"}",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
