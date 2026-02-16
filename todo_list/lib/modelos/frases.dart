class Phrase {
  final int? id;
  final String text;
  final String author;

  Phrase({this.id, required this.text, required this.author});

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'author': author,
      };

  factory Phrase.fromMap(Map<String, dynamic> map) => Phrase(
        id: map['id'],
        text: map['text'],
        author: map['author'] ?? '',
      );
}