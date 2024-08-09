import 'Scores.dart';

class Subject{
  int id;
  String name;
  List<Score> scores;

  Subject(this.id, this.name, this.scores);

  Map<String, dynamic> toJson() {
    return {'name': name,
            'scores': scores.map((score) => score.toJson()).toList()};
  }
  static Subject fromJson(Map<String, dynamic> json) {
      return Subject(json['id'], json['name'], json['scores']);
  }


  @override
  String toString() {
    return 'name: $name, scores: $scores';
  }
}