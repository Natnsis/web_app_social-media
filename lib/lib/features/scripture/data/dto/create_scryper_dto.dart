/// Request body for `POST /v1/churches/{id}/scryper`.
class CreateScryperDto {
  final String verse;
  final String reference;

  const CreateScryperDto({
    required this.verse,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
        'verse': verse.trim(),
        'reference': reference.trim(),
      };
}
