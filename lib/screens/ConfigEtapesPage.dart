import 'package:flutter/material.dart';

class ConfigEtapesPage extends StatefulWidget {
  final Map<String, dynamic>? etape; // Une étape est un Map avec 'nom', 'validee', 'deadline', et 'details'

  ConfigEtapesPage({this.etape});

  @override
  _ConfigEtapesPageState createState() => _ConfigEtapesPageState();
}

class _ConfigEtapesPageState extends State<ConfigEtapesPage> {
  late TextEditingController _nomEtapeController;
  late DateTime _deadline;
  late TextEditingController _detailsEtapeController;
  late bool _validee;

  @override
  void initState() {
    super.initState();

    // Initialisez les champs avec les données de l'étape si disponibles
    _nomEtapeController = TextEditingController(text: widget.etape?['nom'] ?? '');
    _deadline = widget.etape != null && widget.etape?['deadline'] != null
        ? DateTime.parse(widget.etape!['deadline'])
        : DateTime.now();
    _detailsEtapeController =
        TextEditingController(text: widget.etape?['details'] ?? '');
    _validee = widget.etape?['validee'] ?? false;
  }

  @override
  void dispose() {
    _nomEtapeController.dispose();
    _detailsEtapeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuration de l'Étape"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomEtapeController,
              decoration: InputDecoration(labelText: "Nom de l'Étape"),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text("Date de fin : "),
                Text("${_deadline.toLocal()}".split(' ')[0]),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _deadline = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _detailsEtapeController,
              decoration: InputDecoration(labelText: "Détails de l'Étape"),
              maxLines: 3, // Permet plusieurs lignes pour les détails
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Checkbox(
                  value: _validee,
                  onChanged: (value) {
                    setState(() {
                      _validee = value ?? false;
                    });
                  },
                ),
                Text("Étape validée"),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'nom': _nomEtapeController.text,
                    'validee': _validee,
                    'deadline': _deadline.toIso8601String(),
                    'details': _detailsEtapeController.text,
                  }, // Retourne une map avec les données complètes de l'étape
                );
              },
              child: Text("Enregistrer l'Étape"),
            ),
          ],
        ),
      ),
    );
  }
}




