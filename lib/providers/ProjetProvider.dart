import 'package:flutter/material.dart';
import '../models/Projet.dart';

class ProjetProvider extends ChangeNotifier {
  List<Projet> _projets = [];
  List<bool> etapesValidees = [];

  List<Projet> get projets => _projets;

  void ajouterProjets(List<Projet> nouveauxProjets) {
    _projets.addAll(nouveauxProjets);
    etapesValidees = List.generate(_projets.length, (index) => false);
    notifyListeners();
  }

  void supprimerProjet(int index) {
    _projets.removeAt(index);
    etapesValidees.removeAt(index);
    notifyListeners();
  }

  void validerEtape(int index) {
    etapesValidees[index] = true;
    notifyListeners();
  }

  void validerToutesEtapes() {
    etapesValidees = List.generate(_projets.length, (index) => true);
    notifyListeners();
  }
}



