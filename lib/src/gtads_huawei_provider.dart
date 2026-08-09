import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gtads/gtads.dart';

import 'flutter_huaweiad_callback.dart';
import 'flutter_huaweiad_stream.dart';
import 'gtads_huawei_plugin.dart';

class GTAdsHuaweiProvider extends GTAdsProvider {
  static int _requestSequence = 0;

  GTAdsHuaweiProvider(String alias) : super(alias, '', '');

  @override
  Future<bool> initAd(bool isDebug) async {
    return MethodChannelGtadsHuawei.init(isDebug);
  }

  @override
  StreamSubscription? insertAd(
      GTAdsCode adCode, bool isFull, GTAdsCallBack? callBack) {
    final requestId = _nextRequestId('interstitial');
    StreamSubscription? stream;
    stream = FlutterHuaweiAdStream.initAdStream(
      requestId: requestId,
      flutterHuaweiadInteractionCallBack: FlutterHuaweiadInteractionCallBack(
        onShow: () {
          if (callBack != null && callBack.onShow != null) {
            callBack.onShow!(adCode);
          }
        },
        onClick: () {
          if (callBack != null && callBack.onClick != null) {
            callBack.onClick!(adCode);
          }
        },
        onFail: (code, message) {
          if (callBack != null && callBack.onFail != null) {
            callBack.onFail!(adCode, _failureMessage(code, message));
          }
        },
        onClose: () {
          if (callBack != null && callBack.onClose != null) {
            callBack.onClose!(adCode);
          }
        },
        onReady: () {
          unawaited(_showInterstitial(adCode, requestId, callBack));
        },
        onUnReady: () {
          if (callBack != null && callBack.onFail != null) {
            callBack.onFail!(adCode, "广告未准备就绪");
          }
        },
        onVerify: (rewardName, rewardAmount) {
          if (callBack != null && callBack.onVerify != null) {
            callBack.onVerify!(adCode, true, "", rewardName, rewardAmount);
          }
        },
      ),
    );
    unawaited(_loadInterstitial(adCode, requestId, callBack));
    return stream;
  }

  @override
  StreamSubscription? rewardAd(
      GTAdsCode adCode,
      String rewardName,
      int rewardAmount,
      String userId,
      String customData,
      GTAdsCallBack? callBack) {
    final requestId = _nextRequestId('reward');
    StreamSubscription? stream;
    stream = FlutterHuaweiAdStream.initAdStream(
      requestId: requestId,
      //激励广告
      flutterHuaweiadRewardCallBack: FlutterHuaweiadRewardCallBack(onShow: () {
        if (callBack != null && callBack.onShow != null) {
          callBack.onShow!(adCode);
        }
      }, onClick: () {
        if (callBack != null && callBack.onClick != null) {
          callBack.onClick!(adCode);
        }
      }, onFail: (code, message) {
        if (callBack != null && callBack.onFail != null) {
          callBack.onFail!(adCode, _failureMessage(code, message));
        }
      }, onClose: () {
        if (callBack != null && callBack.onClose != null) {
          callBack.onClose!(adCode);
        }
      }, onReady: () {
        unawaited(_showReward(adCode, requestId, callBack));
      }, onUnReady: () {
        if (callBack != null && callBack.onFail != null) {
          callBack.onFail!(adCode, "激励广告预加载未准备就绪");
        }
      }, onVerify: (rewardName, rewardAmount) {
        if (callBack != null && callBack.onVerify != null) {
          callBack.onVerify!(adCode, true, "", rewardName, rewardAmount);
        }
      }, onFinish: () {
        if (callBack != null && callBack.onFinish != null) {
          callBack.onFinish!(adCode);
        }
      }),
    );
    unawaited(_loadReward(
      adCode,
      rewardName,
      rewardAmount,
      userId,
      customData,
      requestId,
      callBack,
    ));
    return stream;
  }

  static String _failureMessage(int code, dynamic message) {
    final detail = message?.toString().trim() ?? '';
    return detail.isNotEmpty ? detail : '华为广告失败(code=$code)';
  }

  static String _platformFailureMessage(Object error) {
    if (error is PlatformException) {
      final message = error.message?.trim();
      return message == null || message.isEmpty
          ? '华为广告调用失败(${error.code})'
          : '$message(${error.code})';
    }
    return '华为广告调用失败：$error';
  }

  static void _notifyPlatformFailure(
      GTAdsCode adCode, GTAdsCallBack? callBack, Object error) {
    callBack?.onFail?.call(adCode, _platformFailureMessage(error));
  }

  static Future<void> _loadInterstitial(
      GTAdsCode adCode, String requestId, GTAdsCallBack? callBack) async {
    try {
      await MethodChannelGtadsHuawei.loadInterstitialAD(
        androidId: adCode.androidId ?? '',
        ohosId: adCode.ohosId ?? '',
        requestId: requestId,
      );
    } catch (error) {
      _notifyPlatformFailure(adCode, callBack, error);
    }
  }

  static Future<void> _showInterstitial(
      GTAdsCode adCode, String requestId, GTAdsCallBack? callBack) async {
    try {
      await MethodChannelGtadsHuawei.showUnifiedInterstitialAD(requestId);
    } catch (error) {
      _notifyPlatformFailure(adCode, callBack, error);
    }
  }

  static Future<void> _loadReward(
    GTAdsCode adCode,
    String rewardName,
    int rewardAmount,
    String userId,
    String customData,
    String requestId,
    GTAdsCallBack? callBack,
  ) async {
    try {
      await MethodChannelGtadsHuawei.loadRewardVideoAd(
        androidId: adCode.androidId ?? '',
        ohosId: adCode.ohosId ?? '',
        userID: userId,
        rewardName: rewardName,
        rewardAmount: rewardAmount,
        customData: customData,
        requestId: requestId,
      );
    } catch (error) {
      _notifyPlatformFailure(adCode, callBack, error);
    }
  }

  static Future<void> _showReward(
      GTAdsCode adCode, String requestId, GTAdsCallBack? callBack) async {
    try {
      await MethodChannelGtadsHuawei.showRewardVideoAd(requestId);
    } catch (error) {
      _notifyPlatformFailure(adCode, callBack, error);
    }
  }

  static String _nextRequestId(String adType) {
    _requestSequence++;
    return '$adType-${DateTime.now().microsecondsSinceEpoch}-$_requestSequence';
  }
}
