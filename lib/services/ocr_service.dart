import '../models/ocr_parsed_item.dart';

class OcrService {
  Future<List<OcrParsedItem>> parseImage(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      OcrParsedItem(
        platform: '淘宝',
        orderTime: DateTime.now(),
        itemName: '牛奶 250ml*12盒',
        quantity: 2,
        amount: 69.9,
        category: '食品',
        rawText: 'Mock OCR Text',
      ),
      OcrParsedItem(
        platform: '淘宝',
        orderTime: DateTime.now(),
        itemName: '洗衣液 2L装',
        quantity: 1,
        amount: 39.9,
        category: '日用品',
        rawText: 'Mock OCR Text 2',
      ),
    ];
  }
}
