class ApiResponse {
  final List<Message> messages;
  ApiResponse({required this.messages});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      messages: List<Message>.from(
        json['messages'].map((x) => Message.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'messages': List<dynamic>.from(messages.map((x) => x.toJson())),
      };
}

class Message {
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

  Message({
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
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
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
    );
  }

  Map<String, dynamic> toJson() => {
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
