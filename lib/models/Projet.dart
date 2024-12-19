class Projet {
  String id; // ID Firestore
  String nom;
  DateTime deadline;
  List<Map<String, dynamic>> etapes; // Liste de maps pour inclure l'état de validation

  Projet({required this.id, required this.nom, required this.deadline, required this.etapes});

  // Méthode pour convertir un projet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'deadline': deadline.toIso8601String(),
      'etapes': etapes, // Directement sous forme de liste de maps
    };
  }

  factory Projet.fromFirestore(String id, Map<String, dynamic> data) {
    print("Reconstruction du projet : ID=$id, Data=$data");
    return Projet(
      id: id,
      nom: data['nom'] ?? 'Nom manquant',
      deadline: DateTime.parse(data['deadline'] ?? DateTime.now().toIso8601String()),
      etapes: List<Map<String, dynamic>>.from(data['etapes'] ?? []),
    );
  }
}


