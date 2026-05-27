import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wish_item.dart';

class WishService {
  final SupabaseClient _client;

  WishService(this._client);

  Future<List<WishItem>> getWishItems() async {
    final response = await _client
        .from('wish_items')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WishItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<WishItem>> getWishItemsByStatus(String status) async {
    final response = await _client
        .from('wish_items')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WishItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<WishItem> addWishItem(WishItem item) async {
    final response = await _client
        .from('wish_items')
        .insert(item.toJson())
        .select()
        .single();

    return WishItem.fromJson(response);
  }

  Future<void> updateWishItem(WishItem item) async {
    await _client
        .from('wish_items')
        .update(item.toJson())
        .eq('id', item.id!);
  }

  Future<void> deleteWishItem(String id) async {
    await _client.from('wish_items').delete().eq('id', id);
  }
}
