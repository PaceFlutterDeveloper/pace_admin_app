import 'package:flutter/material.dart';

class SearchableDropdownFormField<T> extends StatelessWidget {
  const SearchableDropdownFormField({
    super.key,
    required this.decoration,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.searchHintText = 'Search...',
    this.emptySearchText = 'No results found',
  });

  final InputDecoration decoration;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final AutovalidateMode? autovalidateMode;
  final String searchHintText;
  final String emptySearchText;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      builder: (field) {
        final theme = Theme.of(context);
        final effectiveValue = value ?? field.value;
        DropdownMenuItem<T>? selectedItem;
        for (final item in items) {
          if (item.value == effectiveValue) {
            selectedItem = item;
            break;
          }
        }
        final displayText = selectedItem != null && selectedItem.child is Text
            ? (selectedItem.child as Text).data
            : null;
        final isEnabled = onChanged != null && items.isNotEmpty;

        Future<void> openSearchSheet() async {
          if (!isEnabled) return;

          FocusScope.of(context).unfocus();

          final selected = await showModalBottomSheet<T>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (sheetContext) {
              return _SearchableDropdownSheet<T>(
                items: items,
                searchHintText: searchHintText,
                emptySearchText: emptySearchText,
              );
            },
          );

          if (selected != null) {
            field.didChange(selected);
            onChanged?.call(selected);
          }
        }

        return InputDecorator(
          decoration: decoration
              .applyDefaults(theme.inputDecorationTheme)
              .copyWith(
                errorText: field.errorText,
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
          child: InkWell(
            onTap: isEnabled ? openSearchSheet : null,
            child: Text(
              displayText ?? decoration.hintText ?? '',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: displayText != null
                    ? theme.colorScheme.onSurface
                    : theme.hintColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchableDropdownSheet<T> extends StatefulWidget {
  const _SearchableDropdownSheet({
    required this.items,
    required this.searchHintText,
    required this.emptySearchText,
  });

  final List<DropdownMenuItem<T>> items;
  final String searchHintText;
  final String emptySearchText;

  @override
  State<_SearchableDropdownSheet<T>> createState() =>
      _SearchableDropdownSheetState<T>();
}

class _SearchableDropdownSheetState<T>
    extends State<_SearchableDropdownSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _labelFor(DropdownMenuItem<T> item) {
    final child = item.child;
    if (child is Text) {
      return child.data ?? '';
    }
    return child.toString();
  }

  List<DropdownMenuItem<T>> get _filteredItems {
    if (_query.trim().isEmpty) return widget.items;
    final query = _query.trim().toLowerCase();
    return widget.items
        .where((item) => _labelFor(item).toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHintText,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(widget.emptySearchText),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ListTile(
                      title: item.child,
                      onTap: () => Navigator.of(context).pop(item.value),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
