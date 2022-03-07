class PremiumPlan {
  int id;
  int item_id;
  String type;
  double dollar_cost;
  int gem_cost;
  String duration;
  String dollarSavings;
  String gemSavings;
  String createdAt;
  String updatedAt;

  PremiumPlan(
      this.id,
      this.item_id,
      this.type,
      this.dollar_cost,
      this.gem_cost,
      this.duration,
      this.dollarSavings,
      this.gemSavings,
      this.createdAt,
      this.updatedAt);

  PremiumPlan.fromJson(Map<String, dynamic> json) {
    PremiumPlan(
        this.id = json["id"],
        this.item_id = json["item_id"],
        this.type = json["type"],
        this.dollar_cost = json["dollar_cost"],
        this.gem_cost = json["gem_cost"],
        this.duration = json["duration"],
        this.dollarSavings = json["dollarSavings"] ?? "Save 0%",
        this.gemSavings = json["gemSavings"] ?? "Save 0%",
        this.createdAt = json["createdAt"],
        this.updatedAt = json["updatedAt"]);
  }

//  factory PremiumPlan.fromjson(Map<String, dynamic> json){
//    return PremiumPlan(
//      id:json["id"],
//      item_id:json["item_id"],
//      type: json["type"],
//      dollar_cost: json["dollar_cost"],
//      gem_cost: json["gem_cost"],
//      duration: json["duration"],
//
//
//    );
//  }

}
