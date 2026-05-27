import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants.dart';
import '../../../models/wish_item.dart';
import '../../home/providers/data_providers.dart';
import 'advice_page.dart';

class WishInputPage extends ConsumerStatefulWidget {
  const WishInputPage({super.key});

  @override
  ConsumerState<WishInputPage> createState() => _WishInputPageState();
}

class _WishInputPageState extends ConsumerState<WishInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedReason;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final item = WishItem(
        itemName: _nameController.text.trim(),
        itemPrice: _priceController.text.isEmpty
            ? null
            : double.tryParse(_priceController.text),
        category: _selectedCategory,
        reason: _selectedReason,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final wishItem = await ref.read(addWishItemProvider(item).future);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdvicePage(wishItem: wishItem)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记录想买的东西')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '商品名称',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入商品名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '价格（可选）',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '¥ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '分类（可选）',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: AppConstants.categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: _isLoading ? null : (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '购买原因',
                  prefixIcon: Icon(Icons.help_outline),
                  border: OutlineInputBorder(),
                ),
                value: _selectedReason,
                items: AppConstants.reasons.map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason));
                }).toList(),
                onChanged: _isLoading ? null : (value) => setState(() => _selectedReason = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择购买原因';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('获取 AI 建议'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
