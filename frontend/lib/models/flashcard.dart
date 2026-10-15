class Flashcard {
  final int id;
  final String question;
  final String answer;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
  };
}
