import '../../data/models/data.dart';

abstract interface class RecipeRepository {
  Future<List<Recipe>> getRecipes();
}

class LocalRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> getRecipes() async => kRecipes;
}
