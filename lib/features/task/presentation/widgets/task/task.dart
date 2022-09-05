import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// This file includes everything needed to add the concept of a task
/// to Super Editor. This includes:
///
///  * [TaskNode], which represents a logical task.
///  * [TaskComponentViewModel], which configures the visual appearance
///    of a task in a document.
///  * [taskStyles], which applies desired styles to tasks in a document.
///  * [TaskComponentBuilder], which creates new [TaskComponentViewModel]s
///    and [TaskComponent]s, for every [TaskNode] in the document.
///  * [TaskComponent], which renders a task in a document.

/// [DocumentNode] that represents a task to complete.
///
/// A task can either be complete, or incomplete.
class TaskNode extends TextNode {
  TaskNode({
    required String id,
    required AttributedText text,
    Map<String, dynamic>? metadata,
    required bool isComplete,
  })  : _isComplete = isComplete,
        super(id: id, text: text, metadata: metadata) {
    // Set a block type so that TaskNode's can be styled by
    // StyleRule's.
    putMetadataValue("blockType", const NamedAttribution("task"));
  }

  /// Whether this task is complete.
  bool get isComplete => _isComplete;
  bool _isComplete;
  set isComplete(bool newValue) {
    if (newValue == _isComplete) {
      return;
    }

    _isComplete = newValue;
    notifyListeners();
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is TaskNode &&
        isComplete == other.isComplete &&
        text == other.text;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TaskNode &&
          runtimeType == other.runtimeType &&
          isComplete == other.isComplete;

  @override
  int get hashCode => super.hashCode ^ isComplete.hashCode;
}

/// Styles all task components to apply top padding
final taskStyles = StyleRule(
  const BlockSelector("task"),
  (document, node) {
    if (node is! TaskNode) {
      return {};
    }

    return {
      "padding": const CascadingPadding.only(top: 24),
    };
  },
);

/// Builds [TaskComponentViewModel]s and [TaskComponent]s for every
/// [TaskNode] in a document.
class TaskComponentBuilder implements ComponentBuilder {
  TaskComponentBuilder(
      {required this.editor, this.onSuggestion, this.suggestions});

  final DocumentEditor editor;
  final void Function(String)? onSuggestion;
  final List<Emoji>? suggestions;

  @override
  TaskComponentViewModel? createViewModel(
      Document document, DocumentNode node) {
    if (node is! TaskNode) {
      return null;
    }

    return TaskComponentViewModel(
      onSuggestion: onSuggestion,
      suggestions: suggestions,
      nodeId: node.id,
      padding: EdgeInsets.zero,
      isComplete: node.isComplete,
      setComplete: (bool isComplete) {
        editor.executeCommand(EditorCommandFunction((document, transaction) {
          // Technically, this line could be called without the editor, but
          // that's only because Super Editor hasn't fully separated document
          // queries from document edits. In the future, all edits will have
          // to go through a dedicated editing interface.

          node.isComplete = isComplete;
          // ignore: invalid_use_of_visible_for_testing_member
          document.notifyListeners();
        }));
      },
      text: node.text,
      textStyleBuilder: noStyleBuilder,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(SingleColumnDocumentComponentContext componentContext,
      SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! TaskComponentViewModel) {
      return null;
    }

    return TaskComponent(
      textKey: componentContext.componentKey,
      viewModel: componentViewModel,
    );
  }
}

// Test Build,

class ParagraphComponentBuilder implements ComponentBuilder {
  ParagraphComponentBuilder(this._editor);

  final DocumentEditor _editor;

  @override
  TaskComponentViewModel? createViewModel(
      Document document, DocumentNode node) {
    if (node is! TaskNode) {
      return null;
    }

    return TaskComponentViewModel(
      suggestions: [const Emoji("Pineapple", "🍏,")],
      onSuggestion: null,
      nodeId: node.id,
      padding: EdgeInsets.zero,
      isComplete: node.isComplete,
      setComplete: (bool isComplete) {
        _editor.executeCommand(EditorCommandFunction((document, transaction) {
          // Technically, this line could be called without the editor, but
          // that's only because Super Editor hasn't fully separated document
          // queries from document edits. In the future, all edits will have
          // to go through a dedicated editing interface.
          node.isComplete = isComplete;
        }));
      },
      text: node.text,
      textStyleBuilder: noStyleBuilder,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(SingleColumnDocumentComponentContext componentContext,
      SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! TaskComponentViewModel) {
      return null;
    }

    return TaskComponent(
      textKey: componentContext.componentKey,
      viewModel: componentViewModel,
    );
  }
}

/// View model that configures the appearance of a [TaskComponent].
///
/// View models move through various style phases, which fill out
/// various properties in the view model. For example, one phase applies
/// all [StyleRule]s, and another phase configures content selection
/// and caret appearance.
class TaskComponentViewModel extends SingleColumnLayoutComponentViewModel
    with TextComponentViewModel {
  TaskComponentViewModel({
    required String nodeId,
    double? maxWidth,
    required EdgeInsetsGeometry padding,
    required this.isComplete,
    required this.setComplete,
    required this.text,
    required this.textStyleBuilder,
    required this.onSuggestion,
    required this.suggestions,
    this.textDirection = TextDirection.ltr,
    this.textAlignment = TextAlign.left,
    this.selection,
    required this.selectionColor,
    this.highlightWhenEmpty = false,
  }) : super(nodeId: nodeId, maxWidth: maxWidth, padding: padding);

  bool isComplete;
  void Function(bool) setComplete;
  AttributedText text;
  void Function(String)? onSuggestion;
  List<Emoji>? suggestions;

  @override
  AttributionStyleBuilder textStyleBuilder;
  @override
  TextDirection textDirection;
  @override
  TextAlign textAlignment;
  @override
  TextSelection? selection;
  @override
  Color selectionColor;
  @override
  bool highlightWhenEmpty;

  @override
  TaskComponentViewModel copy() {
    return TaskComponentViewModel(
      suggestions: suggestions,
      onSuggestion: onSuggestion,
      nodeId: nodeId,
      maxWidth: maxWidth,
      padding: padding,
      isComplete: isComplete,
      setComplete: setComplete,
      text: text,
      textStyleBuilder: textStyleBuilder,
      textDirection: textDirection,
      selection: selection,
      selectionColor: selectionColor,
      highlightWhenEmpty: highlightWhenEmpty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TaskComponentViewModel &&
          runtimeType == other.runtimeType &&
          isComplete == other.isComplete &&
          setComplete == other.setComplete &&
          text == other.text &&
          textStyleBuilder == other.textStyleBuilder &&
          textDirection == other.textDirection &&
          textAlignment == other.textAlignment &&
          selection == other.selection &&
          selectionColor == other.selectionColor &&
          highlightWhenEmpty == other.highlightWhenEmpty;

  @override
  int get hashCode =>
      super.hashCode ^
      isComplete.hashCode ^
      setComplete.hashCode ^
      text.hashCode ^
      textStyleBuilder.hashCode ^
      textDirection.hashCode ^
      textAlignment.hashCode ^
      selection.hashCode ^
      selectionColor.hashCode ^
      highlightWhenEmpty.hashCode;
}

/// A document component that displays a complete-able task.
///
/// This is the widget that appears in the document layout for
/// an individual task. This widget includes a checkbox that the
/// user can tap to toggle the completeness of the task.
///
/// The appearance of a [TaskComponent] is configured by the given
/// [viewModel].
class TaskComponent extends StatelessWidget {
  const TaskComponent({
    Key? key,
    required this.textKey,
    required this.viewModel,
    this.showDebugPaint = false,
  }) : super(key: key);

  final GlobalKey textKey;
  final TaskComponentViewModel viewModel;
  final bool showDebugPaint;

  @override
  Widget build(BuildContext context) {
    final testList = [
      "🍅",
      "🍅",
      "🍅",
      "🍅",
      "🍅",
      "🍅",
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 4),
          child: Checkbox(
            value: viewModel.isComplete,
            onChanged: (newValue) {
              viewModel.setComplete(newValue!);
            },
          ),
        ),
        // Expanded(
        //   child: Stack(
        //     children: [
        //       Container(
        //         margin: const EdgeInsets.only(bottom: 40),
        //         child: TextComponent(
        //           key: textKey,
        //           text: viewModel.text,
        //           textStyleBuilder: (attributions) {
        //             // Show a strikethrough across the entire task if it's complete.
        //             final style = viewModel.textStyleBuilder(attributions);
        //             return viewModel.isComplete
        //                 ? style.copyWith(
        //                     decoration: style.decoration == null
        //                         ? TextDecoration.lineThrough
        //                         : TextDecoration.combine([
        //                             TextDecoration.lineThrough,
        //                             style.decoration!
        //                           ]),
        //                   )
        //                 : style;
        //           },
        //           textSelection: viewModel.selection,
        //           selectionColor: viewModel.selectionColor,
        //           highlightWhenEmpty: viewModel.highlightWhenEmpty,
        //           showDebugPaint: showDebugPaint,
        //         ),
        //       ),
        //       // Show a list of suggestions below the task text.
        //       // Positioned(
        //       //   bottom: 0,
        //       //   left: 0,
        //       //   right: 0,
        //       //   child: Container(
        //       //     height: 40,
        //       //     padding: const EdgeInsets.only(
        //       //         top: 10, bottom: 10, left: 16, right: 16),
        //       //     decoration: const BoxDecoration(
        //       //         borderRadius: BorderRadius.all(Radius.circular(20)),
        //       //         boxShadow: <BoxShadow>[
        //       //           BoxShadow(
        //       //               color: Colors.black54,
        //       //               blurRadius: 15.0,
        //       //               offset: Offset(0.0, 0.75))
        //       //         ],
        //       //         color: kcLightPrimaryColor),
        //       //     child: Row(
        //       //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       //       children: [
        //       //         Expanded(
        //       //           child: ListView.builder(
        //       //             physics: const ClampingScrollPhysics(),
        //       //             scrollDirection: Axis.horizontal,
        //       //             shrinkWrap: true,
        //       //             itemCount: viewModel.suggestions?.length,
        //       //             itemBuilder: (context, index) {
        //       //               return GestureDetector(
        //       //                 onTap: () {
        //       //                   viewModel.onSuggestion!(testList[index]);
        //       //                   print(testList[index]);
        //       //                 },
        //       //                 child: Container(
        //       //                     margin: const EdgeInsets.only(right: 8),
        //       //                     padding:
        //       //                         const EdgeInsets.fromLTRB(5, 2, 5, 2),
        //       //                     width: 20,
        //       //                     child: Text(
        //       //                         viewModel.suggestions?[index].emoji ??
        //       //                             "")),
        //       //               );
        //       //             },
        //       //           ),
        //       //         ),
        //       //       ],
        //       //     ),
        //       //   ),
        //       // )
        //     ],
        //   ),
        // ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: TextComponent(
              key: textKey,
              text: viewModel.text,
              textStyleBuilder: (attributions) {
                // Show a strikethrough across the entire task if it's complete.
                final style = viewModel.textStyleBuilder(attributions);
                return viewModel.isComplete
                    ? style.copyWith(
                        decoration: style.decoration == null
                            ? TextDecoration.lineThrough
                            : TextDecoration.combine([
                                TextDecoration.lineThrough,
                                style.decoration!
                              ]),
                      )
                    : style;
              },
              textSelection: viewModel.selection,
              selectionColor: viewModel.selectionColor,
              highlightWhenEmpty: viewModel.highlightWhenEmpty,
              showDebugPaint: showDebugPaint,
            ),
          ),
        ),
      ],
    );
  }
}
