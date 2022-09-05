import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:super_editor/super_editor.dart';
import 'package:translator/translator.dart';
import 'package:zumie/core/services/app/translator_service.dart';
import 'package:zumie/core/services/service_locator.dart';
import 'package:zumie/features/task/presentation/widgets/_toolbar.dart';
import 'package:zumie/features/task/presentation/widgets/task/task.dart';

class Input extends StatefulWidget {
  final Document initialDocument;
  final void Function()? onOption;
  final void Function(Document)? onChange;
  const Input(
      {Key? key, required this.initialDocument, this.onOption, this.onChange})
      : super(key: key);

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final GlobalKey _docLayoutKey = GlobalKey();

  final _translatorService = locator<TranslatorService>();

  late Document _doc;
  late DocumentEditor _docEditor;
  late DocumentComposer _composer;
  late CommonEditorOperations _docOps;
  late FocusNode _editorFocusNode;
  late ScrollController _scrollController;

  final _darkBackground = const Color(0xFF222222);
  final _lightBackground = Colors.white;
  final bool _isLight = true;
  final List<Emoji> _suggestionList = [const Emoji("Non-Tomato", "🍅")];

  OverlayEntry? _textFormatBarOverlayEntry;
  final _textSelectionAnchor = ValueNotifier<Offset?>(null);

  OverlayEntry? _imageFormatBarOverlayEntry;
  final _imageSelectionAnchor = ValueNotifier<Offset?>(null);

  Future<String> _getTranslation(String data) async {
    Translation? translation = await _translatorService.translate(data);
    return translation?.text ?? "";
  }

// Todo: Add a function to get the translation of the selected text
  Future<dynamic> _getNode() async {
    final DocumentNode node = _doc.nodes
        .firstWhere((el) => _composer.selection?.base.nodeId == el.id);

    var textNode = node as TextNode;

    var translation = await _getTranslation(textNode.text.text);

    if (translation.isNotEmpty) {
      _suggestionList.addAll(
          await EmojiPickerUtils().searchEmoji(translation.toLowerCase()));

      print(_suggestionList);
    }
  }

  @override
  void initState() {
    super.initState();
    _doc = widget.initialDocument..addListener(_hideOrShowToolbar);
    _docEditor = DocumentEditor(document: _doc as MutableDocument);
    _composer = DocumentComposer()..addListener(_hideOrShowToolbar);
    _docOps = CommonEditorOperations(
      editor: _docEditor,
      composer: _composer,
      documentLayoutResolver: () =>
          _docLayoutKey.currentState as DocumentLayout,
    );
    _editorFocusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_hideOrShowToolbar);
    _composer.addListener(() {
      setState(() {});
      widget.onChange?.call(_doc);
    });
  }

  @override
  void dispose() {
    if (_textFormatBarOverlayEntry != null) {
      _textFormatBarOverlayEntry!.remove();
    }
    _scrollController.dispose();
    _editorFocusNode.dispose();
    _composer.dispose();
    super.dispose();
  }

  void _hideOrShowToolbar() {
    if (_gestureMode != DocumentGestureMode.mouse) {
      // We only add our own toolbar when using mouse. On mobile, a bar
      // is rendered for us.

      return;
    }

    final selection = _composer.selection;
    if (selection == null) {
      // Nothing is selected. We don't want to show a toolbar
      // in this case.
      _hideEditorToolbar();

      return;
    }
    if (selection.base.nodeId != selection.extent.nodeId) {
      // More than one node is selected. We don't want to show
      // a toolbar in this case.
      _hideEditorToolbar();
      _hideImageToolbar();

      return;
    }
    if (selection.isCollapsed) {
      // We only want to show the toolbar when a span of text
      // is selected. Therefore, we ignore collapsed selections.
      _hideEditorToolbar();
      _hideImageToolbar();

      return;
    }

    final selectedNode = _doc.getNodeById(selection.extent.nodeId);

    if (selectedNode is ImageNode) {
      // Show the editor's toolbar for image sizing.
      _showImageToolbar();
      _hideEditorToolbar();
      return;
    } else {
      // The currently selected content is not an image. We don't
      // want to show the image toolbar.
      _hideImageToolbar();
    }

    if (selectedNode is TextNode) {
      // Show the editor's toolbar for text styling.
      _showEditorToolbar();
      _hideImageToolbar();
      return;
    } else {
      // The currently selected content is not a paragraph. We don't
      // want to show a toolbar in this case.
      _hideEditorToolbar();
    }
  }

  void _showEditorToolbar() {
    if (_textFormatBarOverlayEntry == null) {
      // Create an overlay entry to build the editor toolbar.
      // TODO: add an overlay to the Editor widget to avoid using the
      //       application overlay
      _textFormatBarOverlayEntry ??= OverlayEntry(builder: (context) {
        return EditorToolbar(
          anchor: _textSelectionAnchor,
          editorFocusNode: _editorFocusNode,
          editor: _docEditor,
          composer: _composer,
          closeToolbar: _hideEditorToolbar,
        );
      });

      // Display the toolbar in the application overlay.
      final overlay = Overlay.of(context)!;
      overlay.insert(_textFormatBarOverlayEntry!);
    }

    // Schedule a callback after this frame to locate the selection
    // bounds on the screen and display the toolbar near the selected
    // text.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_textFormatBarOverlayEntry == null) {
        return;
      }

      final docBoundingBox = (_docLayoutKey.currentState as DocumentLayout)
          .getRectForSelection(
              _composer.selection!.base, _composer.selection!.extent)!;
      final docBox =
          _docLayoutKey.currentContext!.findRenderObject() as RenderBox;
      final overlayBoundingBox = Rect.fromPoints(
        docBox.localToGlobal(docBoundingBox.topLeft),
        docBox.localToGlobal(docBoundingBox.bottomRight),
      );

      _textSelectionAnchor.value = overlayBoundingBox.topCenter;
    });
  }

  void _hideEditorToolbar() {
    // Null out the selection anchor so that when it re-appears,
    // the bar doesn't momentarily "flash" at its old anchor position.
    _textSelectionAnchor.value = null;

    if (_textFormatBarOverlayEntry != null) {
      // Remove the toolbar overlay and null-out the entry.
      // We null out the entry because we can't query whether
      // or not the entry exists in the overlay, so in our
      // case, null implies the entry is not in the overlay,
      // and non-null implies the entry is in the overlay.
      _textFormatBarOverlayEntry!.remove();
      _textFormatBarOverlayEntry = null;
    }

    // Ensure that focus returns to the editor.
    //
    // I tried explicitly unfocus()'ing the URL textfield
    // in the toolbar but it didn't return focus to the
    // editor. I'm not sure why.
    _editorFocusNode.requestFocus();
  }

  DocumentGestureMode get _gestureMode {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DocumentGestureMode.android;
      case TargetPlatform.iOS:
        return DocumentGestureMode.iOS;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return DocumentGestureMode.mouse;
    }
  }

  bool get _isMobile => _gestureMode != DocumentGestureMode.mouse;

  DocumentInputSource get _inputSource {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return DocumentInputSource.ime;
      // return DocumentInputSource.keyboard;
    }
  }

  void _cut() => _docOps.cut();
  void _copy() => _docOps.copy();
  void _paste() => _docOps.paste();
  void _selectAll() => _docOps.selectAll();

  void _showImageToolbar() {
    if (_imageFormatBarOverlayEntry == null) {
      // Create an overlay entry to build the image toolbar.
      _imageFormatBarOverlayEntry ??= OverlayEntry(builder: (context) {
        return ImageFormatToolbar(
          anchor: _imageSelectionAnchor,
          composer: _composer,
          setWidth: (nodeId, width) {
            final node = _doc.getNodeById(nodeId)!;
            final currentStyles =
                SingleColumnLayoutComponentStyles.fromMetadata(node);
            SingleColumnLayoutComponentStyles(
              width: width,
              padding: currentStyles.padding,
            ).applyTo(node);
          },
          closeToolbar: _hideImageToolbar,
        );
      });

      // Display the toolbar in the application overlay.
      final overlay = Overlay.of(context)!;
      overlay.insert(_imageFormatBarOverlayEntry!);
    }

    // Schedule a callback after this frame to locate the selection
    // bounds on the screen and display the toolbar near the selected
    // text.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_imageFormatBarOverlayEntry == null) {
        return;
      }

      final docBoundingBox = (_docLayoutKey.currentState as DocumentLayout)
          .getRectForSelection(
              _composer.selection!.base, _composer.selection!.extent)!;
      final docBox =
          _docLayoutKey.currentContext!.findRenderObject() as RenderBox;
      final overlayBoundingBox = Rect.fromPoints(
        docBox.localToGlobal(docBoundingBox.topLeft),
        docBox.localToGlobal(docBoundingBox.bottomRight),
      );

      _imageSelectionAnchor.value = overlayBoundingBox.center;
    });
  }

  void _hideImageToolbar() {
    // Null out the selection anchor so that when the bar re-appears,
    // it doesn't momentarily "flash" at its old anchor position.
    _imageSelectionAnchor.value = null;

    if (_imageFormatBarOverlayEntry != null) {
      // Remove the image toolbar overlay and null-out the entry.
      // We null out the entry because we can't query whether
      // or not the entry exists in the overlay, so in our
      // case, null implies the entry is not in the overlay,
      // and non-null implies the entry is in the overlay.
      _imageFormatBarOverlayEntry!.remove();
      _imageFormatBarOverlayEntry = null;
    }

    // Ensure that focus returns to the editor.
    _editorFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: _buildEditor(),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _buildLightAndDarkModeToggle(),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _isMobile ? _buildMountedToolbar() : Container())
      ],
    );
  }

  Widget _buildLightAndDarkModeToggle() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
      child: FloatingActionButton(
          backgroundColor: _isLight ? _darkBackground : _lightBackground,
          foregroundColor: _isLight ? _lightBackground : _darkBackground,
          elevation: 5,
          onPressed: () {
            widget.onOption!();
            setState(() {});
          },
          child: const Icon(
            Icons.add,
          )),
    );
  }

  Widget _buildEditor() {
    return ColoredBox(
      color: _isLight ? _lightBackground : _darkBackground,
      child: SuperEditor(
        editor: _docEditor,
        composer: _composer,
        focusNode: _editorFocusNode,
        scrollController: _scrollController,
        documentLayoutKey: _docLayoutKey,
        documentOverlayBuilders: [
          DefaultCaretOverlayBuilder(
            const CaretStyle()
                .copyWith(color: _isLight ? Colors.black : Colors.redAccent),
          ),
        ],
        selectionStyle: _isLight
            ? defaultSelectionStyle
            : SelectionStyles(
                selectionColor: Colors.red.withOpacity(0.3),
              ),
        stylesheet: defaultStylesheet.copyWith(
          addRulesAfter: [
            if (!_isLight) ..._darkModeStyles,
            taskStyles,
          ],
        ),
        componentBuilders: [
          ...defaultComponentBuilders,
          TaskComponentBuilder(
              editor: _docEditor,
              onSuggestion: (s) {},
              suggestions: _suggestionList)
        ],
        gestureMode: _gestureMode,
        inputSource: _inputSource,
        keyboardActions: _inputSource == DocumentInputSource.ime
            ? defaultImeKeyboardActions
            : defaultKeyboardActions,
        androidToolbarBuilder: (_) => AndroidTextEditingFloatingToolbar(
          onCutPressed: _cut,
          onCopyPressed: _copy,
          onPastePressed: _paste,
          onSelectAllPressed: _selectAll,
        ),
        iOSToolbarBuilder: (_) => IOSTextEditingFloatingToolbar(
          onCutPressed: _cut,
          onCopyPressed: _copy,
          onPastePressed: _paste,
        ),
      ),
    );
  }

  Widget _buildMountedToolbar() {
    return MultiListenableBuilder(
      listenables: <Listenable>{
        _doc,
        _composer.selectionNotifier,
      },
      builder: (_) {
        final selection = _composer.selection;

        if (selection == null) {
          return const SizedBox();
        }

        return KeyboardEditingToolbar(
          document: _doc,
          composer: _composer,
          commonOps: _docOps,
        );
      },
    );
  }
}

// Makes text light, for use during dark mode styling.
final _darkModeStyles = [
  StyleRule(
    BlockSelector.all,
    (doc, docNode) {
      return {
        "textStyle": const TextStyle(
          color: Color(0xFFCCCCCC),
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector("header1"),
    (doc, docNode) {
      return {
        "textStyle": const TextStyle(
          color: Color(0xFF888888),
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector("header2"),
    (doc, docNode) {
      return {
        "textStyle": const TextStyle(
          color: Color(0xFF888888),
        ),
      };
    },
  ),
];
