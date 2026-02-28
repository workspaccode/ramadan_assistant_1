import 'dart:isolate';

void main() async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:quran/quran.dart'),
  );
  print(uri);
}
