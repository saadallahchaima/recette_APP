# Mijou 🍲

Application Flutter de recettes : « voilà ce que j'ai, dis-moi quoi cuisiner ».
Le code reprend le design Figma (8 écrans) : accueil, menu, mon frigo, résultats,
détail d'une recette, mode cuisine avec minuteur, favoris, liste de courses.

## Lancer le projet

```bash
cd mijou
flutter create . --platforms=android,ios   # génère les dossiers android/ et ios/
flutter pub get
flutter run
```

## Structure

```
lib/
  main.dart           démarrage + 4 onglets + navbar flottante
  theme.dart          couleurs (Pal), police Nunito, ombres
  data.dart           recettes, état de l'app (frigo, favoris, courses)
  widgets.dart        mascotte dessinée en code, navbar, boutons, étiquettes
  pages_home.dart     accueil + menu (avatar)
  pages_fridge.dart   mon frigo + résultats
  pages_recipe.dart   détail recette + mode cuisine (minuteur)
  pages_lists.dart    favoris + liste de courses
```

## Ce qui fonctionne

- Ajouter / retirer des ingrédients (rangés automatiquement par catégorie)
- Résultats calculés selon ce qu'il y a dans le frigo, avec « il te manque… »
- Ajuster le nombre de personnes (quantités recalculées)
- Ajouter les ingrédients manquants à la liste de courses (pastille sur l'onglet)
- Favoris, cases à cocher, bouton « partager » (copie la liste)
- Mode cuisine étape par étape avec minuteur (démarrer, pause, +1 min, remise à zéro)
