import 'package:flutter/material.dart';
import '../models/Projet.dart';
import '../services/firestore_service.dart';
import 'ConfigEtapesPage.dart';

class ConfigProjetPage extends StatefulWidget {
  final Projet? projet;

  ConfigProjetPage({this.projet});

  @override
  _ConfigProjetPageState createState() => _ConfigProjetPageState();
}

class _ConfigProjetPageState extends State<ConfigProjetPage> {
  late TextEditingController _nomProjetController;
  late DateTime _deadline;
  late List<Map<String, dynamic>> _etapes;

  @override
  void initState() {
    super.initState();
    _nomProjetController = TextEditingController(text: widget.projet?.nom ?? '');
    _deadline = widget.projet?.deadline ?? DateTime.now();
    _etapes = widget.projet?.etapes.map((etape) => Map<String, dynamic>.from(etape)).toList() ?? [];
  }

  @override
  void dispose() {
    _nomProjetController.dispose();
    super.dispose();
  }

  void _ajouterEtape() async {
    Map<String, dynamic>? nouvelleEtape = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfigEtapesPage()),
    );

    if (nouvelleEtape != null) {
      setState(() {
        _etapes.add(nouvelleEtape); // Ajoute une map avec 'nom' et 'validee'
      });
    }
  }

  void _modifierEtape(int index) async {
    Map<String, dynamic>? etapeModifiee = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigEtapesPage(etape: _etapes[index]), // Passe la map
      ),
    );

    if (etapeModifiee != null) {
      setState(() {
        _etapes[index] = etapeModifiee; // Met à jour l'étape avec la map retournée
      });
    }
  }

  void _supprimerEtape(int index) {
    setState(() {
      _etapes.removeAt(index);
    });
  }

  void _sauvegarderProjet() async {
    String nomProjet = _nomProjetController.text;
    DateTime deadline = _deadline;

    if (nomProjet.isNotEmpty && _etapes.isNotEmpty) {
      Projet nouveauProjet = Projet(
        id: widget.projet?.id ?? '', // Si un projet existe déjà, on conserve son ID
        nom: nomProjet,
        deadline: deadline,
        etapes: _etapes, // Étapes sous forme de liste de maps
      );

      try {
        if (widget.projet == null) {
          // Ajouter un nouveau projet
          await FirestoreService().ajouterProjet(nouveauProjet);
        } else {
          // Mettre à jour un projet existant
          await FirestoreService().mettreAJourProjet(widget.projet!.id, nouveauProjet);
        }
        Navigator.pop(context, nouveauProjet);
      } catch (e) {
        print('Erreur lors de la sauvegarde : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuration du Projet"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomProjetController,
              decoration: InputDecoration(labelText: "Nom du Projet"),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text("Date de Fin : "),
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
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Étapes :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _etapes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_etapes[index]['nom']), // Affiche le nom de l'étape
                    onTap: () => _modifierEtape(index),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _supprimerEtape(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _ajouterEtape,
              child: Text("Ajouter une Étape"),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _sauvegarderProjet,
              child: Text("Enregistrer le Projet"),
            ),
          ],
        ),
      ),
    );
  }
}



