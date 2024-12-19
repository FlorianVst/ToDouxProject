import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Projet.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> ajouterProjet(Projet projet) async {
    try {
      await _firestore.collection('projets').add(projet.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout du projet : $e');
      throw e;
    }
  }

  Future<List<Projet>> recupererProjets() async {
    try {
      final querySnapshot = await _firestore.collection('projets').get();

      // Log pour vérifier les données brutes
      querySnapshot.docs.forEach((doc) {
        print("Projet Firestore ID: ${doc.id}, Data: ${doc.data()}");
      });

      return querySnapshot.docs.map((doc) {
        return Projet.fromFirestore(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des projets : $e');
      throw e;
    }
  }

  // Supprimer un projet de Firestore
  Future<void> supprimerProjet(String id) async {
    try {
      await _firestore.collection('projets').doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression du projet : $e');
      throw e;
    }
  }

  Future<void> mettreAJourProjet(String id, Projet projet) async {
    try {
      await _firestore.collection('projets').doc(id).update({
        'nom': projet.nom,
        'deadline': projet.deadline.toIso8601String(),
        'etapes': projet.etapes.map((etape) => {
          'nom': etape['nom'],
          'validee': etape['validee'],
        }).toList(),
      });
      print("Projet mis à jour avec succès.");
    } catch (e) {
      print("Erreur lors de la mise à jour du projet : $e");
    }
  }

}
