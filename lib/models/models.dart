import 'dart:convert';

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

class ChatResponse {
  List<Chat>? chats;
  int? count;
  int? total;
  int? offset;

  ChatResponse({
    this.chats,
    this.count,
    this.total,
    this.offset,
  });

  ChatResponse copyWith({
    List<Chat>? chats,
    int? count,
    int? total,
    int? offset,
  }) =>
      ChatResponse(
        chats: chats ?? this.chats,
        count: count ?? this.count,
        total: total ?? this.total,
        offset: offset ?? this.offset,
      );

  factory ChatResponse.fromRawJson(String str) => ChatResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
        chats: json["chats"] == null ? [] : List<Chat>.from(json["chats"]!.map((x) => Chat.fromJson(x))),
        count: json["count"],
        total: json["total"],
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "chats": chats == null ? [] : List<dynamic>.from(chats!.map((x) => x.toJson())),
        "count": count,
        "total": total,
        "offset": offset,
      };
}

class Chat {
  String? id;
  String? name;
  String? type;
  int? timestamp;
  String? chatPic;
  String? chatPicFull;
  bool? pin;
  bool? mute;
  int? muteUntil;
  bool? archive;
  int? unread;
  bool? unreadMention;
  bool? readOnly;
  bool? notSpam;
  LastMessage? lastMessage;
  List<Label>? labels;

  Chat({
    this.id,
    this.name,
    this.type,
    this.timestamp,
    this.chatPic,
    this.chatPicFull,
    this.pin,
    this.mute,
    this.muteUntil,
    this.archive,
    this.unread,
    this.unreadMention,
    this.readOnly,
    this.notSpam,
    this.lastMessage,
    this.labels,
  });

  Chat copyWith({
    String? id,
    String? name,
    String? type,
    int? timestamp,
    String? chatPic,
    String? chatPicFull,
    bool? pin,
    bool? mute,
    int? muteUntil,
    bool? archive,
    int? unread,
    bool? unreadMention,
    bool? readOnly,
    bool? notSpam,
    LastMessage? lastMessage,
    List<Label>? labels,
  }) =>
      Chat(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        timestamp: timestamp ?? this.timestamp,
        chatPic: chatPic ?? this.chatPic,
        chatPicFull: chatPicFull ?? this.chatPicFull,
        pin: pin ?? this.pin,
        mute: mute ?? this.mute,
        muteUntil: muteUntil ?? this.muteUntil,
        archive: archive ?? this.archive,
        unread: unread ?? this.unread,
        unreadMention: unreadMention ?? this.unreadMention,
        readOnly: readOnly ?? this.readOnly,
        notSpam: notSpam ?? this.notSpam,
        lastMessage: lastMessage ?? this.lastMessage,
        labels: labels ?? this.labels,
      );

  factory Chat.fromRawJson(String str) => Chat.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        timestamp: json["timestamp"],
        chatPic: json["chat_pic"],
        chatPicFull: json["chat_pic_full"],
        pin: json["pin"],
        mute: json["mute"],
        muteUntil: json["mute_until"],
        archive: json["archive"],
        unread: json["unread"],
        unreadMention: json["unread_mention"],
        readOnly: json["read_only"],
        notSpam: json["not_spam"],
        lastMessage: json["last_message"] == null ? null : LastMessage.fromJson(json["last_message"]),
        labels: json["labels"] == null ? [] : List<Label>.from(json["labels"]!.map((x) => Label.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "timestamp": timestamp,
        "chat_pic": chatPic,
        "chat_pic_full": chatPicFull,
        "pin": pin,
        "mute": mute,
        "mute_until": muteUntil,
        "archive": archive,
        "unread": unread,
        "unread_mention": unreadMention,
        "read_only": readOnly,
        "not_spam": notSpam,
        "last_message": lastMessage?.toJson(),
        "labels": labels == null ? [] : List<dynamic>.from(labels!.map((x) => x.toJson())),
      };
}

class Label {
  String? id;
  String? name;
  String? color;
  int? count;
  List<String>? voters;

  Label({
    this.id,
    this.name,
    this.color,
    this.count,
    this.voters,
  });

  Label copyWith({
    String? id,
    String? name,
    String? color,
    int? count,
    List<String>? voters,
  }) =>
      Label(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        count: count ?? this.count,
        voters: voters ?? this.voters,
      );

  factory Label.fromRawJson(String str) => Label.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Label.fromJson(Map<String, dynamic> json) => Label(
        id: json["id"],
        name: json["name"],
        color: json["color"],
        count: json["count"],
        voters: json["voters"] == null ? [] : List<String>.from(json["voters"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "color": color,
        "count": count,
        "voters": voters == null ? [] : List<dynamic>.from(voters!.map((x) => x)),
      };
}

class LastMessage {
  String? id;
  String? type;
  String? subtype;
  String? chatId;
  String? from;
  bool? fromMe;
  String? fromName;
  String? source;
  int? timestamp;
  int? deviceId;
  String? status;
  ChatText? text;
  StickerClass? image;
  StickerClass? video;
  Gif? short;
  Gif? gif;
  Audio? audio;
  Audio? voice;
  StickerClass? document;
  LinkPreview? linkPreview;
  StickerClass? sticker;
  Location? location;
  LiveLocation? liveLocation;
  Contact? contact;
  ContactList? contactList;
  Interactive? interactive;
  Poll? poll;
  Hsm? hsm;
  System? system;
  Order? order;
  ProductItems? productItems;
  LastMessageAction? action;
  Context? context;
  List<Reaction>? reactions;
  List<Label>? labels;

  LastMessage({
    this.id,
    this.type,
    this.subtype,
    this.chatId,
    this.from,
    this.fromMe,
    this.fromName,
    this.source,
    this.timestamp,
    this.deviceId,
    this.status,
    this.text,
    this.image,
    this.video,
    this.short,
    this.gif,
    this.audio,
    this.voice,
    this.document,
    this.linkPreview,
    this.sticker,
    this.location,
    this.liveLocation,
    this.contact,
    this.contactList,
    this.interactive,
    this.poll,
    this.hsm,
    this.system,
    this.order,
    this.productItems,
    this.action,
    this.context,
    this.reactions,
    this.labels,
  });

  LastMessage copyWith({
    String? id,
    String? type,
    String? subtype,
    String? chatId,
    String? from,
    bool? fromMe,
    String? fromName,
    String? source,
    int? timestamp,
    int? deviceId,
    String? status,
    ChatText? text,
    StickerClass? image,
    StickerClass? video,
    Gif? short,
    Gif? gif,
    Audio? audio,
    Audio? voice,
    StickerClass? document,
    LinkPreview? linkPreview,
    StickerClass? sticker,
    Location? location,
    LiveLocation? liveLocation,
    Contact? contact,
    ContactList? contactList,
    Interactive? interactive,
    Poll? poll,
    Hsm? hsm,
    System? system,
    Order? order,
    ProductItems? productItems,
    LastMessageAction? action,
    Context? context,
    List<Reaction>? reactions,
    List<Label>? labels,
  }) =>
      LastMessage(
        id: id ?? this.id,
        type: type ?? this.type,
        subtype: subtype ?? this.subtype,
        chatId: chatId ?? this.chatId,
        from: from ?? this.from,
        fromMe: fromMe ?? this.fromMe,
        fromName: fromName ?? this.fromName,
        source: source ?? this.source,
        timestamp: timestamp ?? this.timestamp,
        deviceId: deviceId ?? this.deviceId,
        status: status ?? this.status,
        text: text ?? this.text,
        image: image ?? this.image,
        video: video ?? this.video,
        short: short ?? this.short,
        gif: gif ?? this.gif,
        audio: audio ?? this.audio,
        voice: voice ?? this.voice,
        document: document ?? this.document,
        linkPreview: linkPreview ?? this.linkPreview,
        sticker: sticker ?? this.sticker,
        location: location ?? this.location,
        liveLocation: liveLocation ?? this.liveLocation,
        contact: contact ?? this.contact,
        contactList: contactList ?? this.contactList,
        interactive: interactive ?? this.interactive,
        poll: poll ?? this.poll,
        hsm: hsm ?? this.hsm,
        system: system ?? this.system,
        order: order ?? this.order,
        productItems: productItems ?? this.productItems,
        action: action ?? this.action,
        context: context ?? this.context,
        reactions: reactions ?? this.reactions,
        labels: labels ?? this.labels,
      );

  factory LastMessage.fromRawJson(String str) => LastMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        id: json["id"],
        type: json["type"],
        subtype: json["subtype"],
        chatId: json["chat_id"],
        from: json["from"],
        fromMe: json["from_me"],
        fromName: json["from_name"],
        source: json["source"],
        timestamp: json["timestamp"],
        deviceId: json["device_id"],
        status: json["status"],
        text: json["text"] == null ? null : ChatText.fromJson(json["text"]),
        image: json["image"] == null ? null : StickerClass.fromJson(json["image"]),
        video: json["video"] == null ? null : StickerClass.fromJson(json["video"]),
        short: json["short"] == null ? null : Gif.fromJson(json["short"]),
        gif: json["gif"] == null ? null : Gif.fromJson(json["gif"]),
        audio: json["audio"] == null ? null : Audio.fromJson(json["audio"]),
        voice: json["voice"] == null ? null : Audio.fromJson(json["voice"]),
        document: json["document"] == null ? null : StickerClass.fromJson(json["document"]),
        linkPreview: json["link_preview"] == null ? null : LinkPreview.fromJson(json["link_preview"]),
        sticker: json["sticker"] == null ? null : StickerClass.fromJson(json["sticker"]),
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        liveLocation: json["live_location"] == null ? null : LiveLocation.fromJson(json["live_location"]),
        contact: json["contact"] == null ? null : Contact.fromJson(json["contact"]),
        contactList: json["contact_list"] == null ? null : ContactList.fromJson(json["contact_list"]),
        interactive: json["interactive"] == null ? null : Interactive.fromJson(json["interactive"]),
        poll: json["poll"] == null ? null : Poll.fromJson(json["poll"]),
        hsm: json["hsm"] == null ? null : Hsm.fromJson(json["hsm"]),
        system: json["system"] == null ? null : System.fromJson(json["system"]),
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        productItems: json["product_items"] == null ? null : ProductItems.fromJson(json["product_items"]),
        action: json["action"] == null ? null : LastMessageAction.fromJson(json["action"]),
        context: json["context"] == null ? null : Context.fromJson(json["context"]),
        reactions: json["reactions"] == null ? [] : List<Reaction>.from(json["reactions"]!.map((x) => Reaction.fromJson(x))),
        labels: json["labels"] == null ? [] : List<Label>.from(json["labels"]!.map((x) => Label.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "subtype": subtype,
        "chat_id": chatId,
        "from": from,
        "from_me": fromMe,
        "from_name": fromName,
        "source": source,
        "timestamp": timestamp,
        "device_id": deviceId,
        "status": status,
        "text": text?.toJson(),
        "image": image?.toJson(),
        "video": video?.toJson(),
        "short": short?.toJson(),
        "gif": gif?.toJson(),
        "audio": audio?.toJson(),
        "voice": voice?.toJson(),
        "document": document?.toJson(),
        "link_preview": linkPreview?.toJson(),
        "sticker": sticker?.toJson(),
        "location": location?.toJson(),
        "live_location": liveLocation?.toJson(),
        "contact": contact?.toJson(),
        "contact_list": contactList?.toJson(),
        "interactive": interactive?.toJson(),
        "poll": poll?.toJson(),
        "hsm": hsm?.toJson(),
        "system": system?.toJson(),
        "order": order?.toJson(),
        "product_items": productItems?.toJson(),
        "action": action?.toJson(),
        "context": context?.toJson(),
        "reactions": reactions == null ? [] : List<dynamic>.from(reactions!.map((x) => x.toJson())),
        "labels": labels == null ? [] : List<dynamic>.from(labels!.map((x) => x.toJson())),
      };
}

class LastMessageAction {
  String? target;
  String? type;
  String? emoji;
  int? ephemeral;
  String? editedType;
  ChatText? editedContent;
  List<String>? votes;

  LastMessageAction({
    this.target,
    this.type,
    this.emoji,
    this.ephemeral,
    this.editedType,
    this.editedContent,
    this.votes,
  });

  LastMessageAction copyWith({
    String? target,
    String? type,
    String? emoji,
    int? ephemeral,
    String? editedType,
    ChatText? editedContent,
    List<String>? votes,
  }) =>
      LastMessageAction(
        target: target ?? this.target,
        type: type ?? this.type,
        emoji: emoji ?? this.emoji,
        ephemeral: ephemeral ?? this.ephemeral,
        editedType: editedType ?? this.editedType,
        editedContent: editedContent ?? this.editedContent,
        votes: votes ?? this.votes,
      );

  factory LastMessageAction.fromRawJson(String str) => LastMessageAction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LastMessageAction.fromJson(Map<String, dynamic> json) => LastMessageAction(
        target: json["target"],
        type: json["type"],
        emoji: json["emoji"],
        ephemeral: json["ephemeral"],
        editedType: json["edited_type"],
        editedContent: json["edited_content"] == null ? null : ChatText.fromJson(json["edited_content"]),
        votes: json["votes"] == null ? [] : List<String>.from(json["votes"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "target": target,
        "type": type,
        "emoji": emoji,
        "ephemeral": ephemeral,
        "edited_type": editedType,
        "edited_content": editedContent?.toJson(),
        "votes": votes == null ? [] : List<dynamic>.from(votes!.map((x) => x)),
      };
}

class ChatText {
  String? body;
  List<TextButton>? buttons;
  List<ChatSection>? sections;
  String? button;
  bool? viewOnce;

  ChatText({
    this.body,
    this.buttons,
    this.sections,
    this.button,
    this.viewOnce,
  });

  ChatText copyWith({
    String? body,
    List<TextButton>? buttons,
    List<ChatSection>? sections,
    String? button,
    bool? viewOnce,
  }) =>
      ChatText(
        body: body ?? this.body,
        buttons: buttons ?? this.buttons,
        sections: sections ?? this.sections,
        button: button ?? this.button,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory ChatText.fromRawJson(String str) => ChatText.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatText.fromJson(Map<String, dynamic> json) => ChatText(
        body: json["body"],
        buttons: json["buttons"] == null ? [] : List<TextButton>.from(json["buttons"]!.map((x) => TextButton.fromJson(x))),
        sections: json["sections"] == null ? [] : List<ChatSection>.from(json["sections"]!.map((x) => ChatSection.fromJson(x))),
        button: json["button"],
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "body": body,
        "buttons": buttons == null ? [] : List<dynamic>.from(buttons!.map((x) => x.toJson())),
        "sections": sections == null ? [] : List<dynamic>.from(sections!.map((x) => x.toJson())),
        "button": button,
        "view_once": viewOnce,
      };
}

class TextButton {
  String? type;
  String? title;
  String? id;

  TextButton({
    this.type,
    this.title,
    this.id,
  });

  TextButton copyWith({
    String? type,
    String? title,
    String? id,
  }) =>
      TextButton(
        type: type ?? this.type,
        title: title ?? this.title,
        id: id ?? this.id,
      );

  factory TextButton.fromRawJson(String str) => TextButton.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TextButton.fromJson(Map<String, dynamic> json) => TextButton(
        type: json["type"],
        title: json["title"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "title": title,
        "id": id,
      };
}

class ChatSection {
  String? title;
  List<ChatRow>? rows;
  List<ActionElement>? productItems;

  ChatSection({
    this.title,
    this.rows,
    this.productItems,
  });

  ChatSection copyWith({
    String? title,
    List<ChatRow>? rows,
    List<ActionElement>? productItems,
  }) =>
      ChatSection(
        title: title ?? this.title,
        rows: rows ?? this.rows,
        productItems: productItems ?? this.productItems,
      );

  factory ChatSection.fromRawJson(String str) => ChatSection.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatSection.fromJson(Map<String, dynamic> json) => ChatSection(
        title: json["title"],
        rows: json["rows"] == null ? [] : List<ChatRow>.from(json["rows"]!.map((x) => ChatRow.fromJson(x))),
        productItems: json["product_items"] == null ? [] : List<ActionElement>.from(json["product_items"]!.map((x) => ActionElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "rows": rows == null ? [] : List<dynamic>.from(rows!.map((x) => x.toJson())),
        "product_items": productItems == null ? [] : List<dynamic>.from(productItems!.map((x) => x.toJson())),
      };
}

class ActionElement {
  String? catalogId;
  String? productId;

  ActionElement({
    this.catalogId,
    this.productId,
  });

  ActionElement copyWith({
    String? catalogId,
    String? productId,
  }) =>
      ActionElement(
        catalogId: catalogId ?? this.catalogId,
        productId: productId ?? this.productId,
      );

  factory ActionElement.fromRawJson(String str) => ActionElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ActionElement.fromJson(Map<String, dynamic> json) => ActionElement(
        catalogId: json["catalog_id"],
        productId: json["product_id"],
      );

  Map<String, dynamic> toJson() => {
        "catalog_id": catalogId,
        "product_id": productId,
      };
}

class ChatRow {
  String? title;
  String? description;
  String? id;

  ChatRow({
    this.title,
    this.description,
    this.id,
  });

  ChatRow copyWith({
    String? title,
    String? description,
    String? id,
  }) =>
      ChatRow(
        title: title ?? this.title,
        description: description ?? this.description,
        id: id ?? this.id,
      );

  factory ChatRow.fromRawJson(String str) => ChatRow.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatRow.fromJson(Map<String, dynamic> json) => ChatRow(
        title: json["title"],
        description: json["description"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "id": id,
      };
}

class Audio {
  String? id;
  String? link;
  String? mimeType;
  int? fileSize;
  String? sha256;
  int? seconds;
  int? recordingTime;
  bool? viewOnce;

  Audio({
    this.id,
    this.link,
    this.mimeType,
    this.fileSize,
    this.sha256,
    this.seconds,
    this.recordingTime,
    this.viewOnce,
  });

  Audio copyWith({
    String? id,
    String? link,
    String? mimeType,
    int? fileSize,
    String? sha256,
    int? seconds,
    int? recordingTime,
    bool? viewOnce,
  }) =>
      Audio(
        id: id ?? this.id,
        link: link ?? this.link,
        mimeType: mimeType ?? this.mimeType,
        fileSize: fileSize ?? this.fileSize,
        sha256: sha256 ?? this.sha256,
        seconds: seconds ?? this.seconds,
        recordingTime: recordingTime ?? this.recordingTime,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory Audio.fromRawJson(String str) => Audio.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
        id: json["id"],
        link: json["link"],
        mimeType: json["mime_type"],
        fileSize: json["file_size"],
        sha256: json["sha256"],
        seconds: json["seconds"],
        recordingTime: json["recording_time"],
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "link": link,
        "mime_type": mimeType,
        "file_size": fileSize,
        "sha256": sha256,
        "seconds": seconds,
        "recording_time": recordingTime,
        "view_once": viewOnce,
      };
}

class Contact {
  String? name;
  String? vcard;
  bool? viewOnce;

  Contact({
    this.name,
    this.vcard,
    this.viewOnce,
  });

  Contact copyWith({
    String? name,
    String? vcard,
    bool? viewOnce,
  }) =>
      Contact(
        name: name ?? this.name,
        vcard: vcard ?? this.vcard,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory Contact.fromRawJson(String str) => Contact.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        name: json["name"],
        vcard: json["vcard"],
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "vcard": vcard,
        "view_once": viewOnce,
      };
}

class ContactList {
  List<ListElement>? list;
  bool? viewOnce;

  ContactList({
    this.list,
    this.viewOnce,
  });

  ContactList copyWith({
    List<ListElement>? list,
    bool? viewOnce,
  }) =>
      ContactList(
        list: list ?? this.list,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory ContactList.fromRawJson(String str) => ContactList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContactList.fromJson(Map<String, dynamic> json) => ContactList(
        list: json["list"] == null ? [] : List<ListElement>.from(json["list"]!.map((x) => ListElement.fromJson(x))),
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
        "view_once": viewOnce,
      };
}

class ListElement {
  String? name;
  String? vcard;

  ListElement({
    this.name,
    this.vcard,
  });

  ListElement copyWith({
    String? name,
    String? vcard,
  }) =>
      ListElement(
        name: name ?? this.name,
        vcard: vcard ?? this.vcard,
      );

  factory ListElement.fromRawJson(String str) => ListElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        name: json["name"],
        vcard: json["vcard"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "vcard": vcard,
      };
}

class Context {
  bool? forwarded;
  int? forwardingScore;
  List<String>? mentions;
  String? quotedId;
  String? quotedType;
  ChatText? quotedContent;
  String? quotedAuthor;
  int? ephemeral;

  Context({
    this.forwarded,
    this.forwardingScore,
    this.mentions,
    this.quotedId,
    this.quotedType,
    this.quotedContent,
    this.quotedAuthor,
    this.ephemeral,
  });

  Context copyWith({
    bool? forwarded,
    int? forwardingScore,
    List<String>? mentions,
    String? quotedId,
    String? quotedType,
    ChatText? quotedContent,
    String? quotedAuthor,
    int? ephemeral,
  }) =>
      Context(
        forwarded: forwarded ?? this.forwarded,
        forwardingScore: forwardingScore ?? this.forwardingScore,
        mentions: mentions ?? this.mentions,
        quotedId: quotedId ?? this.quotedId,
        quotedType: quotedType ?? this.quotedType,
        quotedContent: quotedContent ?? this.quotedContent,
        quotedAuthor: quotedAuthor ?? this.quotedAuthor,
        ephemeral: ephemeral ?? this.ephemeral,
      );

  factory Context.fromRawJson(String str) => Context.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Context.fromJson(Map<String, dynamic> json) => Context(
        forwarded: json["forwarded"],
        forwardingScore: json["forwarding_score"],
        mentions: json["mentions"] == null ? [] : List<String>.from(json["mentions"]!.map((x) => x)),
        quotedId: json["quoted_id"],
        quotedType: json["quoted_type"],
        quotedContent: json["quoted_content"] == null ? null : ChatText.fromJson(json["quoted_content"]),
        quotedAuthor: json["quoted_author"],
        ephemeral: json["ephemeral"],
      );

  Map<String, dynamic> toJson() => {
        "forwarded": forwarded,
        "forwarding_score": forwardingScore,
        "mentions": mentions == null ? [] : List<dynamic>.from(mentions!.map((x) => x)),
        "quoted_id": quotedId,
        "quoted_type": quotedType,
        "quoted_content": quotedContent?.toJson(),
        "quoted_author": quotedAuthor,
        "ephemeral": ephemeral,
      };
}

class StickerClass {
  String? id;
  String? link;
  String? mimeType;
  int? fileSize;
  String? sha256;
  String? caption;
  String? filename;
  int? pageCount;
  String? preview;
  List<TextButton>? buttons;
  bool? viewOnce;
  int? width;
  int? height;
  bool? animated;
  int? seconds;
  bool? autoplay;

  StickerClass({
    this.id,
    this.link,
    this.mimeType,
    this.fileSize,
    this.sha256,
    this.caption,
    this.filename,
    this.pageCount,
    this.preview,
    this.buttons,
    this.viewOnce,
    this.width,
    this.height,
    this.animated,
    this.seconds,
    this.autoplay,
  });

  StickerClass copyWith({
    String? id,
    String? link,
    String? mimeType,
    int? fileSize,
    String? sha256,
    String? caption,
    String? filename,
    int? pageCount,
    String? preview,
    List<TextButton>? buttons,
    bool? viewOnce,
    int? width,
    int? height,
    bool? animated,
    int? seconds,
    bool? autoplay,
  }) =>
      StickerClass(
        id: id ?? this.id,
        link: link ?? this.link,
        mimeType: mimeType ?? this.mimeType,
        fileSize: fileSize ?? this.fileSize,
        sha256: sha256 ?? this.sha256,
        caption: caption ?? this.caption,
        filename: filename ?? this.filename,
        pageCount: pageCount ?? this.pageCount,
        preview: preview ?? this.preview,
        buttons: buttons ?? this.buttons,
        viewOnce: viewOnce ?? this.viewOnce,
        width: width ?? this.width,
        height: height ?? this.height,
        animated: animated ?? this.animated,
        seconds: seconds ?? this.seconds,
        autoplay: autoplay ?? this.autoplay,
      );

  factory StickerClass.fromRawJson(String str) => StickerClass.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StickerClass.fromJson(Map<String, dynamic> json) => StickerClass(
        id: json["id"],
        link: json["link"],
        mimeType: json["mime_type"],
        fileSize: json["file_size"],
        sha256: json["sha256"],
        caption: json["caption"],
        filename: json["filename"],
        pageCount: json["page_count"],
        preview: json["preview"],
        buttons: json["buttons"] == null ? [] : List<TextButton>.from(json["buttons"]!.map((x) => TextButton.fromJson(x))),
        viewOnce: json["view_once"],
        width: json["width"],
        height: json["height"],
        animated: json["animated"],
        seconds: json["seconds"],
        autoplay: json["autoplay"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "link": link,
        "mime_type": mimeType,
        "file_size": fileSize,
        "sha256": sha256,
        "caption": caption,
        "filename": filename,
        "page_count": pageCount,
        "preview": preview,
        "buttons": buttons == null ? [] : List<dynamic>.from(buttons!.map((x) => x.toJson())),
        "view_once": viewOnce,
        "width": width,
        "height": height,
        "animated": animated,
        "seconds": seconds,
        "autoplay": autoplay,
      };
}

class Gif {
  String? id;
  String? link;
  String? mimeType;
  int? fileSize;
  String? sha256;
  String? caption;
  String? preview;
  int? width;
  int? height;
  int? seconds;
  bool? autoplay;
  List<TextButton>? buttons;
  bool? viewOnce;

  Gif({
    this.id,
    this.link,
    this.mimeType,
    this.fileSize,
    this.sha256,
    this.caption,
    this.preview,
    this.width,
    this.height,
    this.seconds,
    this.autoplay,
    this.buttons,
    this.viewOnce,
  });

  Gif copyWith({
    String? id,
    String? link,
    String? mimeType,
    int? fileSize,
    String? sha256,
    String? caption,
    String? preview,
    int? width,
    int? height,
    int? seconds,
    bool? autoplay,
    List<TextButton>? buttons,
    bool? viewOnce,
  }) =>
      Gif(
        id: id ?? this.id,
        link: link ?? this.link,
        mimeType: mimeType ?? this.mimeType,
        fileSize: fileSize ?? this.fileSize,
        sha256: sha256 ?? this.sha256,
        caption: caption ?? this.caption,
        preview: preview ?? this.preview,
        width: width ?? this.width,
        height: height ?? this.height,
        seconds: seconds ?? this.seconds,
        autoplay: autoplay ?? this.autoplay,
        buttons: buttons ?? this.buttons,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory Gif.fromRawJson(String str) => Gif.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Gif.fromJson(Map<String, dynamic> json) => Gif(
        id: json["id"],
        link: json["link"],
        mimeType: json["mime_type"],
        fileSize: json["file_size"],
        sha256: json["sha256"],
        caption: json["caption"],
        preview: json["preview"],
        width: json["width"],
        height: json["height"],
        seconds: json["seconds"],
        autoplay: json["autoplay"],
        buttons: json["buttons"] == null ? [] : List<TextButton>.from(json["buttons"]!.map((x) => TextButton.fromJson(x))),
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "link": link,
        "mime_type": mimeType,
        "file_size": fileSize,
        "sha256": sha256,
        "caption": caption,
        "preview": preview,
        "width": width,
        "height": height,
        "seconds": seconds,
        "autoplay": autoplay,
        "buttons": buttons == null ? [] : List<dynamic>.from(buttons!.map((x) => x.toJson())),
        "view_once": viewOnce,
      };
}

class Hsm {
  HsmHeader? header;
  String? body;
  String? footer;
  List<HsmButton>? buttons;

  Hsm({
    this.header,
    this.body,
    this.footer,
    this.buttons,
  });

  Hsm copyWith({
    HsmHeader? header,
    String? body,
    String? footer,
    List<HsmButton>? buttons,
  }) =>
      Hsm(
        header: header ?? this.header,
        body: body ?? this.body,
        footer: footer ?? this.footer,
        buttons: buttons ?? this.buttons,
      );

  factory Hsm.fromRawJson(String str) => Hsm.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Hsm.fromJson(Map<String, dynamic> json) => Hsm(
        header: json["header"] == null ? null : HsmHeader.fromJson(json["header"]),
        body: json["body"],
        footer: json["footer"],
        buttons: json["buttons"] == null ? [] : List<HsmButton>.from(json["buttons"]!.map((x) => HsmButton.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "header": header?.toJson(),
        "body": body,
        "footer": footer,
        "buttons": buttons == null ? [] : List<dynamic>.from(buttons!.map((x) => x.toJson())),
      };
}

class HsmButton {
  String? id;
  String? type;
  String? text;
  String? url;
  String? phoneNumber;

  HsmButton({
    this.id,
    this.type,
    this.text,
    this.url,
    this.phoneNumber,
  });

  HsmButton copyWith({
    String? id,
    String? type,
    String? text,
    String? url,
    String? phoneNumber,
  }) =>
      HsmButton(
        id: id ?? this.id,
        type: type ?? this.type,
        text: text ?? this.text,
        url: url ?? this.url,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  factory HsmButton.fromRawJson(String str) => HsmButton.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HsmButton.fromJson(Map<String, dynamic> json) => HsmButton(
        id: json["id"],
        type: json["type"],
        text: json["text"],
        url: json["url"],
        phoneNumber: json["phone_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "text": text,
        "url": url,
        "phone_number": phoneNumber,
      };
}

class HsmHeader {
  String? type;
  System? text;
  HeaderDocument? image;
  HeaderDocument? video;
  HeaderDocument? document;
  Location? location;

  HsmHeader({
    this.type,
    this.text,
    this.image,
    this.video,
    this.document,
    this.location,
  });

  HsmHeader copyWith({
    String? type,
    System? text,
    HeaderDocument? image,
    HeaderDocument? video,
    HeaderDocument? document,
    Location? location,
  }) =>
      HsmHeader(
        type: type ?? this.type,
        text: text ?? this.text,
        image: image ?? this.image,
        video: video ?? this.video,
        document: document ?? this.document,
        location: location ?? this.location,
      );

  factory HsmHeader.fromRawJson(String str) => HsmHeader.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HsmHeader.fromJson(Map<String, dynamic> json) => HsmHeader(
        type: json["type"],
        text: json["text"] == null ? null : System.fromJson(json["text"]),
        image: json["image"] == null ? null : HeaderDocument.fromJson(json["image"]),
        video: json["video"] == null ? null : HeaderDocument.fromJson(json["video"]),
        document: json["document"] == null ? null : HeaderDocument.fromJson(json["document"]),
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "text": text?.toJson(),
        "image": image?.toJson(),
        "video": video?.toJson(),
        "document": document?.toJson(),
        "location": location?.toJson(),
      };
}

class HeaderDocument {
  String? id;
  String? link;
  String? mimeType;
  int? fileSize;
  String? sha256;

  HeaderDocument({
    this.id,
    this.link,
    this.mimeType,
    this.fileSize,
    this.sha256,
  });

  HeaderDocument copyWith({
    String? id,
    String? link,
    String? mimeType,
    int? fileSize,
    String? sha256,
  }) =>
      HeaderDocument(
        id: id ?? this.id,
        link: link ?? this.link,
        mimeType: mimeType ?? this.mimeType,
        fileSize: fileSize ?? this.fileSize,
        sha256: sha256 ?? this.sha256,
      );

  factory HeaderDocument.fromRawJson(String str) => HeaderDocument.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HeaderDocument.fromJson(Map<String, dynamic> json) => HeaderDocument(
        id: json["id"],
        link: json["link"],
        mimeType: json["mime_type"],
        fileSize: json["file_size"],
        sha256: json["sha256"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "link": link,
        "mime_type": mimeType,
        "file_size": fileSize,
        "sha256": sha256,
      };
}

class Location {
  int? latitude;
  int? longitude;
  String? address;
  String? name;
  String? url;
  String? preview;
  int? accuracy;
  int? speed;
  int? degrees;
  String? comment;
  bool? viewOnce;

  Location({
    this.latitude,
    this.longitude,
    this.address,
    this.name,
    this.url,
    this.preview,
    this.accuracy,
    this.speed,
    this.degrees,
    this.comment,
    this.viewOnce,
  });

  Location copyWith({
    int? latitude,
    int? longitude,
    String? address,
    String? name,
    String? url,
    String? preview,
    int? accuracy,
    int? speed,
    int? degrees,
    String? comment,
    bool? viewOnce,
  }) =>
      Location(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        name: name ?? this.name,
        url: url ?? this.url,
        preview: preview ?? this.preview,
        accuracy: accuracy ?? this.accuracy,
        speed: speed ?? this.speed,
        degrees: degrees ?? this.degrees,
        comment: comment ?? this.comment,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory Location.fromRawJson(String str) => Location.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: json["latitude"],
        longitude: json["longitude"],
        address: json["address"],
        name: json["name"],
        url: json["url"],
        preview: json["preview"],
        accuracy: json["accuracy"],
        speed: json["speed"],
        degrees: json["degrees"],
        comment: json["comment"],
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "name": name,
        "url": url,
        "preview": preview,
        "accuracy": accuracy,
        "speed": speed,
        "degrees": degrees,
        "comment": comment,
        "view_once": viewOnce,
      };
}

class System {
  String? body;

  System({
    this.body,
  });

  System copyWith({
    String? body,
  }) =>
      System(
        body: body ?? this.body,
      );

  factory System.fromRawJson(String str) => System.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory System.fromJson(Map<String, dynamic> json) => System(
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "body": body,
      };
}

class Interactive {
  String? type;
  InteractiveHeader? header;
  Body? body;
  Body? footer;
  ActionElement? action;
  String? id;
  String? link;
  String? mimeType;
  int? fileSize;
  String? sha256;
  bool? viewOnce;

  Interactive({
    this.type,
    this.header,
    this.body,
    this.footer,
    this.action,
    this.id,
    this.link,
    this.mimeType,
    this.fileSize,
    this.sha256,
    this.viewOnce,
  });

  Interactive copyWith({
    String? type,
    InteractiveHeader? header,
    Body? body,
    Body? footer,
    ActionElement? action,
    String? id,
    String? link,
    String? mimeType,
    int? fileSize,
    String? sha256,
    bool? viewOnce,
  }) =>
      Interactive(
        type: type ?? this.type,
        header: header ?? this.header,
        body: body ?? this.body,
        footer: footer ?? this.footer,
        action: action ?? this.action,
        id: id ?? this.id,
        link: link ?? this.link,
        mimeType: mimeType ?? this.mimeType,
        fileSize: fileSize ?? this.fileSize,
        sha256: sha256 ?? this.sha256,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory Interactive.fromRawJson(String str) => Interactive.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Interactive.fromJson(Map<String, dynamic> json) => Interactive(
        type: json["type"],
        header: json["header"] == null ? null : InteractiveHeader.fromJson(json["header"]),
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
        footer: json["footer"] == null ? null : Body.fromJson(json["footer"]),
        action: json["action"] == null ? null : ActionElement.fromJson(json["action"]),
        id: json["id"],
        link: json["link"],
        mimeType: json["mime_type"],
        fileSize: json["file_size"],
        sha256: json["sha256"],
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "header": header?.toJson(),
        "body": body?.toJson(),
        "footer": footer?.toJson(),
        "action": action?.toJson(),
        "id": id,
        "link": link,
        "mime_type": mimeType,
        "file_size": fileSize,
        "sha256": sha256,
        "view_once": viewOnce,
      };
}

class Body {
  String? text;

  Body({
    this.text,
  });

  Body copyWith({
    String? text,
  }) =>
      Body(
        text: text ?? this.text,
      );

  factory Body.fromRawJson(String str) => Body.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
      };
}

class InteractiveHeader {
  String? type;
  String? text;
  String? image;
  String? video;
  String? document;

  InteractiveHeader({
    this.type,
    this.text,
    this.image,
    this.video,
    this.document,
  });

  InteractiveHeader copyWith({
    String? type,
    String? text,
    String? image,
    String? video,
    String? document,
  }) =>
      InteractiveHeader(
        type: type ?? this.type,
        text: text ?? this.text,
        image: image ?? this.image,
        video: video ?? this.video,
        document: document ?? this.document,
      );

  factory InteractiveHeader.fromRawJson(String str) => InteractiveHeader.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InteractiveHeader.fromJson(Map<String, dynamic> json) => InteractiveHeader(
        type: json["type"],
        text: json["text"],
        image: json["image"],
        video: json["video"],
        document: json["document"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "text": text,
        "image": image,
        "video": video,
        "document": document,
      };
}

class LinkPreview {
  String? body;
  String? url;
  String? id;
  String? link;
  String? sha256;
  String? title;
  String? description;
  String? canonical;
  String? preview;
  bool? viewOnce;

  LinkPreview({
    this.body,
    this.url,
    this.id,
    this.link,
    this.sha256,
    this.title,
    this.description,
    this.canonical,
    this.preview,
    this.viewOnce,
  });

  LinkPreview copyWith({
    String? body,
    String? url,
    String? id,
    String? link,
    String? sha256,
    String? title,
    String? description,
    String? canonical,
    String? preview,
    bool? viewOnce,
  }) =>
      LinkPreview(
        body: body ?? this.body,
        url: url ?? this.url,
        id: id ?? this.id,
        link: link ?? this.link,
        sha256: sha256 ?? this.sha256,
        title: title ?? this.title,
        description: description ?? this.description,
        canonical: canonical ?? this.canonical,
        preview: preview ?? this.preview,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory LinkPreview.fromRawJson(String str) => LinkPreview.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LinkPreview.fromJson(Map<String, dynamic> json) => LinkPreview(
        body: json["body"],
        url: json["url"],
        id: json["id"],
        link: json["link"],
        sha256: json["sha256"],
        title: json["title"],
        description: json["description"],
        canonical: json["canonical"],
        preview: json["preview"],
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "body": body,
        "url": url,
        "id": id,
        "link": link,
        "sha256": sha256,
        "title": title,
        "description": description,
        "canonical": canonical,
        "preview": preview,
        "view_once": viewOnce,
      };
}

class LiveLocation {
  int? latitude;
  int? longitude;
  int? accuracy;
  int? speed;
  int? degrees;
  String? caption;
  int? sequenceNumber;
  int? timeOffset;
  String? preview;
  bool? viewOnce;

  LiveLocation({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.speed,
    this.degrees,
    this.caption,
    this.sequenceNumber,
    this.timeOffset,
    this.preview,
    this.viewOnce,
  });

  LiveLocation copyWith({
    int? latitude,
    int? longitude,
    int? accuracy,
    int? speed,
    int? degrees,
    String? caption,
    int? sequenceNumber,
    int? timeOffset,
    String? preview,
    bool? viewOnce,
  }) =>
      LiveLocation(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        accuracy: accuracy ?? this.accuracy,
        speed: speed ?? this.speed,
        degrees: degrees ?? this.degrees,
        caption: caption ?? this.caption,
        sequenceNumber: sequenceNumber ?? this.sequenceNumber,
        timeOffset: timeOffset ?? this.timeOffset,
        preview: preview ?? this.preview,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory LiveLocation.fromRawJson(String str) => LiveLocation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LiveLocation.fromJson(Map<String, dynamic> json) => LiveLocation(
        latitude: json["latitude"],
        longitude: json["longitude"],
        accuracy: json["accuracy"],
        speed: json["speed"],
        degrees: json["degrees"],
        caption: json["caption"],
        sequenceNumber: json["sequence_number"],
        timeOffset: json["time_offset"],
        preview: json["preview"],
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "speed": speed,
        "degrees": degrees,
        "caption": caption,
        "sequence_number": sequenceNumber,
        "time_offset": timeOffset,
        "preview": preview,
        "view_once": viewOnce,
      };
}

class Order {
  String? orderId;
  String? seller;
  String? title;
  String? text;
  String? token;
  int? itemCount;
  String? currency;
  int? totalPrice;
  String? status;
  String? preview;

  Order({
    this.orderId,
    this.seller,
    this.title,
    this.text,
    this.token,
    this.itemCount,
    this.currency,
    this.totalPrice,
    this.status,
    this.preview,
  });

  Order copyWith({
    String? orderId,
    String? seller,
    String? title,
    String? text,
    String? token,
    int? itemCount,
    String? currency,
    int? totalPrice,
    String? status,
    String? preview,
  }) =>
      Order(
        orderId: orderId ?? this.orderId,
        seller: seller ?? this.seller,
        title: title ?? this.title,
        text: text ?? this.text,
        token: token ?? this.token,
        itemCount: itemCount ?? this.itemCount,
        currency: currency ?? this.currency,
        totalPrice: totalPrice ?? this.totalPrice,
        status: status ?? this.status,
        preview: preview ?? this.preview,
      );

  factory Order.fromRawJson(String str) => Order.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["order_id"],
        seller: json["seller"],
        title: json["title"],
        text: json["text"],
        token: json["token"],
        itemCount: json["item_count"],
        currency: json["currency"],
        totalPrice: json["total_price"],
        status: json["status"],
        preview: json["preview"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "seller": seller,
        "title": title,
        "text": text,
        "token": token,
        "item_count": itemCount,
        "currency": currency,
        "total_price": totalPrice,
        "status": status,
        "preview": preview,
      };
}

class Poll {
  String? title;
  List<String>? options;
  int? count;
  List<Label>? results;
  bool? viewOnce;

  Poll({
    this.title,
    this.options,
    this.count,
    this.results,
    this.viewOnce,
  });

  Poll copyWith({
    String? title,
    List<String>? options,
    int? count,
    List<Label>? results,
    bool? viewOnce,
  }) =>
      Poll(
        title: title ?? this.title,
        options: options ?? this.options,
        count: count ?? this.count,
        results: results ?? this.results,
        viewOnce: viewOnce ?? this.viewOnce,
      );

  factory Poll.fromRawJson(String str) => Poll.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Poll.fromJson(Map<String, dynamic> json) => Poll(
        title: json["title"],
        options: json["options"] == null ? [] : List<String>.from(json["options"]!.map((x) => x)),
        count: json["count"],
        results: json["results"] == null ? [] : List<Label>.from(json["results"]!.map((x) => Label.fromJson(x))),
        viewOnce: json["view_once"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
        "count": count,
        "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
        "view_once": viewOnce,
      };
}

class ProductItems {
  String? type;

  ProductItems({
    this.type,
  });

  ProductItems copyWith({
    String? type,
  }) =>
      ProductItems(
        type: type ?? this.type,
      );

  factory ProductItems.fromRawJson(String str) => ProductItems.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductItems.fromJson(Map<String, dynamic> json) => ProductItems(
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
      };
}

class Reaction {
  String? id;
  String? emoji;
  String? groupKey;
  int? t;
  bool? unread;
  int? count;

  Reaction({
    this.id,
    this.emoji,
    this.groupKey,
    this.t,
    this.unread,
    this.count,
  });

  Reaction copyWith({
    String? id,
    String? emoji,
    String? groupKey,
    int? t,
    bool? unread,
    int? count,
  }) =>
      Reaction(
        id: id ?? this.id,
        emoji: emoji ?? this.emoji,
        groupKey: groupKey ?? this.groupKey,
        t: t ?? this.t,
        unread: unread ?? this.unread,
        count: count ?? this.count,
      );

  factory Reaction.fromRawJson(String str) => Reaction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        id: json["id"],
        emoji: json["emoji"],
        groupKey: json["group_key"],
        t: json["t"],
        unread: json["unread"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "emoji": emoji,
        "group_key": groupKey,
        "t": t,
        "unread": unread,
        "count": count,
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
