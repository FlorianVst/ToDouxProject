import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'FirebaseOptions.dart';
import 'screens/HomePage.dart';
import 'screens/LoginPage.dart';
import 'models/Projet.dart';
import 'services/notification_service.dart'; // Import du service de notifications

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);

  // Initialisation des notifications avec Awesome Notifications
  await NotificationService().initializeNotifications();

  runApp(MyApp(projets: []));
}

class MyApp extends StatelessWidget {
  final List<Projet> projets;

  MyApp({required this.projets});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDouxProject',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationWrapper(projets: projets), // Wrapper pour l'authentification
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final List<Projet> projets;

  AuthenticationWrapper({required this.projets});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Écoute des changements d'authentification
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Indicateur de chargement si l'état est en attente
        }
        if (snapshot.hasData) {
          return HomePage(projets: projets); // Redirection vers HomePage si l'utilisateur est connecté
        }
        return LoginPage(); // Redirection vers LoginPage si l'utilisateur n'est pas connecté
      },
    );
  }
}

















