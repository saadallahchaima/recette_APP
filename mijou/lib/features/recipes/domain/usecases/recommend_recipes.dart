import '../../data/models/data.dart';
import '../../presentation/controllers/app_state.dart';

class RecommendRecipes {
  List<Recipe> call(Iterable<Recipe> recipes, AppState state,
      {int? maxMinutes, double? maxBudget}) {
    final result = recipes.where((recipe) {
      return (maxMinutes == null || recipe.minutes <= maxMinutes) &&
          (maxBudget == null || recipe.budget <= maxBudget);
    }).toList();
    result.sort((a, b) {
      final available = state.haveCount(b).compareTo(state.haveCount(a));
      if (available != 0) return available;
      return state.missing(a).length.compareTo(state.missing(b).length);
    });
    return result;
  }
}
