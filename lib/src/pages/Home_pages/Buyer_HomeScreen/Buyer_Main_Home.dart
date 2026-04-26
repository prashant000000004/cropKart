import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Landing_pages/welcome.dart';
import 'BuyerCropDetails.dart';
import 'Buyer_OrdersScreen.dart';

class BuyerMainHome extends StatefulWidget {
  const BuyerMainHome({super.key});

  @override
  State<BuyerMainHome> createState() => _BuyerMainHomeState();
}

class _BuyerMainHomeState extends State<BuyerMainHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _BuyerBrowsePage(),
    const BuyerOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: const Color.fromRGBO(51, 114, 51, 1.0),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "My Orders",
          ),
        ],
      ),
    );
  }
}

/// Separate widget for the crop browsing page (the original body)
class _BuyerBrowsePage extends StatelessWidget {
  const _BuyerBrowsePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  childAspectRatio: 0.72,
                ),
                itemCount: cropDocs.length,
                itemBuilder: (context, index) {
                  var crop = cropDocs[index].data() as Map<String, dynamic>;
                  String docId = cropDocs[index].id;

                  // Parse availability
                  double availability = _parseAvailability(
                      crop["Availability"]?.toString() ?? "0");
                  bool isSoldOut = availability <= 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CropDetailsPage(
                            cropDetails: crop,
                            cropDocId: docId,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  crop["Product"] ?? "Unknown Product",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isSoldOut
                                        ? Colors.grey
                                        : const Color.fromRGBO(
                                            51, 114, 51, 1.0),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "₹${crop["CostPerKg"] ?? "N/A"}/Kg",
                                  style: TextStyle(
                                    color: isSoldOut
                                        ? Colors.grey
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rating: ${crop["CropRating"] ?? "N/A"} ⭐",
                                  style: TextStyle(
                                    color: isSoldOut
                                        ? Colors.grey
                                        : Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),

                                /// Availability chip
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isSoldOut
                                        ? Colors.red.shade50
                                        : const Color.fromRGBO(
                                            51, 114, 51, 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSoldOut
                                            ? Icons.remove_shopping_cart
                                            : Icons.inventory_2,
                                        size: 16,
                                        color: isSoldOut
                                            ? Colors.red
                                            : const Color.fromRGBO(
                                                51, 114, 51, 1.0),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          isSoldOut
                                              ? "Sold Out"
                                              : "${availability.toStringAsFixed(1)} Kg",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSoldOut
                                                ? Colors.red
                                                : const Color.fromRGBO(
                                                    51, 114, 51, 1.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Sold Out Overlay
                          if (isSoldOut)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
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

  double _parseAvailability(String value) {
    try {
      String cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
