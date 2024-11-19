import 'package:get/get.dart';

class HomeController extends GetxController {
  // Données utilisateur
  Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);

  // Solde du compte
  RxDouble balance = 0.0.obs;

  // Statut du compte
  RxString accountStatus = 'INACTIVE'.obs;

  void updateUserData(Map<String, dynamic>? data) {
    if (data != null) {
      userData.value = data;

      // Mettre à jour le solde
      if (data['account'] != null && data['account']['balance'] != null) {
        balance.value = double.parse(data['account']['balance'].toString());
      }

      // Mettre à jour le statut du compte
      if (data['account'] != null && data['account']['status'] != null) {
        accountStatus.value = data['account']['status'];
      }
    }
  }

  // Méthodes supplémentaires pour gérer les transactions, etc.
  void sendMoney() {
    // Logique d'envoi d'argent
  }

  void requestMoney() {
    // Logique de demande d'argent
  }
}