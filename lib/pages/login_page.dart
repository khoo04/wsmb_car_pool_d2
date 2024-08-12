import 'package:car_pool_rider/pages/register_page.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _icTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  Future<void> _loginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      await AuthService.loginUser(_icTextController.text.trim(),
          _passwordTextController.text.trim(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                children: [
                  const Icon(Icons.car_rental_outlined, size:128,),
                  const SizedBox(height: 10,),
                  const Text(
                    "Car Pool App",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                  ),
                  const Text(
                    "Riders",
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: _icTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "IC Number",
                      labelText: "IC Number",
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "IC is required";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      String digits = value.replaceAll(RegExp(r'\D'), "");
                      debugPrint(digits);
                      if (digits.length > 12) {
                        _icTextController.text =
                            "${digits.substring(0, 6)}-${digits.substring(6, 8)}-${digits.substring(8, 12)}";
                      } else if (digits.length > 8) {
                        _icTextController.text =
                            "${digits.substring(0, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}";
                      } else if (digits.length > 6) {
                        _icTextController.text =
                            "${digits.substring(0, 6)}-${digits.substring(6)}";
                      } else {
                        _icTextController.text = digits.substring(0);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: _passwordTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Password",
                      labelText: "Password",
                      isDense: true,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            await _loginUser();
                          },
                          child: const Text("Login")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterPage()));
                          },
                          child: const Text("Register")),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
