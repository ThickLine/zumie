import 'package:super_editor/super_editor.dart';

import 'package:zumie/features/task/presentation/widgets/task/task.dart';

final DOCUMENT = MutableDocument(nodes: [
  ParagraphNode(
    id: DocumentEditor.createNodeId(),
    text: AttributedText(
      text: 'Welcome to Super Editor 💙 🚀',
    ),
    metadata: {
      'blockType': header1Attribution,
    },
  ),
  TaskNode(
    id: DocumentEditor.createNodeId(),
    isComplete: false,
    text: AttributedText(
      text:
          'Create and configure your document, for example, by creating a new MutableDocument.',
    ),
  ),
]);
