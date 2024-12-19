import 'package:flutter/material.dart';
import '../models/Projet.dart';
import '../services/firestore_service.dart';
import 'ConfigEtapesPage.dart';

class EditProjetPage extends StatefulWidget {
  final Projet projet;

  EditProjetPage({required this.projet});

  @override
  _EditProjetPageState createState() => _EditProjetPageState();
}

class _EditProjetPageState extends State<EditProjetPage> {
  late TextEditingController _nomController;
  late DateTime _deadline;
  late List<Map<String, dynamic>> _etapes; // Étapes au format Map<String, dynamic>

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.projet.nom);
    _deadline = widget.projet.deadline;

    // Convertit les étapes existantes en Map<String, dynamic> si elles sont des String
    _etapes = widget.projet.etapes.map((etape) {
      if (etape is String) {
        return {
          'nom': etape,
          'validee': false,
          'deadline': DateTime.now().toIso8601String(), // Valeur par défaut
          'details': '', // Détails vides par défaut
        };
      }
      return Map<String, dynamic>.from(etape);
    }).toList();
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  // Met à jour Firestore après chaque modification
  Future<void> _updateFirestore() async {
    try {
      await FirestoreService().mettreAJourProjet(
        widget.projet.id,
        Projet(
          id: widget.projet.id,
          nom: _nomController.text,
          deadline: _deadline,
          etapes: _etapes,
        ),
      );
    } catch (e) {
      print("Erreur lors de la mise à jour dans Firestore : $e");
    }
  }

  void _editEtape(int index) async {
    final Map<String, dynamic>? etapeModifiee = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigEtapesPage(etape: _etapes[index]),
      ),
    );

    if (etapeModifiee != null) {
      setState(() {
        _etapes[index] = etapeModifiee; // Met à jour l'étape localement
      });
      await _updateFirestore(); // Met à jour Firestore
    }
  }

  void _addEtape() async {
    final Map<String, dynamic>? nouvelleEtape = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfigEtapesPage()),
    );

    if (nouvelleEtape != null) {
      setState(() {
        _etapes.add(nouvelleEtape); // Ajoute une nouvelle étape localement
      });
      await _updateFirestore(); // Met à jour Firestore
    }
  }

  void _supprimerEtape(int index) async {
    setState(() {
      _etapes.removeAt(index); // Supprime l'étape localement
    });
    await _updateFirestore(); // Met à jour Firestore
  }

  void _saveProject() async {
    // Mettez à jour le projet et sauvegardez dans Firestore
    widget.projet.nom = _nomController.text;
    widget.projet.deadline = _deadline;
    widget.projet.etapes = _etapes;

    await _updateFirestore(); // Sauvegarde dans Firestore
    Navigator.pop(context, widget.projet); // Retourne le projet modifié
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier le Projet"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProject,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: "Nom du Projet"),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text("Date de Fin: "),
                Text("${_deadline.toLocal()}".split(' ')[0]),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (picked != null && picked != _deadline) {
                      setState(() {
                        _deadline = picked;
                      });
                      await _updateFirestore(); // Met à jour Firestore
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addEtape,
              child: Text("Ajouter une Étape"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _etapes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_etapes[index]['nom']), // Affiche le nom de l'étape
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editEtape(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _supprimerEtape(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




