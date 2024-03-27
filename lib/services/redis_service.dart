import 'package:redis/redis.dart';
import 'package:whatsapp_ai/main.dart';

abstract class AbstractRedisService {
  bool get isConnectionOpen;
  Command? get currentCommand;
  String get host;
  int get port;
  bool get replyFlag;

  Future<void> initialize();

  Future<void> connect(String host, int port);
  Future<void> disconnect();
  Future<void> set(String key, String value);
  Future<dynamic> get(String key);
  Future<void> delete(String key);

  Future<void> updateReplyFlag();
  Future<void> setReplyFlag(bool value);

  Future<void> recordMessageReply(String messageId, String authorId);
  Future<bool> hasMessageBeenRepliedTo(String messageId, String authorId);
}

class RedisService extends AbstractRedisService with AppServicesMixin {
  static const String kHostSharedPrefKey = 'redis_host';
  static const String kPortSharedPrefKey = 'redis_port';

  static const String kReplyFlagPrefKey = 'prevent_multiple_replies';

  @override
  bool get isConnectionOpen => currentCommand != null;

  Command? _currentCommand;

  @override
  Command? get currentCommand => _currentCommand;

  String _host = '';

  @override
  String get host => _host;

  int _port = 0;

  @override
  int get port => _port;

  bool _replyFlag = false;

  @override
  bool get replyFlag => _replyFlag;

  @override
  Future<void> initialize() async {
    final host = sharedPreferences.getString(kHostSharedPrefKey);
    final port = sharedPreferences.getInt(kPortSharedPrefKey);

    if (host != null && port != null) {
      _host = host;
      _port = port;

      await connect(host, port);
      await updateReplyFlag();
    }
  }

  @override
  Future<void> connect(String host, int port) async {
    final redis = RedisConnection();
    _currentCommand = await redis.connect(host, port);

    await sharedPreferences.setString(kHostSharedPrefKey, host);
    await sharedPreferences.setInt(kPortSharedPrefKey, port);

    systemService.showInformationToast('Connected to Redis at $host:$port');
  }

  @override
  Future<void> disconnect() async {
    final RedisConnection? conn = _currentCommand?.get_connection();
    if (conn != null) {
      await conn.close();
    }

    _currentCommand = null;

    await sharedPreferences.remove(kHostSharedPrefKey);
    await sharedPreferences.remove(kPortSharedPrefKey);

    systemService.showInformationToast('Disconnected from Redis');
  }

  @override
  Future<void> set(String key, String value) async {
    if (_currentCommand == null) {
      throw Exception('Not connected to Redis');
    }

    await _currentCommand?.set(key, value);
  }

  @override
  Future<dynamic> get(String key) async {
    if (_currentCommand == null) {
      throw Exception('Not connected to Redis');
    }

    return await _currentCommand?.get(key);
  }

  @override
  Future<void> delete(String key) async {
    if (_currentCommand == null) {
      throw Exception('Not connected to Redis');
    }

    await _currentCommand?.set(key, '');
  }

  @override
  Future<void> updateReplyFlag() async {
    if (_currentCommand == null) {
      throw Exception('Not connected to Redis');
    }

    final String? value = await _currentCommand?.get(kReplyFlagPrefKey);
    if (value != null) {
      _replyFlag = value == 'true';
    }
  }

  @override
  Future<void> setReplyFlag(bool value) async {
    if (_currentCommand == null) {
      throw Exception('Not connected to Redis');
    }

    await _currentCommand?.set(kReplyFlagPrefKey, value.toString());
  }

  @override
  Future<void> recordMessageReply(String messageId, String authorId) async {
    if (_currentCommand == null) {
      throw Exception('Not connected to Redis');
    }

    await _currentCommand?.set('replied:$messageId:$authorId', 'true');
  }

  @override
  Future<bool> hasMessageBeenRepliedTo(String messageId, String authorId) async {
    if (_currentCommand == null) {
      throw Exception('Not connected to Redis');
    }

    final String? value = await _currentCommand?.get('replied:$messageId:$authorId');
    return value == 'true';
  }
}
