class ShopItem {
  int id;
  int item_id;
  String name;
  String description;
  double dollar_cost;
  String more_description;
  int gem_cost;
  int gem_value;
  String imagePath;
  String value_note;

  ShopItem(
      this.id,
      this.item_id,
      this.name,
      this.description,
      this.more_description,
      this.dollar_cost,
      this.gem_cost,
      this.gem_value,
      this.imagePath,
      this.value_note);

  ShopItem.fromJson(Map<String, dynamic> json) {
    ShopItem(
      this.id = json["id"],
      this.item_id = json["item_id"],
      this.name = json["name"] ?? "null",
      this.description = json["description"],
      this.more_description = json["more_description"],
      this.dollar_cost = json["dollar_cost"],
      this.gem_cost = json["gem_cost"],
      this.gem_value = json["gem_value"],
      this.imagePath = json["imagePath"],
      this.value_note = json["value_note"],
    );
  }
}
