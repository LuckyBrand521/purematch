extension ListExtension on List<String> {
  List<String> trimNextLines() {
    if (this != null && this.isNotEmpty) {
      for (int i = 0; i < this.length; i++) {
        this[i] = this[i].replaceAll("\n", "");
      }
      return this;
    } else {
      return this;
    }
  }
} // preet.sc27@gmail.com
// Preet@123
