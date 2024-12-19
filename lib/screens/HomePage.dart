import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Projet.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'ConfigProjetPage.dart';
import 'DetailsProjetPage.dart';
import 'EditProjetPage.dart';

class HomePage extends StatefulWidget {
  final List<Projet> projets;

  HomePage({required this.projets});

  @override
  _HomePageState createState() => _HomePageState(projets: projets);
}

class _HomePageState extends State<HomePage> {
  List<Projet> projets;

  _HomePageState({required this.projets});

  @override
  void initState() {
    super.initState();
    _chargerProjets(); // Charge les projets au démarrage
    _lancerNotificationsEtapes();
  }

  void _chargerProjets() async {
    try {
      List<Projet> projetsRecuperes = await FirestoreService().recupererProjets();
      print("Projets chargés : ${projetsRecuperes.length}");

      setState(() {
        projets = projetsRecuperes;
      });
    } catch (e) {
      print('Erreur lors du chargement des projets : $e');
    }
  }

  void _lancerNotificationsEtapes() async {
    List<Map<String, dynamic>> projetsAVenir = [];

    for (var projet in projets) {
      try {
        // Vérifie si la deadline du projet est dans le futur
        if (projet.deadline.isAfter(DateTime.now())) {
          print("Projet : ${projet.nom}, Deadline : ${projet.deadline}");
          projetsAVenir.add({
            'nom': projet.nom,
            'deadline': projet.deadline.toIso8601String(),
          });
        }
      } catch (e) {
        print("Erreur avec le projet '${projet.nom}' : $e");
      }
    }

    print("Projets valides trouvés : $projetsAVenir");

    // Planifie les notifications pour les projets avec des deadlines futures
    if (projetsAVenir.isNotEmpty) {
      for (var projet in projetsAVenir) {
        await NotificationService().scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // ID unique
          title: "🔔 Rappel : ${projet['nom']}",
          body: "La deadline approche pour le projet '${projet['nom']}'.",
          scheduledDate: DateTime.parse(projet['deadline']),
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notifications planifiées pour ${projetsAVenir.length} projet(s).")),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Aucun projet valide trouvé pour les notifications.")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDouxProject"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: projets.isEmpty
          ? Center(child: Text("Aucun projet enregistré"))
          : ListView.builder(
        itemCount: projets.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(projets[index].nom),
              subtitle: Text(
                  "Deadline: ${projets[index].deadline.toLocal().toString().split(' ')[0]}"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailsProjetPage(projet: projets[index]),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editProjet(projets[index]),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteProjet(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add_project",
            onPressed: _ajouterProjet, // Ajoute un nouveau projet
            child: Icon(Icons.add),
            tooltip: "Ajouter un projet",
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "test_notifications",
            onPressed: () {
              // Lance les notifications de test aléatoires
              List<Map<String, dynamic>> toutesLesEtapes = [];
              for (var projet in projets) {
                toutesLesEtapes.addAll(projet.etapes);
              }
              NotificationService().scheduleRandomStepNotifications(toutesLesEtapes);
            },
            child: Icon(Icons.notifications_active),
            tooltip: "Lancer les notifications de test",
          ),
        ],
      ),
    );
  }

  // Méthode pour éditer un projet
  void _editProjet(Projet projet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProjetPage(projet: projet),
      ),
    ).then((updatedProjet) {
      if (updatedProjet != null) {
        setState(() {
          int index = projets.indexWhere((p) => p.id == updatedProjet.id);
          if (index != -1) {
            projets[index] = updatedProjet;
          }
        });
      }
    });
  }

  // Méthode pour ajouter un projet
  void _ajouterProjet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfigProjetPage()),
    ).then((nouveauProjet) {
      if (nouveauProjet != null && nouveauProjet is Projet) {
        setState(() {
          projets.add(nouveauProjet);
        });
      }
    });
  }

  // Méthode pour supprimer un projet
  void _deleteProjet(int index) async {
    try {
      await FirestoreService().supprimerProjet(projets[index].id);
      setState(() {
        projets.removeAt(index);
      });
    } catch (e) {
      print('Erreur lors de la suppression du projet : $e');
    }
  }
}








