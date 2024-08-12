import 'dart:io';

import 'package:car_pool_rider/models/rider.dart';
import 'package:car_pool_rider/services/auth_service.dart';
import 'package:car_pool_rider/services/rider_service.dart';
import 'package:car_pool_rider/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helper.dart';
import '../services/storage_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Rider Register Form
  final _riderRegisterFormKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _icTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  String? gender;
  final _emailTextController = TextEditingController();
  final _addressTextController = TextEditingController();
  final _phoneTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  XFile? image;

  bool isLoading = false;

  //Rider Register Form
  void _setGender(String? value) {
    gender = value;
  }

  void _setUploadImage(XFile imageToUpload) {
    image = imageToUpload;
  }

  //Validate Rider Register Form
  Future<void> validateRiderRegisterForm() async {
    setState(() {
      isLoading = true;
    });
    if (_riderRegisterFormKey.currentState!.validate()) {
      bool isDuplicated = await RiderService.checkIsDuplicated(
          _emailTextController.text.trim(), _icTextController.text.trim());
      if (isDuplicated) {
        Helper.showSnackBar(context, "This account is already registered");
        return;
      }
      String? uploadedFileURL;
      if (image != null) {
        uploadedFileURL =
        await StorageService.uploadImageToStorage(File(image!.path));
        if (uploadedFileURL == null) {
          Helper.showSnackBar(context,
              "Error occurred in uploading profile image. Please check connection");
        }
      }
      Rider riderRegisterModel = Rider(
        IC: _icTextController.text.trim(),
        name: _nameTextController.text.trim(),
        gender: gender!,
        email: _emailTextController.text.trim(),
        address: _addressTextController.text.trim(),
        phone: _phoneTextController.text.trim(),
        imageUrl: uploadedFileURL,
      );

      bool isSuccess = await AuthService.registerUser(
          _emailTextController.text.trim(),
          _passwordTextController.text.trim());

      if (!isSuccess) {
        Helper.showSnackBar(context,
            "Error occurred in register user");
        return;
      }

    bool isCreatedSuccess =
    await RiderService.createNewRider(riderRegisterModel);

      if (isCreatedSuccess){
        Helper.showSnackBar(context,
            "Your account is registered successfully");
        Navigator.pop(context);
      }else{
        Helper.showSnackBar(context,
            "Unexpected error occurred in registering account");
      }
    } else {
      debugPrint("Rider register form is not valid");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register as a Rider"),
      ),
      body: Column(
        children: [
          isLoading? const LinearProgressIndicator() : const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.black)),
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      children: [
                        RiderRegisterForm(
                          formKey: _riderRegisterFormKey,
                          icTextController: _icTextController,
                          nameTextController: _nameTextController,
                          phoneTextController: _phoneTextController,
                          emailTextController: _emailTextController,
                          addressTextController: _addressTextController,
                          passwordTextController: _passwordTextController,
                          setGender: _setGender,
                          setImageToUpload: _setUploadImage,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        validateRiderRegisterForm();
                      },
                      child: const Text("Register"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
