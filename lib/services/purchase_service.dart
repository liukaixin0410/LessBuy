import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchase_record.dart';

class PurchaseService {
  final SupabaseClient _client;

  PurchaseService(this._client);

  Future<List<PurchaseRecord>> getPurchaseRecords() async {
    final response = await _client
        .from('purchase_records')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PurchaseRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addPurchaseRecord(PurchaseRecord record) async {
    await _client.from('purchase_records').insert(record.toJson());
  }

  Future<void> addPurchaseRecords(List<PurchaseRecord> records) async {
    await _client.from('purchase_records').insert(
          records.map((r) => r.toJson()).toList(),
        );
  }
}
