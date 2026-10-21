class RecipeDataException implements Exception {
  final String message;
  const RecipeDataException(this.message);

  @override
  String toString() => message;
}
