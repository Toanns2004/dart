class Score{
  int id;
  int score;

  Score(this.id, this.score);

  Map<String, dynamic> toJson() {
    return {'id': id, 'score': score};
  }
  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(json['id'], json['score']);
  }


  @override
  String toString() {
    return '0: ,$score';
  }
}