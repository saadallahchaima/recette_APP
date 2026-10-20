import 'package:flutter/foundation.dart';

import '../../data/models/data.dart';

class AppState extends ChangeNotifier {
  int tab = 0;

  void setTab(int value) {
    if (tab == value) return;
    tab = value;
    notifyListeners();
  }

  final List<Pantry> pantry = [
    Pantry('Courgettes', '2', 'Légumes'),
    Pantry('Carottes', '3', 'Légumes'),
    Pantry('Poulet', '250 g', 'Viandes & poissons'),
    Pantry('Crème', '20 cl', 'Produits laitiers'),
    Pantry('Coquillettes', '300 g', 'Féculents'),
    Pantry('Riz', '500 g', 'Féculents'),
    Pantry('Huile d’olive', '', 'Épicerie'),
    Pantry('Sel', '', 'Épicerie'),
  ];

  final Set<String> favorites = {'coquillettes', 'poulet'};

  final List<ShopItem> shopping = [
    ShopItem('Emmental râpé', 'Pour tes coquillettes câlines', '80 g',
        'Produits laitiers',
        recipeId: 'coquillettes'),
  ];

  int get toBuy => shopping.where((s) => !s.checked).length;

  bool has(String key) {
    final k = key.toLowerCase();
    return pantry.any((p) => p.name.toLowerCase().startsWith(k));
  }

  List<Ing> missing(Recipe r) => r.ings.where((i) => !has(i.key)).toList();
  int haveCount(Recipe r) => r.ings.length - missing(r).length;

  void toggleFav(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    notifyListeners();
  }

  String guessCat(String name) {
    final n = name.toLowerCase();
    bool any(List<String> k) => k.any(n.contains);
    if (any([
      'courgette',
      'carotte',
      'tomate',
      'oignon',
      'salade',
      'poireau',
      'haricot',
      'poivron',
      'champignon',
      'épinard',
      'ail',
      'concombre'
    ])) {
      return 'Légumes';
    }
    if (any([
      'poulet',
      'bœuf',
      'boeuf',
      'poisson',
      'saumon',
      'jambon',
      'thon',
      'dinde',
      'steak',
      'porc',
      'merguez'
    ])) {
      return 'Viandes & poissons';
    }
    if (any([
      'lait',
      'crème',
      'creme',
      'fromage',
      'emmental',
      'beurre',
      'yaourt',
      'œuf',
      'oeuf',
      'mozzarella',
      'parmesan'
    ])) {
      return 'Produits laitiers';
    }
    if (any([
      'pâte',
      'pate',
      'riz',
      'coquillette',
      'pomme de terre',
      'pain',
      'semoule',
      'quinoa',
      'spaghetti',
      'lentille'
    ])) {
      return 'Féculents';
    }
    return 'Épicerie';
  }

  void addPantry(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final cap = clean[0].toUpperCase() + clean.substring(1);
    if (pantry.any((p) => p.name.toLowerCase() == cap.toLowerCase())) return;
    pantry.add(Pantry(cap, '', guessCat(cap)));
    notifyListeners();
  }

  void removePantry(Pantry p) {
    pantry.remove(p);
    notifyListeners();
  }

  void addMissing(Recipe r, int servings) {
    for (final i in missing(r)) {
      if (shopping.any((s) => s.name == i.name)) continue;
      shopping.add(ShopItem(i.name, 'Pour tes ${r.name.toLowerCase()}',
          fmtQty(i, servings), guessCat(i.name),
          recipeId: r.id));
    }
    notifyListeners();
  }

  void addCustom(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final cap = clean[0].toUpperCase() + clean.substring(1);
    shopping.add(ShopItem(cap, 'Pour la maison', '', guessCat(cap)));
    notifyListeners();
  }

  void toggleShop(ShopItem s) {
    s.checked = !s.checked;
    notifyListeners();
  }
}
