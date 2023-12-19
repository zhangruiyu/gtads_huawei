import 'dart:async';

import 'package:flutter/services.dart';

import 'flutter_huaweiad_callback.dart';
import 'flutter_huaweiad_code.dart.dart';


/// @Author: gstory
/// @CreateDate: 2021/8/9 9:30 下午
/// @Description: dart类作用描述

const EventChannel HuaweiAdEventEvent =
    EventChannel("com.huazi.gtads_huawei/adevent");

class FlutterHuaweiAdStream {
  ///
  /// # 注册stream监听原生返回的信息
  ///
  /// [rewardAdCallBack] 激励广告回调
  ///
  /// [interactionAdCallBack] 插屏广告回调
  ///
  static StreamSubscription initAdStream(
      {FlutterHuaweiadRewardCallBack? flutterHuaweiadRewardCallBack,
      FlutterHuaweiadInteractionCallBack?
          flutterHuaweiadInteractionCallBack}) {
    StreamSubscription _adStream =
        HuaweiAdEventEvent.receiveBroadcastStream().listen((data) {
      switch (data[FlutterHuaweiadType.adType]) {

        ///激励广告
        case FlutterHuaweiadType.rewardAd:
          switch (data[FlutterHuaweiadMethod.onAdMethod]) {
            case FlutterHuaweiadMethod.onShow:
              if (flutterHuaweiadRewardCallBack?.onShow != null) {
                flutterHuaweiadRewardCallBack?.onShow!();
              }
              break;
            case FlutterHuaweiadMethod.onClose:
              if (flutterHuaweiadRewardCallBack?.onClose != null) {
                flutterHuaweiadRewardCallBack?.onClose!();
              }
              break;
            case FlutterHuaweiadMethod.onFail:
              if (flutterHuaweiadRewardCallBack?.onFail != null) {
                flutterHuaweiadRewardCallBack?.onFail!(
                    data["code"], data["message"]);
              }
              break;
            case FlutterHuaweiadMethod.onClick:
              if (flutterHuaweiadRewardCallBack?.onClick != null) {
                flutterHuaweiadRewardCallBack?.onClick!();
              }
              break;
            case FlutterHuaweiadMethod.onVerify:
              if (flutterHuaweiadRewardCallBack?.onVerify != null) {
                flutterHuaweiadRewardCallBack?.onVerify!(
                    data["transId"], data["rewardName"], data["rewardAmount"]);
              }
              break;
            case FlutterHuaweiadMethod.onFinish:
              if (flutterHuaweiadRewardCallBack?.onFinish != null) {
                flutterHuaweiadRewardCallBack?.onFinish!();
              }
              break;
            case FlutterHuaweiadMethod.onReady:
              if (flutterHuaweiadRewardCallBack?.onReady != null) {
                flutterHuaweiadRewardCallBack?.onReady!();
              }
              break;
            case FlutterHuaweiadMethod.onUnReady:
              if (flutterHuaweiadRewardCallBack?.onUnReady != null) {
                flutterHuaweiadRewardCallBack?.onUnReady!();
              }
              break;
            case FlutterHuaweiadMethod.onExpose:
              if (flutterHuaweiadRewardCallBack?.onExpose != null) {
                flutterHuaweiadRewardCallBack?.onExpose!();
              }
              break;
            case FlutterHuaweiadMethod.onECPM:
              if (flutterHuaweiadRewardCallBack?.onECPM != null) {
                flutterHuaweiadRewardCallBack?.onECPM!(
                    data["ecpmLevel"], data["ecpm"]);
              }
              break;
          }
          break;

        ///插屏广告
        case FlutterHuaweiadType.interactAd:
          switch (data[FlutterHuaweiadMethod.onAdMethod]) {
            case FlutterHuaweiadMethod.onShow:
              if (flutterHuaweiadInteractionCallBack?.onShow != null) {
                flutterHuaweiadInteractionCallBack?.onShow!();
              }
              break;
            case FlutterHuaweiadMethod.onClose:
              if (flutterHuaweiadInteractionCallBack?.onClose != null) {
                flutterHuaweiadInteractionCallBack?.onClose!();
              }
              break;
            case FlutterHuaweiadMethod.onFail:
              if (flutterHuaweiadInteractionCallBack?.onFail != null) {
                flutterHuaweiadInteractionCallBack?.onFail!(
                    data["code"], data["message"]);
              }
              break;
            case FlutterHuaweiadMethod.onClick:
              if (flutterHuaweiadInteractionCallBack?.onClick != null) {
                flutterHuaweiadInteractionCallBack?.onClick!();
              }
              break;
            case FlutterHuaweiadMethod.onExpose:
              if (flutterHuaweiadInteractionCallBack?.onExpose != null) {
                flutterHuaweiadInteractionCallBack?.onExpose!();
              }
              break;
            case FlutterHuaweiadMethod.onReady:
              if (flutterHuaweiadInteractionCallBack?.onReady != null) {
                flutterHuaweiadInteractionCallBack?.onReady!();
              }
              break;
            case FlutterHuaweiadMethod.onUnReady:
              if (flutterHuaweiadInteractionCallBack?.onUnReady != null) {
                flutterHuaweiadInteractionCallBack?.onUnReady!();
              }
              break;
            case FlutterHuaweiadMethod.onVerify:
              if (flutterHuaweiadInteractionCallBack?.onVerify != null) {
                flutterHuaweiadInteractionCallBack?.onVerify!(
                    data["transId"], "", 0);
              }
              break;
            case FlutterHuaweiadMethod.onECPM:
              if (flutterHuaweiadInteractionCallBack?.onECPM != null) {
                flutterHuaweiadInteractionCallBack?.onECPM!(
                    data["ecpmLevel"], data["ecpm"]);
              }
              break;
          }
          break;
      }
    });
    return _adStream;
  }

  static void deleteAdStream(StreamSubscription stream) {
    stream.cancel();
  }
}
