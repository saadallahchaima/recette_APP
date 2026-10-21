import 'package:flutter/material.dart';

const kUserName = 'Léa';
const kBaseServings = 4;

class Cat {
  final String name;
  final IconData icon;
  final String image;
  const Cat(this.name, this.icon, this.image);
}

const kCats = <Cat>[
  Cat('Légumes', Icons.eco_rounded, 'assets/images/legumes.png'),
  Cat('Viandes & poissons', Icons.set_meal_rounded, 'assets/images/poissons.png'),
  Cat('Produits laitiers', Icons.local_drink_rounded, 'assets/images/produit_laitiers.png'),
  Cat('Féculents', Icons.grain_rounded, 'assets/images/feculents.png'),
  Cat('Épicerie', Icons.soup_kitchen_rounded, 'assets/images/epecerie.png'),
];

/// Un ingrédient présent dans le frigo.
class Pantry {
  final String name;
  String qty;
  final String cat;
  DateTime? expiry;
  Pantry(this.name, this.qty, this.cat, {this.expiry});
  String get label => qty.isEmpty ? name : '$name · $qty';

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        'cat': cat,
        'expiry': expiry?.toIso8601String(),
      };

  factory Pantry.fromJson(Map<String, dynamic> json) => Pantry(
        json['name'] as String,
        json['qty'] as String? ?? '',
        json['cat'] as String,
        expiry: json['expiry'] == null
            ? null
            : DateTime.tryParse(json['expiry'] as String),
      );
}

/// Un ingrédient d'une recette.
class Ing {
  final String name; // affiché
  final String key; // sert à retrouver l'ingrédient dans le frigo
  final double qty;
  final String unit;
  final bool scales;
  final String? miss; // texte « Il te manque : … »
  const Ing(this.name, this.key, this.qty, this.unit,
      {this.scales = true, this.miss});
}

class CookStep {
  final String title;
  final String text;
  final int minutes;
  final String cook;
  final String tip;
  CookStep(this.title, this.text, this.minutes, {String? cook, this.tip = ''})
      : cook = cook ?? text;
}

class Recipe {
  final String id, name, sub, level, kicker, badge, intro, third, emoji, tip;
  final int minutes;
  final Set<String> tags;
  final List<Ing> ings;
  final List<CookStep> steps;
  final double budget;
  final Map<String, String> substitutions;
  final Set<String> wasteKeys;
  Recipe({
    required this.id,
    required this.name,
    required this.sub,
    required this.minutes,
    required this.kicker,
    required this.badge,
    required this.intro,
    required this.third,
    required this.emoji,
    required this.tip,
    required this.tags,
    required this.ings,
    required this.steps,
    this.level = 'Facile',
    this.budget = 2.5,
    this.substitutions = const {},
    this.wasteKeys = const {},
  });

  /// Photo à déposer dans assets/images/<id>.png
  String get photo => 'assets/images/$id.png';
}

String fmtQty(Ing i, int servings) {
  final q = i.scales ? i.qty * servings / kBaseServings : i.qty;
  final n = q == q.roundToDouble()
      ? q.round().toString()
      : q.toStringAsFixed(1).replaceAll('.', ',');
  var u = i.unit;
  if (u == 'pincée' && q > 1) u = 'pincées';
  return u.isEmpty ? n : '$n $u';
}

final List<Recipe> kRecipes = [
  Recipe(
    id: 'coquillettes',
    name: 'Coquillettes câlines',
    sub: 'Courgette & fromage',
    minutes: 20,
    kicker: 'La bonne idée du soir',
    badge: 'Un câlin dans une assiette',
    intro:
        'Courgette, crème et fromage fondant.\nLe dîner qui met tout le monde d’accord.',
    third: 'Végétarien',
    emoji: '🍝',
    tip:
        'Pas besoin d’éplucher les courgettes.\nUne petite corvée en moins, hop !',
    tags: {'rapide', 'enfants', 'végétarien'},
    ings: const [
      Ing('Coquillettes', 'coquillette', 300, 'g'),
      Ing('Courgettes', 'courgette', 2, ''),
      Ing('Crème liquide', 'crème', 20, 'cl'),
      Ing('Huile d’olive', 'huile', 1, 'c. à soupe', scales: false),
      Ing('Sel', 'sel', 1, 'pincée', scales: false),
      Ing('Emmental râpé', 'emmental', 80, 'g', miss: '80 g d’emmental'),
    ],
    budget: 2.5,
    substitutions: const {'emmental': 'mozzarella ou levure alimentaire'},
    wasteKeys: {'courgette', 'crème'},
    steps: [
      CookStep(
          'On se prépare',
          'Lave les courgettes et coupe-les en fines demi-rondelles. Fais bouillir une casserole d’eau salée.',
          5,
          tip: 'Pas besoin d’éplucher les courgettes !'),
      CookStep(
          'Les courgettes au chaud',
          'Chauffe l’huile dans une poêle. Ajoute les courgettes et fais-les revenir 8 min à feu moyen en remuant.',
          8,
          cook:
              'Chauffe 1 cuillère d’huile dans une poêle. Ajoute les courgettes et fais-les revenir 8 min à feu moyen.',
          tip: 'Remue de temps en temps. Elles aiment bien danser !'),
      CookStep(
          'Les pâtes font trempette',
          'Pendant ce temps, cuis les coquillettes 8 min dans l’eau bouillante. Garde une louche d’eau, puis égoutte.',
          8,
          tip: 'Garde l’eau de cuisson, c’est le secret du crémeux.'),
      CookStep(
          'Le câlin crémeux',
          'Ajoute la crème, les pâtes et l’emmental aux courgettes. Mélange 2 min à feu doux. Un peu d’eau de cuisson si besoin, et à table !',
          2,
          tip: 'Goûte avant de servir, Mijou a confiance en toi !'),
    ],
  ),
  Recipe(
    id: 'poulet',
    name: 'Poulet tout doux',
    sub: 'Carottes, crème & riz',
    minutes: 30,
    kicker: 'Le réconfort du jour',
    badge: 'Doux comme un dimanche',
    intro:
        'Poulet fondant, carottes tendres et sauce crémeuse.\nUn plat qui fait du bien.',
    third: 'Gourmand',
    emoji: '🍗',
    tip: 'Les carottes deviennent encore plus douces\navec un petit couvercle.',
    tags: {'enfants', 'healthy', 'économique'},
    ings: const [
      Ing('Poulet', 'poulet', 250, 'g'),
      Ing('Carottes', 'carotte', 3, ''),
      Ing('Crème liquide', 'crème', 20, 'cl'),
      Ing('Riz', 'riz', 200, 'g'),
      Ing('Huile d’olive', 'huile', 1, 'c. à soupe', scales: false),
      Ing('Sel', 'sel', 1, 'pincée', scales: false),
    ],
    budget: 3.5,
    substitutions: const {'poulet': 'pois chiches', 'crème': 'yaourt nature'},
    wasteKeys: {'carotte', 'crème'},
    steps: [
      CookStep('On coupe tout',
          'Coupe le poulet en petits morceaux et les carottes en rondelles.', 5,
          tip: 'Des petits morceaux, ça cuit plus vite !'),
      CookStep('Le poulet dore',
          'Fais dorer le poulet 5 min dans l’huile chaude, en remuant.', 5,
          tip: 'Ne le bouscule pas trop, il doit dorer.'),
      CookStep(
          'Carottes et crème',
          'Ajoute les carottes, la crème et un peu de sel. Laisse mijoter 15 min à feu doux.',
          15,
          tip: 'Un petit couvercle et la magie opère.'),
      CookStep(
          'Le riz en renfort',
          'Pendant ce temps, cuis le riz 10 min dans l’eau bouillante, puis égoutte et sers avec le poulet.',
          10,
          tip: 'À table, tout le monde !'),
    ],
  ),
  Recipe(
    id: 'galettes',
    name: 'Galettes soleil',
    sub: 'Carotte & riz doré',
    minutes: 25,
    kicker: 'Un petit rayon de soleil',
    badge: 'Un rayon de soleil',
    intro:
        'Carottes et riz dorés, croustillants dehors, tendres dedans.\nParfait pour les petits et les grands.',
    third: 'Végétarien',
    emoji: '🥕',
    tip: 'Aplatis bien les galettes\npour qu’elles soient croustillantes.',
    tags: {'rapide', 'économique', 'healthy', 'végétarien'},
    ings: const [
      Ing('Carottes', 'carotte', 2, ''),
      Ing('Riz cuit', 'riz', 150, 'g'),
      Ing('Œuf', 'œuf', 1, '', miss: '1 œuf'),
      Ing('Crème liquide', 'crème', 5, 'cl'),
      Ing('Huile d’olive', 'huile', 1, 'c. à soupe', scales: false),
      Ing('Sel', 'sel', 1, 'pincée', scales: false),
    ],
    budget: 2,
    substitutions: const {'œuf': '1 c. à soupe de maïzena'},
    wasteKeys: {'carotte', 'riz'},
    steps: [
      CookStep('On râpe', 'Épluche et râpe les carottes.', 5,
          tip: 'Une râpe à gros trous, c’est parfait.'),
      CookStep(
          'Le mélange doré',
          'Mélange les carottes, le riz cuit, l’œuf, la crème et une pincée de sel.',
          3,
          tip: 'Mélange avec les mains si tu veux, ça marche très bien !'),
      CookStep(
          'À la poêle',
          'Chauffe l’huile, dépose des petits tas de mélange et aplatis-les.',
          3,
          tip: 'Pas trop grosses, elles seront plus croustillantes.'),
      CookStep('Dorées des deux côtés',
          'Laisse dorer 4 min de chaque côté à feu moyen. Sers bien chaud !', 8,
          tip: 'Retourne-les une seule fois, avec patience.'),
    ],
  ),
];

Recipe recipeById(String id) => kRecipes.firstWhere((r) => r.id == id);

class ShopItem {
  final String name, note, cat;
  String qty;
  final String? recipeId;
  bool checked;
  ShopItem(this.name, this.note, this.qty, this.cat,
      {this.recipeId, this.checked = false});

  Map<String, dynamic> toJson() => {
        'name': name,
        'note': note,
        'qty': qty,
        'cat': cat,
        'recipeId': recipeId,
        'checked': checked,
      };

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        json['name'] as String,
        json['note'] as String? ?? '',
        json['qty'] as String? ?? '',
        json['cat'] as String,
        recipeId: json['recipeId'] as String?,
        checked: json['checked'] as bool? ?? false,
      );
}
