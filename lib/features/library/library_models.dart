enum LibraryKind { companion, hadith }

enum LibraryMediaKind { audio, video, image }

Uri? libraryHttpsUri(String value) {
  final input = value.trim();
  if (input.isEmpty || RegExp(r'\s').hasMatch(input)) return null;
  final uri = Uri.tryParse(input);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  return uri;
}

class LibraryMedia {
  const LibraryMedia({
    required this.id,
    required this.kind,
    required this.url,
    this.label = '',
  });
  final String id;
  final LibraryMediaKind kind;
  final Uri url;
  final String label;
  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'url': url.toString(),
    'label': label,
  };

  static LibraryMedia? fromJson(Object? value) {
    if (value is! Map) return null;
    final id = value['id'];
    final uri = value['url'] is String ? libraryHttpsUri(value['url']) : null;
    final kinds = LibraryMediaKind.values.where(
      (kind) => kind.name == value['kind'],
    );
    if (id is! String || id.isEmpty || uri == null || kinds.isEmpty) {
      return null;
    }
    return LibraryMedia(
      id: id,
      kind: kinds.first,
      url: uri,
      label: value['label'] is String ? value['label'] : '',
    );
  }
}

class LibraryItem {
  LibraryItem({
    required this.id,
    required this.kind,
    required Map<String, String> title,
    required Map<String, String> text,
    required this.source,
    required this.sourceUrl,
    this.favorite = false,
    List<LibraryMedia> media = const [],
  }) : titles = Map.unmodifiable(title),
       texts = Map.unmodifiable(text),
       media = List.unmodifiable(media);
  final String id;
  final LibraryKind kind;
  final Map<String, String> titles;
  final Map<String, String> texts;
  final String source;
  final Uri sourceUrl;
  final bool favorite;
  final List<LibraryMedia> media;
  String title(String locale) =>
      titles[locale] ?? titles['en'] ?? titles.values.first;
  String text(String locale) =>
      texts[locale] ?? texts['en'] ?? texts.values.first;
  LibraryItem withPreferences({
    required bool favorite,
    required List<LibraryMedia> media,
  }) => LibraryItem(
    id: id,
    kind: kind,
    title: titles,
    text: texts,
    source: source,
    sourceUrl: sourceUrl,
    favorite: favorite,
    media: media,
  );
}
