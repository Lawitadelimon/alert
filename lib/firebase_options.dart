// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Puedes personalizar aquí según el paquete
        return androidPhone; // o usar lógica para elegir según package
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for this platform.',
        );
      case TargetPlatform.fuchsia:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // Configuración para com.phone
  static const FirebaseOptions androidPhone = FirebaseOptions(
    apiKey: 'AIzaSyCKZynRVE0pAJ7uaRlbp3Dty45fRqMEtG8',
    appId: '1:748366412187:android:1b90d8438c5f52da00893e',
    messagingSenderId: '748366412187',
    projectId: 'alert2-56723',
    storageBucket: 'alert2-56723.firebasestorage.app',
  );

  // Configuración para com.watch
  static const FirebaseOptions androidWatch = FirebaseOptions(
    apiKey: 'AIzaSyCKZynRVE0pAJ7uaRlbp3Dty45fRqMEtG8',
    appId: '1:748366412187:android:b97424d10b73e1ac00893e',
    messagingSenderId: '748366412187',
    projectId: 'alert2-56723',
    storageBucket: 'alert2-56723.firebasestorage.app',
  );
}
