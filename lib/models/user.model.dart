class User {
  String name;
  String lastName;
  String imageUrl;
  int id;

  User(this.name, this.imageUrl, {this.lastName = "", this.id = -1});

  String get fullName => "$name $lastName".trim();
}
