import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quiz/utils/app_widget.dart';
import 'package:quiz/utils/codePicker/selection_dialog.dart';
import 'country_code.dart';
import 'country_codes.dart';

export 'country_code.dart';

class CountryCodePicker extends StatefulWidget {
  final ValueChanged<CountryCode>? onChanged;

  // Exposed new method to get the initial information of the country
  final ValueChanged<CountryCode?>? onInit;
  final String? initialSelection;
  final List<String> favorite;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final WidgetBuilder? emptySearchBuilder;
  final Function(CountryCode?)? builder;

  /// Shows the name of the country instead of the dial code
  final bool showOnlyCountryWhenClosed;

  /// Aligns the flag and the text left
  final bool alignLeft;

  /// Shows the flag
  final bool showFlag;

  /// Contains the country codes to load only the specified countries
  final List<String> countryFilter;

  const CountryCodePicker({
    super.key,
    this.onChanged,
    this.onInit,
    this.initialSelection,
    this.favorite = const [],
    this.countryFilter = const [],
    this.textStyle,
    this.padding = const EdgeInsets.all(0.0),
    this.showCountryOnly = false,
    this.searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.emptySearchBuilder,
    this.showOnlyCountryWhenClosed = false,
    this.alignLeft = false,
    this.showFlag = true,
    this.builder,
  });

  @override
  State<StatefulWidget> createState() {
    List<Map> jsonList = codes;

    List<CountryCode> elements = jsonList
        .map((s) => CountryCode(
      name: s['name'],
      code: s['code'],
      dialCode: s['dial_code'],
      flagUri: '', // Add icon URLs here
    ))
        .toList();

    if (countryFilter.isNotEmpty) {
      elements = elements.where((c) => countryFilter.contains(c.code)).toList();
    }

    return _CountryCodePickerState(elements);
  }
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  CountryCode? selectedItem;
  List<CountryCode> elements = [];
  List<CountryCode> favoriteElements = [];

  _CountryCodePickerState(this.elements);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showSelectionDialog,
      child: widget.builder != null
          ? widget.builder!(selectedItem)
          : _buildDefaultPicker(),
    );
  }

  Widget _buildDefaultPicker() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: widget.padding,
      ),
      onPressed: _showSelectionDialog,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.showFlag) _buildFlagWidget(),
          Flexible(
            fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
            child: text(
              selectedItem?.toCountryCodeString() ?? '',
              textColor: textPrimaryColor,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagWidget() {
    return Flexible(
      flex: widget.alignLeft ? 0 : 1,
      fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
      child: Padding(
        padding: widget.alignLeft
            ? const EdgeInsets.symmetric(horizontal: 8.0)
            : const EdgeInsets.only(right: 8.0),
        child: CachedNetworkImage(
          imageUrl: selectedItem?.flagUri ?? '',
          width: 25.0,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelection != widget.initialSelection) {
      selectedItem = widget.initialSelection != null
          ? elements.firstWhere(
            (e) => (e.code!.toUpperCase() == widget.initialSelection!.toUpperCase()) ||
            (e.dialCode == widget.initialSelection.toString()),
        orElse: () => elements[0],
      )
          : elements[0];
    }
  }

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initialSelection != null
        ? elements.firstWhere(
          (e) => (e.code!.toUpperCase() == widget.initialSelection!.toUpperCase()) ||
          (e.dialCode == widget.initialSelection.toString()),
      orElse: () => elements[0],
    )
        : elements[0];

    // Change added: get the initial entered country information
    _onInit(selectedItem);

    favoriteElements = elements.where(
          (e) => widget.favorite.firstWhereOrNull(
            (f) => e.code == f.toUpperCase() || e.dialCode == f.toString(),
      ) !=
          null,
    ).toList();
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => SelectionDialog(
        elements,
        favoriteElements,
        showCountryOnly: widget.showCountryOnly,
        emptySearchBuilder: widget.emptySearchBuilder,
        searchDecoration: widget.searchDecoration,
        searchStyle: widget.searchStyle,
        showFlag: widget.showFlag,
      ),
    ).then((e) {
      if (e != null) {
        setState(() {
          selectedItem = e;
        });
        _publishSelection(e);
      }
    });
  }

  void _publishSelection(CountryCode e) {
    widget.onChanged?.call(e);
  }

  void _onInit(CountryCode? initialData) {
    widget.onInit?.call(initialData);
  }
}
