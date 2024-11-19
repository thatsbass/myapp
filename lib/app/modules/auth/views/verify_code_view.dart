// lib/app/modules/auth/views/verify_code_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class VerifyCodeView extends GetView<AuthController> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String verificationId = Get.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('Vérifier le code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Code de vérification',
                  prefixIcon: const Icon(Icons.lock_clock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.verifyCode(
                  verificationId,
                  codeController.text,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Vérifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
