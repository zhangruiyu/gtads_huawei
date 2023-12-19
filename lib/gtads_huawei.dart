import 'package:flutter/services.dart';

/// An implementation of [GtadsHuaweiPlatform] that uses method channels.
class MethodChannelGtadsHuawei {
  static const methodChannel = MethodChannel('gtads_huawei');

  static Future<bool> init(bool debug) async {
    final result = await methodChannel.invokeMethod<bool>('init',{
      'debug':debug
    });
    return result!;
  }

  static Future<bool> loadInterstitialAD(String adCode) async {
    final result = await methodChannel
        .invokeMethod<bool>('loadInterstitialAD', {'adCode': adCode});
    return result!;
  }

  static Future<bool> showUnifiedInterstitialAD() async {
    return await methodChannel.invokeMethod("showInterstitialAD");
  }
}
