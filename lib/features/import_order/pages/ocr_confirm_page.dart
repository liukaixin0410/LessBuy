import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants.dart';
import '../../../models/ocr_parsed_item.dart';
import '../../../models/purchase_record.dart';
import '../../../models/inventory_item.dart';
import '../../../services/mock_data_service.dart';
import '../../home/providers/data_providers.dart';

class OcrConfirmPage extends ConsumerStatefulWidget {
  final List<OcrParsedItem> items;

  const OcrConfirmPage({super.key, required this.items});

  @override
  ConsumerState<OcrConfirmPage> createState() => _OcrConfirmPageState();
}

class _OcrConfirmPageState extends ConsumerState<OcrConfirmPage> {
  late List<_EditableItem> _editableItems;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _editableItems = widget.items.map((item) => _EditableItem(item: item)).toList();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final records = _editableItems
          .where((item) => item.action == _SaveAction.purchase)
          .map((item) => PurchaseRecord(
                platform: item.item.platform,
                orderTime: item.item.orderTime,
                itemName: item.item.itemName,
                quantity: item.item.quantity,
                amount: item.item.amount,
                category: item.item.category,
                sourceType: 'screenshot',
                rawText: item.item.rawText,
              ))
          .toList();

      final inventoryItems = _editableItems
          .where((item) => item.action == _SaveAction.inventory)
          .map((item) => InventoryItem(
                itemName: item.item.itemName,
                quantity: item.item.quantity,
                category: item.item.category,
                status: 'enough',
                sourceType: 'screenshot',
              ))
          .toList();

      if (records.isNotEmpty) {
        await MockDataService.addPurchaseRecords(records);
      }

      for (final item in inventoryItems) {
        await MockDataService.addInventoryItem(item);
      }

      ref.invalidate(inventoryProvider);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已保存 ${records.length + inventoryItems.length} 条记录！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('确认识别结果')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _editableItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OcrItemCard(
                item: _editableItems[index],
                onChanged: (item) => setState(() => _editableItems[index] = item),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('保存'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableItem {
  final OcrParsedItem item;
  _SaveAction action;

  _EditableItem({required this.item, this.action = _SaveAction.purchase});

  _EditableItem copyWith({OcrParsedItem? item, _SaveAction? action}) {
    return _EditableItem(
      item: item ?? this.item,
      action: action ?? this.action,
    );
  }
}

enum _SaveAction {
  purchase,
  inventory,
  ignore,
}

class _OcrItemCard extends StatefulWidget {
  final _EditableItem item;
  final ValueChanged<_EditableItem> onChanged;

  const _OcrItemCard({required this.item, required this.onChanged});

  @override
  State<_OcrItemCard> createState() => _OcrItemCardState();
}

class _OcrItemCardState extends State<_OcrItemCard> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _amountController;
  String? _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.item.itemName);
    _quantityController = TextEditingController(text: widget.item.item.quantity.toString());
    _amountController = TextEditingController(text: widget.item.item.amount?.toString());
    _category = widget.item.item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(widget.item.copyWith(
      item: OcrParsedItem(
        platform: widget.item.item.platform,
        orderTime: widget.item.item.orderTime,
        itemName: _nameController.text,
        quantity: double.tryParse(_quantityController.text) ?? 1,
        amount: double.tryParse(_amountController.text),
        category: _category,
        rawText: widget.item.item.rawText,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '商品名称'),
                    onChanged: (_) => _notifyChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: '数量'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _notifyChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '金额',
                      prefixText: '¥ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _notifyChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '分类'),
                    initialValue: _category,
                    items: AppConstants.categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _category = value);
                      _notifyChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<_SaveAction>(
              segments: const [
                ButtonSegment(value: _SaveAction.purchase, label: Text('记购买')),
                ButtonSegment(value: _SaveAction.inventory, label: Text('记库存')),
                ButtonSegment(value: _SaveAction.ignore, label: Text('忽略')),
              ],
              selected: {widget.item.action},
              onSelectionChanged: (newSelection) {
                widget.onChanged(widget.item.copyWith(action: newSelection.first));
              },
            ),
          ],
        ),
      ),
    );
  }
}
