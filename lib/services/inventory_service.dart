import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';

class InventoryService {
  final SupabaseClient _client;

  InventoryService(this._client);

  Future<List<InventoryItem>> getInventoryItems() async {
    final response = await _client
        .from('inventory_items')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => InventoryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    await _client.from('inventory_items').insert(item.toJson());
  }

  Future<void> addInventoryItems(List<InventoryItem> items) async {
    await _client.from('inventory_items').insert(
          items.map((i) => i.toJson()).toList(),
        );
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _client
        .from('inventory_items')
        .update(item.toJson())
        .eq('id', item.id!);
  }

  Future<void> deleteInventoryItem(String id) async {
    await _client.from('inventory_items').delete().eq('id', id);
  }
}
