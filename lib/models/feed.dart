class Challenge {
  String name;
  String description;
  String rarity;

  Challenge(this.name, this.description, this.rarity);

  static List<Challenge> generateChallenge() {
    var list = [
      Challenge("Technology", "Trends on Tech", "technology"),
      Challenge("Food", "Trends on Food", "food"),
      Challenge("Fashion", "Fashion Trends", "fashion"),
      Challenge("Celebrity Gossip", "Gossips about Celebs.", "gossips"),
      Challenge("Vehicles", "New Cars and tech used", "cars"),
      Challenge("Football", "News about football, whats trending", "football"),
    ];
    list.shuffle();
    return list;
  }
}
