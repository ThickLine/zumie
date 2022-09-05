import 'package:logger/logger.dart';
import 'package:translator/translator.dart';

class TranslatorService {
  final log = Logger();
  final translator = GoogleTranslator();

  Future<Translation?> translate(String? text, {String? to = "en"}) async {
    try {
      if (text == null && text!.length < 3) return null;
      return await translator.translate(text, to: to!);
    } catch (e) {
      log.wtf(e);
    }
    return null;
  }
}
