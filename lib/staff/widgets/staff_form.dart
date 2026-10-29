import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Labelled text input in the staff look.
class StaffField extends StatefulWidget {
  const StaffField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscure = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.suffixGlyph,
    this.autofocus = false,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? suffixGlyph;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<StaffField> createState() => _StaffFieldState();
}

class _StaffFieldState extends State<StaffField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final radius = BorderRadius.circular(14);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            widget.label,
            style: sora(12, weight: FontWeight.w600, color: p.muted),
          ),
        ),
        TextField(
          controller: widget.controller,
          obscureText: _hidden,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          minLines: 1,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          cursorColor: p.amberText,
          style: sora(14, weight: FontWeight.w500, color: p.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: sora(14, weight: FontWeight.w400, color: p.muted),
            filled: true,
            fillColor: p.surfaceRaised,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: border(p.border),
            enabledBorder: border(p.border),
            disabledBorder: border(p.border),
            focusedBorder: border(p.amber),
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _hidden ? 'Show' : 'Hide',
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: p.muted,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : widget.suffixGlyph == null
                ? null
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: StaffIcon(
                      widget.suffixGlyph!,
                      size: 18,
                      color: p.muted,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Pill used for filters.
class StaffFilterChip extends StatelessWidget {
  const StaffFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Material(
      color: selected ? p.amber : p.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? p.amber : p.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: sora(
              12.5,
              weight: FontWeight.w600,
              color: selected ? p.onAmber : p.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of [StaffFilterChip]s.
class StaffFilterRow extends StatelessWidget {
  const StaffFilterRow({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              StaffFilterChip(
                label: labels[i],
                selected: i == selected,
                onTap: () => onSelect(i),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet in the staff theme. [builder] gets a context under the sheet,
/// and the content lifts above the keyboard.
Future<T?> showStaffSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  final theme = Theme.of(context);
  final p = StaffPalette.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    backgroundColor: p.surface,
    barrierColor: p.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => Theme(
      data: theme,
      child: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: p.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: sora(
                      20,
                      weight: FontWeight.w700,
                      color: p.text,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              Flexible(child: Builder(builder: builder)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Searchable list picker for long option sets (category, location, …).
Future<T?> showStaffSearchPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  T? selected,
  String searchHint = 'Search',
  String emptyMessage = 'Nothing matches',
}) {
  return showStaffSheet<T>(
    context,
    title: title,
    builder: (context) => _StaffSearchPickerBody<T>(
      items: items,
      labelOf: labelOf,
      selected: selected,
      searchHint: searchHint,
      emptyMessage: emptyMessage,
    ),
  );
}

class _StaffSearchPickerBody<T> extends StatefulWidget {
  const _StaffSearchPickerBody({
    required this.items,
    required this.labelOf,
    required this.selected,
    required this.searchHint,
    required this.emptyMessage,
  });

  final List<T> items;
  final String Function(T) labelOf;
  final T? selected;
  final String searchHint;
  final String emptyMessage;

  @override
  State<_StaffSearchPickerBody<T>> createState() =>
      _StaffSearchPickerBodyState<T>();
}

class _StaffSearchPickerBodyState<T> extends State<_StaffSearchPickerBody<T>> {
  final _query = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final q = _filter.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.items
        : widget.items
              .where((item) => widget.labelOf(item).toLowerCase().contains(q))
              .toList();
    final height = MediaQuery.sizeOf(context).height * 0.55;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: p.surfaceRaised,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  StaffIcon(StaffGlyphs.search, size: 19, color: p.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      cursorColor: p.amberText,
                      style: sora(13.5, weight: FontWeight.w500, color: p.text),
                      onChanged: (v) => setState(() => _filter = v),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: widget.searchHint,
                        hintStyle: sora(
                          13.5,
                          weight: FontWeight.w400,
                          color: p.muted,
                        ),
                      ),
                    ),
                  ),
                  if (_filter.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _query.clear();
                        setState(() => _filter = '');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: StaffIcon(
                          StaffGlyphs.close,
                          size: 18,
                          color: p.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      widget.items.isEmpty
                          ? 'No options available'
                          : widget.emptyMessage,
                      style: sora(13, weight: FontWeight.w500, color: p.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final selected = identical(item, widget.selected) ||
                          item == widget.selected;
                      return ListTile(
                        title: Text(
                          widget.labelOf(item),
                          style: sora(
                            14,
                            weight: FontWeight.w600,
                            color: p.text,
                          ),
                        ),
                        trailing: selected
                            ? StaffIcon(
                                StaffGlyphs.check,
                                color: p.amberText,
                                size: 20,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Form field that opens [showStaffSearchPicker] — use for long lists.
class StaffSearchableDropdownFormField<T> extends FormField<T> {
  StaffSearchableDropdownFormField({
    super.key,
    required this.label,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    T? value,
    super.validator,
    this.searchHint = 'Search',
    this.emptyMessage = 'Nothing matches',
    this.enabled = true,
  }) : super(
         initialValue: value,
         enabled: enabled,
         builder: (field) {
           final state = field as _StaffSearchableDropdownFormFieldState<T>;
           return state.buildField();
         },
       );

  final String label;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final String searchHint;
  final String emptyMessage;
  final bool enabled;

  @override
  FormFieldState<T> createState() =>
      _StaffSearchableDropdownFormFieldState<T>();
}

class _StaffSearchableDropdownFormFieldState<T> extends FormFieldState<T> {
  @override
  StaffSearchableDropdownFormField<T> get widget =>
      super.widget as StaffSearchableDropdownFormField<T>;

  @override
  void didUpdateWidget(covariant StaffSearchableDropdownFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  Future<void> _openPicker() async {
    if (!widget.enabled) return;
    final picked = await showStaffSearchPicker<T>(
      context: context,
      title: widget.label,
      items: widget.items,
      labelOf: widget.labelOf,
      selected: value,
      searchHint: widget.searchHint,
      emptyMessage: widget.emptyMessage,
    );
    if (picked == null || !mounted) return;
    didChange(picked);
    widget.onChanged(picked);
  }

  Widget buildField() {
    final p = context.staff;
    final selectedLabel = value == null ? null : widget.labelOf(value as T);
    return InkWell(
      onTap: widget.enabled ? _openPicker : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: selectedLabel == null,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: errorText,
          enabled: widget.enabled,
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: widget.enabled ? p.muted : p.muted.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          selectedLabel ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: widget.enabled ? p.text : p.muted,
          ),
        ),
      ),
    );
  }
}
