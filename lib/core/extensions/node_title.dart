import 'package:super_editor/super_editor.dart';

/// Extracts firsts [Nodes] title
extension NodeTitle on Document {
  String? get nodeTitle => (nodes[0] as TextNode).text.text;
}
