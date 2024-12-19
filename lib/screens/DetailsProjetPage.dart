import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/Projet.dart';
import '../services/firestore_service.dart';

class DetailsProjetPage extends StatefulWidget {
  final Projet projet;

  DetailsProjetPage({required this.projet});

  @override
  _DetailsProjetPageState createState() => _DetailsProjetPageState();
}

class _DetailsProjetPageState extends State<DetailsProjetPage> {
  List<bool> etapesValidees = [];
  List<double> fillLevels = [];
  List<double> rectangleFillLevels = [];
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    etapesValidees = widget.projet.etapes
        .map((etape) => etape['validee'] as bool) // Initialise l'état des étapes
        .toList();
    fillLevels = List.generate(widget.projet.etapes.length, (_) => 0.0);
    rectangleFillLevels = List.generate(widget.projet.etapes.length - 1, (_) => 0.0);
    _audioPlayer = AudioPlayer(); // Initialise le lecteur audio
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Libère les ressources audio
    super.dispose();
  }

  void _validateEtape(int index) async {
    setState(() {
      widget.projet.etapes[index]['validee'] = true; // Marque l'étape comme validée
      etapesValidees[index] = true; // Met à jour l'état localement
    });

    try {
      // Met à jour Firestore avec le nouvel état des étapes
      await FirestoreService().mettreAJourProjet(widget.projet.id, widget.projet);
    } catch (e) {
      print('Erreur lors de la mise à jour dans Firestore : $e');
    }

    _animateEtape(index); // Joue l'animation
    _playSound(); // Joue un son de validation
  }

  void _animateEtape(int index) {
    setState(() {
      fillLevels[index] = 50.0; // Simule le remplissage de l'étape
      if (index < widget.projet.etapes.length - 1) {
        rectangleFillLevels[index] = 20.0; // Taille fixe pour le rectangle
      }
    });
  }

  void _playSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/validation_sound.mp3'); // Charge l'audio
      await _audioPlayer.play(); // Joue le son
    } catch (e) {
      print("Erreur lors de la lecture audio : $e");
    }
  }

  void _fillNext() {
    int index = etapesValidees.indexOf(false); // Cherche la première étape non validée
    if (index != -1) {
      _validateEtape(index);
    }
  }

  Widget buildEtapeItem(int index) {
    Map<String, dynamic> etape = widget.projet.etapes[index]; // Chaque étape est une map

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: etape['validee'] ? Colors.blue.withOpacity(0.5) : Colors.transparent, // Bleu si validée
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  etape['nom'], // Nom de l'étape
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: etape['validee'] ? Colors.white : Colors.black, // Blanc si validée
                  ),
                ),
              ),
            ),
          ],
        ),
        if (index < widget.projet.etapes.length - 1)
          AnimatedContainer(
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
            width: 20,
            height: rectangleFillLevels[index], // Hauteur animée
            color: Colors.blue,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projet.nom),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Deadline: ${widget.projet.deadline.toLocal()}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              "Étapes :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.projet.etapes.length,
                itemBuilder: (context, index) {
                  return buildEtapeItem(index);
                },
              ),
            ),
            ElevatedButton(
              onPressed: _fillNext,
              child: Text("Valider l'étape suivante"),
            ),
          ],
        ),
      ),
    );
  }
}























