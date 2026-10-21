import 'package:flutter_test/flutter_test.dart';
import 'package:mijou/features/recipes/data/models/data.dart';
import 'package:mijou/features/recipes/domain/usecases/recommend_recipes.dart';
import 'package:mijou/features/recipes/presentation/controllers/app_state.dart';

void main() {
  test('recommends recipes with the most ingredients available first', () {
    final state = AppState();
    final result = RecommendRecipes()(kRecipes, state);

    expect(result, isNotEmpty);
    expect(state.haveCount(result.first),
        greaterThanOrEqualTo(state.haveCount(result.last)));
  });

  test('applies preparation time and budget limits', () {
    final state = AppState();
    final result = RecommendRecipes()(kRecipes, state,
        maxMinutes: 20, maxBudget: 3);

    expect(result, everyElement(predicate<Recipe>(
        (recipe) => recipe.minutes <= 20 && recipe.budget <= 3)));
  });
}
