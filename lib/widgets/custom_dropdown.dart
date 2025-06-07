import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/currency_service.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final String selectedValue;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Color color;
  final bool isCurrency;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.color,
    this.isCurrency = false,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          if (widget.isCurrency) {
            final info = CurrencyService.getCurrencyInfo(item);
            return item.toLowerCase().contains(query.toLowerCase()) ||
                   info['name']!.toLowerCase().contains(query.toLowerCase()) ||
                   info['country']!.toLowerCase().contains(query.toLowerCase());
          }
          return item.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildCurrencyItem(String code, {bool isSelected = false}) {
    final info = CurrencyService.getCurrencyInfo(code);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? widget.color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            info['flag']!,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isSelected ? widget.color : null,
                  ),
                ),
                Text(
                  info['name']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check,
              color: widget.color,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildRegularItem(String item, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? widget.color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isSelected ? widget.color : null,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check,
              color: widget.color,
              size: 20,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _isExpanded = !_isExpanded);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isExpanded ? widget.color : Theme.of(context).dividerColor,
                width: _isExpanded ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                if (widget.isCurrency) ...[
                  Text(
                    CurrencyService.getCurrencyInfo(widget.selectedValue)['flag']!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedValue,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.isCurrency)
                        Text(
                          CurrencyService.getCurrencyInfo(widget.selectedValue)['name']!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? 300 : 0,
          child: _isExpanded
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Theme.of(context).dividerColor),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: Icon(Icons.search, color: widget.color),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: _filterItems,
                        ),
                      ),
                      // Items List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = item == widget.selectedValue;
                            
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onChanged(item);
                                setState(() {
                                  _isExpanded = false;
                                  _searchController.clear();
                                  _filteredItems = widget.items;
                                });
                              },
                              child: widget.isCurrency
                                  ? _buildCurrencyItem(item, isSelected: isSelected)
                                  : _buildRegularItem(item, isSelected: isSelected),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
