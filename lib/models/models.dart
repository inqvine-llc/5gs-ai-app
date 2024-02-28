class ApiResponse {
  final List<Message> messages;
  ApiResponse({required this.messages});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      messages: List<Message>.from(
        json['messages'].map((x) => Message.fromWhapiJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'messages': List<dynamic>.from(messages.map((x) => x.toWhapiJson())),
      };
}

enum MessageProvider { whatsapp, unknown }

class Message {
  final MessageProvider provider;
  final String id;
  final bool fromMe;
  final String type;
  final String chatId;
  final int timestamp;
  final String source;
  final int deviceId;
  final String status;
  final TextContent text;
  final String from;
  final String fromName;
  final Map<String, dynamic> context;

  Message({
    required this.provider,
    required this.id,
    required this.fromMe,
    required this.type,
    required this.chatId,
    required this.timestamp,
    required this.source,
    required this.deviceId,
    required this.status,
    required this.text,
    required this.from,
    required this.fromName,
    this.context = const {},
  });

  factory Message.empty() {
    return Message(
      provider: MessageProvider.unknown,
      id: '',
      fromMe: false,
      type: '',
      chatId: '',
      timestamp: 0,
      source: '',
      deviceId: 0,
      status: '',
      text: TextContent(body: ''),
      from: '',
      fromName: '',
    );
  }

  factory Message.fromWhapiJson(Map<String, dynamic> json) {
    return Message(
      provider: MessageProvider.whatsapp,
      id: json.containsKey('id') ? json['id'] : '',
      fromMe: json.containsKey('from_me') ? json['from_me'] : false,
      type: json.containsKey('type') ? json['type'] : '',
      chatId: json.containsKey('chat_id') ? json['chat_id'] : '',
      timestamp: json.containsKey('timestamp') ? json['timestamp'] : 0,
      source: json.containsKey('source') ? json['source'] : '',
      deviceId: json.containsKey('device_id') ? json['device_id'] : 0,
      status: json.containsKey('status') ? json['status'] : '',
      text: TextContent.fromJson(json.containsKey('text') ? json['text'] : {}),
      from: json.containsKey('from') ? json['from'] : '',
      fromName: json.containsKey('from_name') ? json['from_name'] : '',
      context: json.containsKey('context') ? json['context'] : {},
    );
  }

  Map<String, dynamic> toWhapiJson() => {
        'id': id,
        'from_me': fromMe,
        'type': type,
        'chat_id': chatId,
        'timestamp': timestamp,
        'source': source,
        'device_id': deviceId,
        'status': status,
        'text': text.toJson(),
        'from': from,
        'from_name': fromName,
        'context': context,
      };

  @override
  String toString() {
    return 'Message(provider: $provider, id: $id, fromMe: $fromMe, type: $type, chatId: $chatId, timestamp: $timestamp, source: $source, deviceId: $deviceId, status: $status, text: $text, from: $from, fromName: $fromName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.provider == provider &&
        other.id == id &&
        other.fromMe == fromMe &&
        other.type == type &&
        other.chatId == chatId &&
        other.timestamp == timestamp &&
        other.source == source &&
        other.deviceId == deviceId &&
        other.status == status &&
        other.text == text &&
        other.from == from &&
        other.fromName == fromName &&
        other.context == context;
  }

  @override
  int get hashCode {
    return provider.hashCode ^ id.hashCode ^ fromMe.hashCode ^ type.hashCode ^ chatId.hashCode ^ timestamp.hashCode ^ source.hashCode ^ deviceId.hashCode ^ status.hashCode ^ text.hashCode ^ from.hashCode ^ fromName.hashCode ^ context.hashCode;
  }
}

class MessageQuotationData {
  MessageQuotationData({
    required this.quotedId,
    required this.quotedAuthor,
    required this.quotedContent,
    required this.quotedType,
  });

  final String quotedId;
  final String quotedAuthor;
  final Map<String, dynamic> quotedContent;
  final String quotedType;

  static MessageQuotationData? fromMessageContext(Map<String, dynamic> context) {
    final bool hasQuotedId = context.containsKey('quoted_id');
    final bool hasQuotedAuthor = context.containsKey('quoted_author');

    if (hasQuotedId && hasQuotedAuthor) {
      return MessageQuotationData(
        quotedId: context['quoted_id'],
        quotedAuthor: context['quoted_author'],
        quotedContent: context.containsKey('quoted_content') ? context['quoted_content'] : {},
        quotedType: context.containsKey('quoted_type') ? context['quoted_type'] : '',
      );
    }

    return null;
  }

  factory MessageQuotationData.fromJson(Map<String, dynamic> json) {
    return MessageQuotationData(
      quotedId: json['quoted_id'],
      quotedAuthor: json['quoted_author'],
      quotedContent: json['quoted_content'],
      quotedType: json['quoted_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'quoted_id': quotedId,
        'quoted_author': quotedAuthor,
        'quoted_content': quotedContent,
        'quoted_type': quotedType,
      };
}

class TextContent {
  final String body;

  TextContent({required this.body});

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() => {
        'body': body,
      };
}
