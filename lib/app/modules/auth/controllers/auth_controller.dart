import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../home/controllers/home_controller.dart';


class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> user = Rx<User?>(null);
  Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    user.bindStream(_auth.authStateChanges());
    ever(user, _handleAuthChanged);
    super.onInit();
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await fetchUserData(firebaseUser.uid);
    } else {
      userData.value = null;
    }
  }


  Future<void> fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userData.value = userDoc.data() as Map<String, dynamic>;
        // Optionally update HomeController with user data
        final homeController = Get.find<HomeController>();
        homeController.updateUserData(userData.value);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de récupérer les données utilisateur');
    }
  }

    Future<void> registerWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
    String address,
    String cin,
    String phone,
  ) async {
    try {
      // Créer un utilisateur avec email et mot de passe
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Ajouter les informations supplémentaires dans Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'nom': lastName,
          'prenom': firstName,
          'adresse': address,
          'CIN': cin,
          'telephone': phone,
          'email': email,
          'role': 'client',
          'account': {
            'balance': 0,
            'balanceMax': 1000000,
            'balanceMensuel': 20000,
            'status': 'ACTIVE',
            'qrcode': 'qrcodetoBase64',
          },
        });

        // Redirection vers la page d'accueil après inscription
        Get.snackbar('Succès', 'Compte créé avec succès');
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs spécifiques à Firebase Authentication
      String errorMessage = 'Une erreur s\'est produite';

      if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe est trop faible';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Un compte existe déjà avec cet email';
      }

      Get.snackbar('Erreur', errorMessage);
    } catch (e) {
      // Gestion des autres erreurs
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await fetchUserData(firebaseUser.uid);
        Get.snackbar('Succès', 'Connexion réussie');
        Get.offAllNamed('/home'); // Redirection vers le tableau de bord
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar('Erreur', 'Connexion annulée par l\'utilisateur');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        Get.snackbar('Erreur', 'Échec de l\'authentification Google');
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Vérifier si l'utilisateur existe déjà dans Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (!userDoc.exists) {
          // Créer un nouveau document utilisateur pour la connexion Google
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'nom': firebaseUser.displayName ?? '',
            'email': firebaseUser.email ?? '',
            'role': 'client',
            'account': {
              'balance': 0,
              'balanceMax': 1000000,
              'balanceMensuel': 20000,
              'status': 'ACTIVE',
              'qrcode': 'qrcodetoBase64',
            },
          });
        }

        await fetchUserData(firebaseUser.uid);
        Get.snackbar('Succès', 'Connexion Google réussie');
        Get.offAllNamed('/home'); // Redirection vers le tableau de bord
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
      print('Erreur Google Sign-In: $e');
    }
  }

  Future<void> verifyPhone(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar('Erreur', e.message ?? 'Erreur de vérification');
      },
      codeSent: (String verificationId, int? resendToken) {
        Get.toNamed('/verify-code', arguments: verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      Get.snackbar('Succès', 'Vérification réussie');
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
