import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/data.dart';

class AppState extends ChangeNotifier {
  bool isLoading = true;
  Object? error;
  Box<dynamic>? _box;

  AppState() {
    _load();
  }

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

  Future<void> _load() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<dynamic>('mijou_state');
      final savedPantry = _box!.get('pantry') as List?;
      final savedFavorites = _box!.get('favorites') as List?;
      final savedShopping = _box!.get('shopping') as List?;
      if (savedPantry != null) {
        pantry
          ..clear()
          ..addAll(savedPantry.map((item) =>
              Pantry.fromJson(Map<String, dynamic>.from(item as Map))));
      }
      if (savedFavorites != null) {
        favorites
          ..clear()
          ..addAll(savedFavorites.cast<String>());
      }
      if (savedShopping != null) {
        shopping
          ..clear()
          ..addAll(savedShopping.map((item) =>
              ShopItem.fromJson(Map<String, dynamic>.from(item as Map))));
      }
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final box = _box;
    if (box == null) return;
    await box.put('pantry', pantry.map((item) => item.toJson()).toList());
    await box.put('favorites', favorites.toList());
    await box.put('shopping', shopping.map((item) => item.toJson()).toList());
  }

  void _changed() {
    notifyListeners();
    _persist().then((_) {}, onError: (Object e, StackTrace _) {
      error = e;
      notifyListeners();
    });
  }

  bool has(String key) {
    final k = key.toLowerCase();
    return pantry.any((p) => p.name.toLowerCase().startsWith(k));
  }

  List<Ing> missing(Recipe r) => r.ings.where((i) => !has(i.key)).toList();
  int haveCount(Recipe r) => r.ings.length - missing(r).length;
  int wasteScore(Recipe r) {
    var score = r.wasteKeys.where((key) => has(key)).length;
    for (final ingredient in r.ings) {
      final expiry = expiryFor(ingredient.key);
      if (expiry != null &&
          expiry.difference(DateTime.now()).inDays <= 3) {
        score += 2;
      }
    }
    return score;
  }

  int availableScore(Recipe r) => haveCount(r);

  DateTime? expiryFor(String key) {
    final normalized = key.toLowerCase();
    for (final item in pantry) {
      if (item.name.toLowerCase().startsWith(normalized)) return item.expiry;
    }
    return null;
  }

  String? substitutionFor(Recipe r, Ing ingredient) =>
      r.substitutions[ingredient.key];

  void toggleFav(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    _changed();
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

  void addPantry(String name, {String qty = '', DateTime? expiry}) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final cap = clean[0].toUpperCase() + clean.substring(1);
    Pantry? existing;
    for (final item in pantry) {
      if (item.name.toLowerCase() == cap.toLowerCase()) {
        existing = item;
        break;
      }
    }
    if (existing != null) {
      existing.qty = _mergeQuantities(existing.qty, qty);
      existing.expiry ??= expiry;
      _changed();
      return;
    }
    pantry.add(Pantry(cap, qty, guessCat(cap), expiry: expiry));
    _changed();
  }

  void updatePantry(Pantry item, {required String qty, DateTime? expiry}) {
    item.qty = qty.trim();
    item.expiry = expiry;
    _changed();
  }

  void removePantry(Pantry p) {
    pantry.remove(p);
    _changed();
  }

  void addMissing(Recipe r, int servings) {
    for (final i in missing(r)) {
      final quantity = fmtQty(i, servings);
      ShopItem? existing;
      for (final item in shopping) {
        if (item.name.toLowerCase() == i.name.toLowerCase()) {
          existing = item;
          break;
        }
      }
      if (existing != null) {
        existing.qty = _mergeQuantities(existing.qty, quantity);
      } else {
        shopping.add(ShopItem(i.name, 'Pour tes ${r.name.toLowerCase()}',
            quantity, guessCat(i.name),
            recipeId: r.id));
      }
    }
    _changed();
  }

  void addCustom(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final cap = clean[0].toUpperCase() + clean.substring(1);
    ShopItem? existing;
    for (final item in shopping) {
      if (item.name.toLowerCase() == cap.toLowerCase()) {
        existing = item;
        break;
      }
    }
    if (existing != null) {
      _changed();
      return;
    }
    shopping.add(ShopItem(cap, 'Pour la maison', '', guessCat(cap)));
    _changed();
  }

  void toggleShop(ShopItem s) {
    s.checked = !s.checked;
    _changed();
  }

  String _mergeQuantities(String first, String second) {
    if (first.isEmpty) return second;
    if (second.isEmpty) return first;
    final a = RegExp(r'^(\d+(?:[,.]\d+)?)\s*(.*)$').firstMatch(first);
    final b = RegExp(r'^(\d+(?:[,.]\d+)?)\s*(.*)$').firstMatch(second);
    if (a != null && b != null &&
        a.group(2)!.trim().toLowerCase() == b.group(2)!.trim().toLowerCase()) {
      final total = double.parse(a.group(1)!.replaceAll(',', '.')) +
          double.parse(b.group(1)!.replaceAll(',', '.'));
      final number =
          total == total.roundToDouble() ? total.toInt().toString() : total.toString();
      return '$number ${a.group(2)!.trim()}'.trim();
    }
    return '$first + $second';
  }
}
