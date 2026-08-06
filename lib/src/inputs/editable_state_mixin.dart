import 'package:flutter/widgets.dart';

/// Shared controller / focus-node ownership lifecycle for editable inputs.
///
/// Both [StarryTextField] and [StarrySearchInput] owned an identical
/// controller/focusNode lifecycle: create-if-absent, dispose-only-if-owned,
/// swap on `didUpdateWidget`, and track a `_focused` flag off a focus listener.
/// This mixin is the single source of truth for that lifecycle. It is an
/// implementation detail of `lib/src/inputs/` and is intentionally NOT exported
/// from the public barrel.
///
/// Hosts supply their widget-configured controller/focusNode via
/// [configuredController] / [configuredFocusNode], drive the swap by calling
/// [syncEditableConfig] from `didUpdateWidget`, and consume [controller],
/// [focusNode] and [isFocused] in `build`. Subclasses that need to observe text
/// changes (e.g. debounce) override [attachControllerListeners] /
/// [detachControllerListeners]; the mixin keeps them balanced across swaps and
/// disposal.
mixin StarryEditableStateMixin<T extends StatefulWidget> on State<T> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _focused = false;

  TextEditingController? _lastConfiguredController;
  FocusNode? _lastConfiguredFocusNode;

  /// The live controller (host-provided or internally owned).
  TextEditingController get controller => _controller;

  /// The live focus node (host-provided or internally owned).
  FocusNode get focusNode => _focusNode;

  /// Whether [focusNode] currently holds focus (kept in sync via [setState]).
  bool get isFocused => _focused;

  /// The externally-provided controller for the current widget, or null when
  /// the host wants the mixin to own one.
  TextEditingController? get configuredController;

  /// The externally-provided focus node for the current widget, or null when
  /// the host wants the mixin to own one.
  FocusNode? get configuredFocusNode;

  /// Attach any host listeners (e.g. a debounce) to a freshly-bound
  /// [controller]. Balanced by [detachControllerListeners]. Default: no-op, so
  /// hosts that read text via `ValueListenableBuilder` pay nothing.
  void attachControllerListeners(TextEditingController controller) {}

  /// Detach whatever [attachControllerListeners] added, before a controller is
  /// swapped out or disposed. Default: no-op.
  void detachControllerListeners(TextEditingController controller) {}

  @override
  void initState() {
    super.initState();
    _lastConfiguredController = configuredController;
    _ownsController = configuredController == null;
    _controller = configuredController ?? TextEditingController();
    attachControllerListeners(_controller);
    _lastConfiguredFocusNode = configuredFocusNode;
    _ownsFocusNode = configuredFocusNode == null;
    _focusNode = configuredFocusNode ?? FocusNode();
    _focused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChange);
  }

  /// Reconcile the live controller/focusNode with the host's current
  /// configuration. Call from the host's `didUpdateWidget` after `super`.
  void syncEditableConfig() {
    if (configuredController != _lastConfiguredController) {
      detachControllerListeners(_controller);
      if (_ownsController) _controller.dispose();
      _ownsController = configuredController == null;
      _controller = configuredController ?? TextEditingController();
      _lastConfiguredController = configuredController;
      attachControllerListeners(_controller);
    }
    if (configuredFocusNode != _lastConfiguredFocusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = configuredFocusNode == null;
      _focusNode = configuredFocusNode ?? FocusNode();
      _focused = _focusNode.hasFocus;
      _lastConfiguredFocusNode = configuredFocusNode;
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    detachControllerListeners(_controller);
    if (_ownsController) _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted || _focusNode.hasFocus == _focused) return;
    setState(() => _focused = _focusNode.hasFocus);
  }
}
