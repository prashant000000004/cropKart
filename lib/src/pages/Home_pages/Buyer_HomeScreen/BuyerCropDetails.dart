import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CropDetailsPage extends StatefulWidget {
  final Map<String, dynamic> cropDetails;
  final String cropDocId;

  const CropDetailsPage({
    super.key,
    required this.cropDetails,
    required this.cropDocId,
  });

  @override
  State<CropDetailsPage> createState() => _CropDetailsPageState();
}

class _CropDetailsPageState extends State<CropDetailsPage> {
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    // Parse availability to check if sold out
    double availability = _parseAvailability(
        widget.cropDetails["Availability"]?.toString() ?? "0");
    bool isSoldOut = availability <= 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(51, 114, 51, 1.0),
        title: Text(
          widget.cropDetails["Product"] ?? "Crop Details",
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Poppins-SemiBold'),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      /// Sold Out Banner
                      if (isSoldOut)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "SOLD OUT",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Poppins-SemiBold',
                                ),
                              ),
                            ],
                          ),
                        ),

                      /// Availability highlight
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSoldOut
                              ? Colors.grey.shade100
                              : const Color.fromRGBO(51, 114, 51, 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              color: isSoldOut
                                  ? Colors.grey
                                  : const Color.fromRGBO(51, 114, 51, 1.0),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Available: ${widget.cropDetails["Availability"] ?? "N/A"} Kg",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins-SemiBold',
                                color: isSoldOut
                                    ? Colors.grey
                                    : const Color.fromRGBO(51, 114, 51, 1.0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      detailRow("Product", widget.cropDetails["Product"]),
                      detailRow("Availability",
                          "${widget.cropDetails["Availability"]}"),
                      detailRow("Cost Per Kg",
                          "₹${widget.cropDetails["CostPerKg"]}"),
                      detailRow(
                          "Crop Rating", widget.cropDetails["CropRating"]),
                      detailRow("Crop Type", widget.cropDetails["Croptype"]),
                      detailRow("Uploaded Date",
                          widget.cropDetails["CropUploadedDate"]),
                      detailRow(
                          "Harvest Date", widget.cropDetails["HarvestDate"]),
                      detailRow(
                          "Expiry Date", widget.cropDetails["ExpiryDate"]),
                      detailRow(
                          "Price Type", widget.cropDetails["PriceType"]),
                      detailRow("Location", widget.cropDetails["Location"]),
                      detailRow("Farmer", widget.cropDetails["FarmerName"]),
                      detailRow(
                          "Phone Number", widget.cropDetails["PhoneNumber"]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// Buy Now Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSoldOut || _isPurchasing
                    ? null
                    : () => _showBuyBottomSheet(context),
                icon: Icon(
                  isSoldOut ? Icons.block : Icons.shopping_cart,
                  color: Colors.white,
                ),
                label: Text(
                  isSoldOut ? "Sold Out" : "Buy Now",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Poppins-SemiBold',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSoldOut
                      ? Colors.grey
                      : const Color.fromRGBO(51, 114, 51, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseAvailability(String value) {
    try {
      // Remove any non-numeric characters except dot
      String cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  void _showBuyBottomSheet(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();
    double availableStock = _parseAvailability(
        widget.cropDetails["Availability"]?.toString() ?? "0");
    double costPerKg = _parseAvailability(
        widget.cropDetails["CostPerKg"]?.toString() ?? "0");
    double totalCost = 0;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setBottomSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Title
                  Text(
                    "Buy ${widget.cropDetails["Product"] ?? "Crop"}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins-SemiBold',
                      color: Color.fromRGBO(51, 114, 51, 1.0),
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Available stock info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(51, 114, 51, 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Available Stock:",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          "${availableStock.toStringAsFixed(1)} Kg",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(51, 114, 51, 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(51, 114, 51, 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price Per Kg:",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          "₹${costPerKg.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(51, 114, 51, 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Quantity input
                  TextField(
                    controller: quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Quantity (Kg)",
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins-SemiBold',
                      ),
                      hintText: "Enter quantity in Kg",
                      errorText: errorText,
                      prefixIcon: const Icon(Icons.scale,
                          color: Color.fromRGBO(51, 114, 51, 1.0)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color.fromRGBO(51, 114, 51, 1.0),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    onChanged: (value) {
                      double qty = double.tryParse(value) ?? 0;
                      setBottomSheetState(() {
                        if (qty <= 0) {
                          errorText = "Enter a valid quantity";
                          totalCost = 0;
                        } else if (qty > availableStock) {
                          errorText =
                              "Cannot exceed available stock (${availableStock.toStringAsFixed(1)} Kg)";
                          totalCost = 0;
                        } else {
                          errorText = null;
                          totalCost = qty * costPerKg;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Total cost display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(51, 114, 51, 1.0),
                          Color.fromRGBO(76, 155, 76, 1.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Cost:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontFamily: 'Poppins-SemiBold',
                          ),
                        ),
                        Text(
                          "₹${totalCost.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins-SemiBold',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Confirm Purchase Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: (errorText != null ||
                              totalCost <= 0 ||
                              _isPurchasing)
                          ? null
                          : () async {
                              double qty = double.tryParse(
                                      quantityController.text) ??
                                  0;
                              Navigator.pop(bottomSheetContext);
                              await _confirmPurchase(qty, totalCost, costPerKg);
                            },
                      icon: _isPurchasing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle,
                              color: Colors.white),
                      label: Text(
                        _isPurchasing
                            ? "Processing..."
                            : "Confirm Purchase",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Poppins-SemiBold',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(51, 114, 51, 1.0),
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmPurchase(
      double quantity, double totalCost, double costPerKg) async {
    setState(() => _isPurchasing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage("Please login to make a purchase", Colors.red);
        setState(() => _isPurchasing = false);
        return;
      }

      // Fetch buyer name from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String buyerName = "Unknown Buyer";
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;
        buyerName = userData?['name'] ?? userData?['fullName'] ?? user.email ?? "Unknown Buyer";
      }

      // Use a Firestore transaction for atomic operation
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Read the current crop document
        DocumentReference cropRef = FirebaseFirestore.instance
            .collection('CropMain')
            .doc(widget.cropDocId);
        DocumentSnapshot cropSnapshot = await transaction.get(cropRef);

        if (!cropSnapshot.exists) {
          throw Exception("Crop no longer exists");
        }

        var cropData = cropSnapshot.data() as Map<String, dynamic>;
        double currentAvailability =
            _parseAvailability(cropData['Availability']?.toString() ?? "0");

        if (quantity > currentAvailability) {
          throw Exception(
              "Not enough stock. Only ${currentAvailability.toStringAsFixed(1)} Kg available.");
        }

        // Subtract the quantity
        double newAvailability = currentAvailability - quantity;

        // Update the crop availability
        transaction.update(cropRef, {
          'Availability': newAvailability.toStringAsFixed(1),
        });

        // Create the order document
        String orderDate =
            DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
        DocumentReference orderRef =
            FirebaseFirestore.instance.collection('Orders').doc();

        transaction.set(orderRef, {
          'buyerUID': user.uid,
          'buyerName': buyerName,
          'farmerUID': cropData['FarmerUID'] ?? '',
          'farmerName': cropData['FarmerName'] ?? 'Unknown',
          'farmerPhone': cropData['PhoneNumber'] ?? '',
          'cropDocId': widget.cropDocId,
          'product': cropData['Product'] ?? '',
          'quantityKg': quantity,
          'costPerKg': costPerKg.toStringAsFixed(2),
          'totalCost': totalCost.toStringAsFixed(2),
          'orderDate': orderDate,
          'orderTimestamp': FieldValue.serverTimestamp(),
          'status': 'Placed',
        });
      });

      if (mounted) {
        _showMessage("Purchase successful! 🎉", const Color.fromRGBO(51, 114, 51, 1.0));

        // Update local crop details to reflect new availability
        double newAvail = _parseAvailability(
                widget.cropDetails["Availability"]?.toString() ?? "0") -
            quantity;
        setState(() {
          widget.cropDetails["Availability"] =
              newAvail.toStringAsFixed(1);
          _isPurchasing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage("Purchase failed: ${e.toString()}", Colors.red);
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
