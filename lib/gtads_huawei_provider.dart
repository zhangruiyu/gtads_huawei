import 'dart:async';

import 'package:gtads/gtads.dart';

import 'flutter_huaweiad_callback.dart';
import 'flutter_huaweiad_stream.dart';
import 'gtads_huawei.dart';

class GTAdsHuaweiProvider extends GTAdsProvider {
  GTAdsHuaweiProvider(String alias) : super(alias, '', '');

  @override
  Future<bool> initAd(bool isDebug) async {
    return MethodChannelGtadsHuawei.init(isDebug);
  }

  @override
  StreamSubscription? insertAd(
      GTAdsCode adCode, bool isFull, GTAdsCallBack? callBack) {
    StreamSubscription? stream = null;
    stream = FlutterHuaweiAdStream.initAdStream(
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
            callBack.onFail!(adCode, message);
          }
        },
        onClose: () {
          if (callBack != null && callBack.onClose != null) {
            callBack.onClose!(adCode);
          }
        },
        onReady: () async {
          await MethodChannelGtadsHuawei.showUnifiedInterstitialAD();
        },
        onUnReady: () {
          if (callBack != null && callBack.onFail != null) {
            callBack.onFail!(adCode, "广告未准备就绪");
          }
        },
        onVerify: (transId, rewardName, rewardAmount) {
          if (callBack != null && callBack.onVerify != null) {
            callBack.onVerify!(adCode, true, "", rewardName, rewardAmount);
          }
        },
      ),
    );
    // FlutterUnionad.loadFullScreenVideoAdInteraction(
    //   //android 全屏广告id 必填
    //   androidCodeId: adCode.androidId ?? "",
    //   //ios 全屏广告id 必填
    //   iosCodeId: adCode.iosId ?? "",
    //   //是否支持 DeepLink 选填
    //   supportDeepLink: true,
    //   //视屏方向 选填
    //   orientation: FlutterUnionadOrientation.VERTICAL,
    //   //控制下载APP前是否弹出二次确认弹窗
    //   downloadType: FlutterUnionadDownLoadType.DOWNLOAD_TYPE_POPUP,
    //   //用于标注此次的广告请求用途为预加载（当做缓存）还是实时加载，
    //   adLoadType: FlutterUnionadLoadType.LOAD,
    // );
    MethodChannelGtadsHuawei.loadInterstitialAD(adCode.androidId!);
    return stream;
  }
/*
  @override
  StreamSubscription? rewardAd(
      GTAdsCode adCode,
      String rewardName,
      int rewardAmount,
      String userId,
      String customData,
      GTAdsCallBack? callBack) {
    StreamSubscription? stream = null;
    stream = FlutterUnionadStream.initAdStream(
      flutterUnionadRewardAdCallBack: FlutterUnionadRewardAdCallBack(
        onShow: () {
          print("激励广告--onShow--$adCode");
          if (callBack?.onShow != null) {
            callBack?.onShow!(adCode);
          }
        },
        onClick: () {
          if (callBack?.onClick != null) {
            callBack?.onClick!(adCode);
          }
        },
        onFail: (error) {
          if (callBack?.onFail != null) {
            callBack?.onFail!(adCode, error);
          }
        },
        onClose: () {
          if (callBack?.onClose != null) {
            callBack?.onClose!(adCode);
          }
        },
        onSkip: () {},
        onVerify: (rewardVerify, rewardAmount, rewardName, code, message) {
          if (!rewardVerify) {
            if (callBack?.onFail != null) {
              callBack?.onFail!(adCode, "$code $message");
            }
          }
          if (callBack?.onVerify != null) {
            callBack?.onVerify!(
                adCode, rewardVerify, "", rewardName, rewardAmount);
          }
        },
        onReady: () async {},
        onCache: () async {
          //显示激励广告
          await FlutterUnionad.showRewardVideoAd();
        },
        onUnReady: () {
          if (callBack?.onFail != null) {
            callBack?.onFail!(adCode, "激励广告预加载未准备就绪");
          }
        },
        onRewardArrived: (rewardVerify, rewardType, rewardAmount, rewardName,
            errorCode, error, propose) {
          if (callBack?.onExpand != null) {
            var map = {
              "type": "onRewardArrived",
              "rewardVerify": rewardVerify,
              "rewardType": rewardType,
              "rewardAmount": rewardAmount,
              "rewardName": rewardName,
              "errorCode": errorCode,
              "error": error,
              "propose": propose,
            };
            callBack?.onExpand!(adCode, map);
          }
        },
      ),
    );
    FlutterUnionad.loadRewardVideoAd(
      //是否个性化 选填
      androidCodeId: adCode.androidId ?? "",
      //Android 激励视频广告id  必填
      iosCodeId: adCode.iosId ?? "",
      //ios 激励视频广告id  必填
      supportDeepLink: true,
      //是否支持 DeepLink 选填
      rewardName: rewardName,
      //奖励名称 选填
      rewardAmount: rewardAmount,
      //奖励数量 选填
      userID: userId,
      //  用户id 选填
      orientation: FlutterUnionadOrientation.VERTICAL,
      //控制下载APP前是否弹出二次确认弹窗
      downloadType: FlutterUnionadDownLoadType.DOWNLOAD_TYPE_POPUP,
      //视屏方向 选填
      mediaExtra: customData,
      //扩展参数 选填
      //用于标注此次的广告请求用途为预加载（当做缓存）还是实时加载，
      adLoadType: FlutterUnionadLoadType.PRELOAD,
    );
    return stream;
  }*/
}
