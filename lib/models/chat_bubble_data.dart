import 'chat_image_data.dart';

class ChatBubbleData {
  int id;
  String text;
  ChatImageData chatImageData;
  bool reverse;
  DateTime createdAt;
  int suggestedId;
  String suggested_name;
  String suggested_photo_id;
  String type;
  ChatBubbleData(
      this.id,
      this.text,
      this.chatImageData,
      this.reverse,
      this.createdAt,
      this.suggestedId,
      this.suggested_name,
      this.suggested_photo_id,
      this.type);
}
