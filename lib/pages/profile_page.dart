import 'dart:io';

import 'package:car_pool_rider/services/rider_service.dart';
import 'package:car_pool_rider/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helper.dart';
import '../models/driver.dart';
import '../models/rider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController icTextController = TextEditingController();
  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController phoneTextController = TextEditingController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController addressTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  String? gender;
  ImageProvider? userProfileImage;
  XFile? fileSelected;

  final TextEditingController carModelController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController specialFeaturesController =
      TextEditingController();

  Future<bool> checkPermission() async {
    var cameraPermission = await Permission.camera.status;
    var galleryPermission = await Permission.manageExternalStorage.status;

    if (cameraPermission.isDenied) {
      cameraPermission = await Permission.camera.request();
    }
    if (galleryPermission.isDenied) {
      cameraPermission = await Permission.manageExternalStorage.request();
    }
    if (cameraPermission.isGranted || galleryPermission.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  void showBottomSheetOption() async {
    if (await checkPermission()) {
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 80,
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    fileSelected = await _pickImage(ImageSource.camera);
                    if (fileSelected != null) {
                      Navigator.pop(context);
                      setState(() {
                        userProfileImage = FileImage(File(fileSelected!.path));
                      });
                    } else {
                      Navigator.pop(context);
                      Helper.showSnackBar(context, "Action cancel");
                    }
                  },
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                ),
                TextButton.icon(
                  onPressed: () async {
                    fileSelected = await _pickImage(ImageSource.gallery);
                    if (fileSelected != null) {
                      Navigator.pop(context);
                      setState(() {
                        userProfileImage = FileImage(File(fileSelected!.path));
                      });
                    } else {
                      Navigator.pop(context);
                      Helper.showSnackBar(context, "Action cancel");
                    }
                  },
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                ),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.pop(context);
      Helper.showSnackBar(context, "Permission denied");
    }
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: source);
    return image;
  }

  void initPage() async {
    Rider? rider = await RiderService.getCurrentLoginUser();
    if (rider == null) {
      return;
    } else {
      icTextController.text = rider.IC!;
      nameTextController.text = rider.name!;
      phoneTextController.text = rider.phone!;
      emailTextController.text = rider.email!;
      addressTextController.text = rider.address!;

      if (rider.imageUrl != null) {
        userProfileImage = NetworkImage(rider.imageUrl!);
      }

      if (mounted) {
        setState(() {
          gender = rider.gender;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initPage();
  }

  void updateProfile() async {
    debugPrint("Clicked");
    late Rider riderUpdateModel;
    if (fileSelected == null) {
      riderUpdateModel = Rider(
        name: nameTextController.text.trim(),
        phone: phoneTextController.text.trim(),
        address: addressTextController.text.trim(),
      );
    } else {
      String? uploadedImageURL =
          await StorageService.uploadImageToStorage(File(fileSelected!.path));
      if (uploadedImageURL == null) {
        Helper.showSnackBar(context,
            "Unable to upload new profile image. Check internet connection");
        return;
      }

      riderUpdateModel = Rider(
        name: nameTextController.text.trim(),
        phone: phoneTextController.text.trim(),
        address: addressTextController.text.trim(),
        imageUrl: uploadedImageURL,
      );
    }

    bool isSuccess = await RiderService.updateRiderDetails(riderUpdateModel);
    if (isSuccess) {
      Helper.showSnackBar(context, "Profile updated successfully");
    } else {
      Helper.showSnackBar(context, "Error occurred in updating profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          children: [
            const Text(
              "Rider Profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Stack(
              children: [
                userProfileImage == null
                    ? const CircleAvatar(
                        radius: 60,
                        child: Icon(
                          Icons.person,
                          size: 60,
                        ),
                      )
                    : CircleAvatar(
                        backgroundImage: userProfileImage,
                        radius: 60,
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    radius: 20,
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      showBottomSheetOption();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.blue[600],
                      radius: 20,
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            //IC
            TextFormField(
              controller: icTextController,
              readOnly: true,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "IC Number",
                labelText: "IC Number",
                isDense: true,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            //Name
            TextFormField(
              controller: nameTextController,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Name",
                labelText: "Name",
                isDense: true,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            //Gender Dropdown
            DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Gender",
                labelText: "Gender",
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Gender is required";
                }
                return null;
              },
              items: const [
                DropdownMenuItem(
                  value: "male",
                  child: Text("Male"),
                ),
                DropdownMenuItem(
                  value: "female",
                  child: Text("Female"),
                ),
              ],
              value: gender,
              onChanged: null,
            ),
            const SizedBox(
              height: 10.0,
            ),
            //Email
            TextFormField(
              readOnly: true,
              controller: emailTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Email",
                labelText: "Email",
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                if (!value.isEmail()) {
                  return 'Please provide a valid email';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            //Phone
            TextFormField(
              controller: phoneTextController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Phone Number",
                labelText: "Phone Number",
                isDense: true,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Phone number is required";
                }
                if (!RegExp(r'\d{3}-\d{7,9}').hasMatch(value)) {
                  return 'Please provide a phone number. Ex: 012-36202024';
                }
                return null;
              },
              onChanged: (value) {
                String digits = value.replaceAll(RegExp(r'\D'), "");
                if (digits.length > 12) {
                  phoneTextController.text =
                      "${digits.substring(0, 3)}-${digits.substring(3, 12)}";
                } else if (digits.length > 3) {
                  phoneTextController.text =
                      "${digits.substring(0, 3)}-${digits.substring(3)}";
                } else {
                  phoneTextController.text = digits.substring(0);
                }
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            //Address
            TextFormField(
              controller: addressTextController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Address",
                labelText: "Address",
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Address is required";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  updateProfile();
                },
                child: const Text("Update Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
