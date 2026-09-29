class ReviewModel {
  final int id;
  final String userName;
  final int rating;
  final String title;
  final String body;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      userName: json['user_name'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
