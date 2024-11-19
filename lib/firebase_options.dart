import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Remplace ces valeurs par celles de ta console Firebase
    return const FirebaseOptions(
      apiKey: "AIzaSyDhAD4o3PJscRPmRzfR5h-SglrVodXc598",
      authDomain: "peril-54f0d.firebaseapp.com",
      projectId: "peril-54f0d",
      storageBucket: "peril-54f0d.firebasestorage.app",
      messagingSenderId: "798156677861",
      appId: "1:798156677861:android:ba1d56e5ca058fffc52a0c"
    );
  }
}