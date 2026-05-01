import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/nexus_card.dart';

class NexusDataTable extends StatefulWidget {
  final List<String> columns;
  final List<Map<String, dynamic>> data;
  final bool searchable;
  final Function(Map<String, dynamic>)? onTap;
  final Widget Function(Map<String, dynamic>)? actionsBuilder;

  const NexusDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.searchable = false,
    this.onTap,
    this.actionsBuilder,
  });

  @override
  State<NexusDataTable> createState() => _NexusDataTableState();
}

class _NexusDataTableState extends State<NexusDataTable> {
  late List<Map<String, dynamic>> _filteredData;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = widget.data;
  }

  @override
  void didUpdateWidget(NexusDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _filterData(_searchController.text);
    }
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = widget.data;
      } else {
        _filteredData = widget.data.where((row) {
          return row.values.any((value) => 
            value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.searchable)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterData,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredData.length,
            itemBuilder: (context, index) {
              final row = _filteredData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: NexusCard(
                  onTap: widget.onTap != null ? () => widget.onTap!(row) : null,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 450;
                      
                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDataField(context, widget.columns[0], row[widget.columns[0]]),
                                ),
                                if (widget.actionsBuilder != null)
                                  widget.actionsBuilder!(row),
                              ],
                            ),
                            if (widget.columns.length > 1) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 24,
                                runSpacing: 12,
                                children: widget.columns.skip(1).map((col) {
                                  return SizedBox(
                                    width: (constraints.maxWidth - 48) / 2,
                                    child: _buildDataField(context, col, row[col]),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          ...widget.columns.map((col) {
                            return Expanded(
                              child: _buildDataField(context, col, row[col]),
                            );
                          }).toList(),
                          if (widget.actionsBuilder != null)
                            widget.actionsBuilder!(row),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataField(BuildContext context, String col, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          col.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
