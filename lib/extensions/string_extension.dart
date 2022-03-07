extension StringExtension on String {
  String capitalize() {
    if (this != null && this.isNotEmpty) {
      return "${this[0].toUpperCase()}${this.substring(1)}";
    } else {
      return this;
    }
  }

  bool validateStringToDate() {
    try {
      DateTime givenDate = DateTime.parse(this);
      if (DateTime.now().difference(givenDate).inDays > 0) {
        return true;
      }
    } on FormatException catch (e) {
      print("Error: ${e.message}");
      return false;
    }
    return false;
  }
}
