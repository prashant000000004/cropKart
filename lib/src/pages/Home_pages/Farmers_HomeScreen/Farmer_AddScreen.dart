import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class FarmerAddscreen extends StatefulWidget {
  const FarmerAddscreen({super.key});

  @override
  State<FarmerAddscreen> createState() => _FarmerAddscreenState();
}

class _FarmerAddscreenState extends State<FarmerAddscreen> {
  final ProductController = TextEditingController();
  final AvailabilityController = TextEditingController();
  final CostPerKgController = TextEditingController();
  final HarvestDateController = TextEditingController();
  final ExpiryDateController = TextEditingController();
  final PhoneNumberController = TextEditingController();

  String Croptype = '';
  String CropRating = "";
  String CropUploadedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String PriceType = '';
  String Location = "";
  final FarmerNameController = TextEditingController();

  // Function to get the current location

  Future<String> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Location services are disabled";
    }

    // Request location permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return "Location permission denied";
    }

    // Get the current position of the device
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Set high accuracy
        timeLimit: Duration(seconds: 10), // Add a timeout to prevent long waits
      );

      // Convert coordinates into a readable address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark placemark = placemarks[0]; // Get the first result

      // Construct a human-readable address
      String location =
          "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";

      return location;
    } catch (e) {
      return "Error getting location: ${e.toString()}";
    }
  }

  ///form key
  final GlobalKey<FormState> farmerAddGkey = GlobalKey<FormState>();

  ///all the firestore crud opreations
  Future AddTheCropDeatils() async {
    try {
      final user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user == null) {
        // Handle the case if the user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User not logged in"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection("CropMain").add({
        "Product": ProductController.text.trim(),
        "Availability": AvailabilityController.text.trim(),
        "CostPerKg": CostPerKgController.text.trim(),
        "HarvestDate": HarvestDateController.text.trim(),
        "ExpiryDate": ExpiryDateController.text.trim(),
        "FarmerName": FarmerNameController.text.trim(),
        "Croptype": Croptype,
        "CropRating": CropRating,
        "CropUploadedDate": CropUploadedDate,
        "PriceType": PriceType,
        "PhoneNumber": PhoneNumberController.text.trim(),
        "Location": Location,
        "FarmerUID": user.uid, // Store the farmer's UID
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Your Crop is Successfully Added",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromRGBO(51, 114, 51, 1.0),
        ),
      );

      print("crop created");
      ProductController.clear();
      AvailabilityController.clear();
      CostPerKgController.clear();
      Croptype = "";
      CropRating = '';
      PhoneNumberController.clear();
      FarmerNameController.clear();
      HarvestDateController.clear();
      ExpiryDateController.clear();

      Location = "";
      PriceType = "";
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message.toString(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromRGBO(51, 114, 51, 1.0),
        ),
      );
    }
  }

  Future<void> _getLocation() async {
    String location =
        await getCurrentLocation(); // Fetch the location asynchronously
    setState(() {
      Location = location; // Update the location value
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Your Crop",
          style: TextStyle(
            color: Color.fromRGBO(51, 114, 51, 1.0),
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: farmerAddGkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10,
                      top: 15,
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Farmer Name";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        label: Text("Farmer Name"),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-SemiBold",
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(51, 114, 51, 1.0),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                      ),
                      controller: FarmerNameController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          " * Please Enter Valid Farmer Name",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10,
                      top: 15,
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Phone Number";
                        } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                          return "Enter a valid phone number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: Text("Phone Number"),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-SemiBold",
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(51, 114, 51, 1.0),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                      ),
                      controller: PhoneNumberController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          " * Please Enter Valid PhoneNumber",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Product";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        label: Text("Product"),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-SemiBold",
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(51, 114, 51, 1.0),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                      ),
                      controller: ProductController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      " * Please Mention Crops Like Potatoes Or Tomatoes.",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Availability";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        label: Text("Availability"),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-SemiBold",
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(51, 114, 51, 1.0),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                      ),
                      controller: AvailabilityController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          " * Please Mention Availability in Kgs.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Cost Per Kg";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        label: Text("Cost Per Kg"),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-SemiBold",
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(51, 114, 51, 1.0),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                      ),
                      controller: CostPerKgController,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          " * Expecting Cost per Kg",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 19.0,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildPriceTypeCheckBox("Fixed Price"),
                        SizedBox(width: 15),
                        _buildPriceTypeCheckBox("Negotiable"),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          " * Select the Price Type",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 19.0,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildCheckBox("Organic"),
                        SizedBox(width: 20),
                        _buildCheckBox("Hybrid"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      " *  Please Click The Checkbox To Select The Crop Variety",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: HarvestDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Harvest Date",
                        prefixIcon: Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onTap: () async {
                        FocusScope.of(
                          context,
                        ).requestFocus(FocusNode()); // 🔥 VERY IMPORTANT
                        await _pickHarvestDate(); // 🔥 await
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: ExpiryDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Expiry Date",
                        prefixIcon: Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onTap: () async {
                        FocusScope.of(
                          context,
                        ).requestFocus(FocusNode()); // 🔥 VERY IMPORTANT
                        await _pickExpiryDate(); // 🔥 await
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 10),
                    child: RatingBar(
                      filledColor: Color.fromRGBO(51, 114, 51, 1.0),
                      size: 40,
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      onRatingChanged: (p0) {
                        CropRating = p0.toString();
                      },
                      initialRating: 0,
                      maxRating: 5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          " * Rate your crop from 1 to 5.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (farmerAddGkey.currentState!.validate()) {
                            await AddTheCropDeatils();
                          }
                        },
                        child: Text(
                          "Submit My Crop",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(padding: const EdgeInsets.all(8.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBox(String label) {
    bool isSelected = Croptype == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          Croptype = label;
        });
        print(Croptype);
        print(CropRating);
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              color: isSelected ? Colors.green : Colors.transparent,
            ),
            child:
                isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
          ),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildPriceTypeCheckBox(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          PriceType = label;
        });
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              color: PriceType == label ? Colors.green : Colors.transparent,
            ),
            child:
                PriceType == label
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
          ),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Future<void> _pickHarvestDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        HarvestDateController.text = DateFormat(
          'dd-MM-yyyy',
        ).format(pickedDate);
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // expiry should not be past
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        ExpiryDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }
}
