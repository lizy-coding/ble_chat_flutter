import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations == null) {
      throw FlutterError(
        'AppLocalizations not found in widget tree. Please add AppLocalizations.localizationsDelegates '
        'and AppLocalizations.supportedLocales to MaterialApp.',
      );
    }
    return localizations;
  }

  static const Map<String, Map<String, String>> _localizedValues = <String, Map<String, String>>{
    'en': <String, String>{
      'appTitle': 'BLE IM',
      'notificationNewMessage': 'New message',
      'chatWithPeer': 'Chat with {peerId}',
      'messagesLoadFailed': 'Failed to load messages: {error}',
      'messageInputHint': 'Message...',
      'bleDevicesTitle': 'BLE devices',
      'conversationsLabel': 'Conversations',
      'conversationLastUpdated': 'Last updated: {timestamp}',
      'devicesLabel': 'Devices',
      'noDevicesTitle': 'No devices found',
      'noDevicesSubtitle': 'No devices found. Please scan for devices.',
      'errorLabel': 'Error: {message}',
    },
    'zh': <String, String>{
      'appTitle': 'BLE 聊天',
      'notificationNewMessage': '新消息',
      'chatWithPeer': '与 {peerId} 聊天',
      'messagesLoadFailed': '加载消息失败：{error}',
      'messageInputHint': '请输入消息...',
      'bleDevicesTitle': 'BLE 设备',
      'conversationsLabel': '会话',
      'conversationLastUpdated': '最近更新：{timestamp}',
      'devicesLabel': '设备',
      'noDevicesTitle': '未发现设备',
      'noDevicesSubtitle': '未发现设备，请尝试重新扫描。',
      'errorLabel': '错误：{message}',
    },
  };

  String _resolve(String key) {
    final languageCode = _localizedValues.containsKey(locale.languageCode) ? locale.languageCode : 'en';
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']![key] ?? key;
  }

  String get appTitle => _resolve('appTitle');
  String get notificationNewMessage => _resolve('notificationNewMessage');
  String chatWithPeer(String peerId) => _resolve('chatWithPeer').replaceFirst('{peerId}', peerId);
  String messagesLoadFailed(String error) =>
      _resolve('messagesLoadFailed').replaceFirst('{error}', error);
  String get messageInputHint => _resolve('messageInputHint');
  String get bleDevicesTitle => _resolve('bleDevicesTitle');
  String get conversationsLabel => _resolve('conversationsLabel');
  String conversationLastUpdated(String timestamp) =>
      _resolve('conversationLastUpdated').replaceFirst('{timestamp}', timestamp);
  String get devicesLabel => _resolve('devicesLabel');
  String get noDevicesTitle => _resolve('noDevicesTitle');
  String get noDevicesSubtitle => _resolve('noDevicesSubtitle');
  String errorLabel(String message) => _resolve('errorLabel').replaceFirst('{message}', message);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension LocalizationBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
