import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helper.dart';

class RiderRegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController icTextController;
  final TextEditingController nameTextController;
  final TextEditingController phoneTextController;
  final TextEditingController emailTextController;
  final TextEditingController addressTextController;
  final TextEditingController passwordTextController;
  final Function(String?) setGender;
  final Function(XFile file) setImageToUpload;

  const RiderRegisterForm({
    super.key,
    required this.formKey,
    required this.icTextController,
    required this.nameTextController,
    required this.phoneTextController,
    required this.emailTextController,
    required this.passwordTextController,
    required this.addressTextController,
    required this.setGender,
    required this.setImageToUpload,
  });

  @override
  State<RiderRegisterForm> createState() => _RiderRegisterFormState();
}

class _RiderRegisterFormState extends State<RiderRegisterForm> {
  XFile? fileSelected;

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
                      setState(() {});
                      widget.setImageToUpload(fileSelected!);
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
                      setState(() {});
                      widget.setImageToUpload(fileSelected!);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
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
                  (fileSelected != null)
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(File(fileSelected!.path)),
                        )
                      : const CircleAvatar(
                          radius: 60,
                          child: Icon(
                            Icons.person,
                            size: 60,
                          ),
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
                controller: widget.icTextController,
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "IC Number",
                  labelText: "IC Number",
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "IC Number is required";
                  }
                  return null;
                },
                onChanged: (value) {
                  String digits = value.replaceAll(RegExp(r'\D'), "");
                  debugPrint(digits);
                  if (digits.length > 12) {
                    widget.icTextController.text =
                        "${digits.substring(0, 6)}-${digits.substring(6, 8)}-${digits.substring(8, 12)}";
                  } else if (digits.length > 8) {
                    widget.icTextController.text =
                        "${digits.substring(0, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}";
                  } else if (digits.length > 6) {
                    widget.icTextController.text =
                        "${digits.substring(0, 6)}-${digits.substring(6)}";
                  } else {
                    widget.icTextController.text = digits.substring(0);
                  }
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              //Name
              TextFormField(
                controller: widget.nameTextController,
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Name",
                  labelText: "Name",
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              //Gender Dropdown
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Choose your gender",
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
                onChanged: (value) {
                  widget.setGender(value);
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              //Email
              TextFormField(
                controller: widget.emailTextController,
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
                controller: widget.phoneTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Phone Number",
                  labelText: "Phone Number",
                  isDense: true,
                  errorMaxLines: 3,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number is required";
                  }
                  if (!RegExp(r'\d{3}-\d{7,9}').hasMatch(value)) {
                    return 'Please provide a phone number. Ex: 012-36202023';
                  }
                  return null;
                },
                onChanged: (value){
                  String digits = value.replaceAll(RegExp(r'\D'), "");
                  if (digits.length > 12) {
                    widget.phoneTextController.text =
                    "${digits.substring(0, 3)}-${digits.substring(3, 12)}";
                  }  else if (digits.length > 3) {
                    widget.phoneTextController.text =
                    "${digits.substring(0, 3)}-${digits.substring(3)}";
                  } else {
                    widget.phoneTextController.text = digits.substring(0);
                  }
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              //Address
              TextFormField(
                controller: widget.addressTextController,
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
              //Password
              TextFormField(
                obscureText: true,
                controller: widget.passwordTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                  labelText: "Password",
                  isDense: true,
                  errorMaxLines: 3,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  if (!value.isPasswordHard()) {
                    return "Please provide a strong password. Combination of symbol and capital letter";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Confirm Password",
                  labelText: "Confirm Password",
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirm Password is required";
                  }
                  if (value != widget.passwordTextController.text.trim()) {
                    return "Confirm password must be same";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
