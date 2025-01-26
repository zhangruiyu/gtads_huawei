import { window } from "@kit.ArkUI";
import { advertising, identifier } from '@kit.AdsKit';
import hilog from "@ohos.hilog";
import FlutterUnionadEventPlugin from './FlutterUnionadEventPlugin';
import { common } from "@kit.AbilityKit";
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { Any, Log } from "@ohos/flutter_ohos";


enum AdStatus {
  AD_OPEN = 'onAdOpen',
  AD_CLICKED = 'onAdClick',
  AD_CLOSED = 'onAdClose',
  AD_REWARDED = 'onAdReward',
  AD_VIDEO_START = 'onVideoPlayBegin',
  AD_COMPLETED = 'onVideoPlayEnd'
}

const KEY_REWARD_DATA = "reward_ad_data";
const KEY_REWARD_STATUS = "reward_ad_status";

export default class RewardVideoAd {
  private static TAG = "RewardVideoAd"
  static mContext: Context | null = null
  static mActivity: window.WindowStage | null = null
  // 用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
  static subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private static mTTAdNative: advertising.Advertisement | null = null
  // //广告所需参数
  private static mCodeId: string | null = null

  static init(context: Context,
    mActivity: window.WindowStage | null,
    mCodeId: string | null,): void {
    RewardVideoAd.mContext = context
    RewardVideoAd.mActivity = mActivity
    RewardVideoAd.mCodeId = mCodeId
    RewardVideoAd.loadRewardVideoAd()
  }


  private static async loadRewardVideoAd() {
    let adLoader: advertising.AdLoader = new advertising.AdLoader(RewardVideoAd.mContext!);
    const adRequestParam: advertising.AdRequestParams = {
      // 广告类型：激励广告
      adType: 7,
      // 'testx9dtjwj8hp'为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID
      adId: 'testx9dtjwj8hp',
      // 开放匿名设备标识符
      oaid: await identifier.getOAID()
    };
    const adOption: advertising.AdOptions = {
      // 设置是否请求非个性化广告
      nonPersonalizedAd: 0,
      // 是否允许流量下载0：不允许，1：允许，不设置以广告主设置为准
      allowMobileTraffic: 0,
      // 是否希望根据 COPPA 的规定将您的内容视为面向儿童的内容: -1默认值，不确定 0不希望 1希望
      tagForChildProtection: -1,
      // 是否希望按适合未达到法定承诺年龄的欧洲经济区 (EEA) 用户的方式处理该广告请求： -1默认值，不确定 0不希望 1希望
      tagForUnderAgeOfPromise: -1,
      // 设置广告内容分级上限: W: 3+,所有受众 PI: 7+,家长指导 J:12+,青少年 A: 16+/18+，成人受众
      adContentClassification: 'A'
    };
    const adLoaderListener: advertising.AdLoadListener = {
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to request ad, message: ${errorMsg}, error code: ${errorCode}`);
        FlutterUnionadEventPlugin.sendContent({
          "adType": "rewardAd",
          "onAdMethod": "onFail",
          "code": errorCode,
          "message": errorMsg
        });
      },
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        hilog.info(0x0000, 'testTag', '%{public}s', `Succeeded in requesting ad`);
        RewardVideoAd.mTTAdNative = ads[0];
        FlutterUnionadEventPlugin.sendContent(
          new Map([["adType", "rewardAd"], ["onAdMethod", "onReady"]])
        );
      },
    };
    adLoader.loadAd(adRequestParam, adOption, adLoaderListener);
  }


  // 订阅方法，需要在每次展示广告前调用
  public static registerPPSReceiver(): void {
    if (RewardVideoAd.subscriber) {
      RewardVideoAd.unRegisterPPSReceiver();
    }
    // 订阅者信息
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['com.huawei.hms.pps.action.PPS_REWARD_STATUS_CHANGED'],
      // publisherBundleName被设置为"com.huawei.hms.adsservice",这意味着只有来自该包名的事件才会被订阅者接受和处理。
      // 如果没有明确声明publisherBundleName，那么订阅者可能会收到来自其它包名的伪造事件，从而导致安全性问题或误导。
      publisherBundleName: 'com.huawei.hms.adsservice'
    };
    // 创建订阅者回调
    commonEventManager.createSubscriber(subscribeInfo,
      (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
        if (err) {
          hilog.error(0x0000, 'testTag', '%{public}s', `CreateSubscriber error, ${err.code}, message: ${err.message}}`);
          return;
        }
        hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded in creating subscriber');
        RewardVideoAd.subscriber = commonEventSubscriber;
        // 订阅公共事件回调
        if (!RewardVideoAd.subscriber) {
          hilog.warn(0x0000, 'testTag', '%{public}s', 'Need to create subscriber');
          return;
        }
        commonEventManager.subscribe(RewardVideoAd.subscriber, (err: BusinessError, commonEventSubscriber:
          commonEventManager.CommonEventData) => {
          if (err) {
            hilog.error(0x0000, 'testTag', '%{public}s', `Subscribe error, ${err.code}, message: ${err.message}`);
          } else {
            // 订阅者成功接收到公共事件
            hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded subscribing data');
            // 获取插屏广告页面变化状态
            const status: string = commonEventSubscriber?.parameters?.[KEY_REWARD_STATUS];
            switch (status) {
              case AdStatus.AD_OPEN:
                hilog.info(0x0000, 'testTag', '%{public}s', 'onAdOpen');
                Log.e(RewardVideoAd.TAG, "fullScreenVideoAdInteraction show")
                FlutterUnionadEventPlugin.sendContent({
                  "adType": "rewardAd", "onAdMethod": "onShow"
                })
                break;
              case AdStatus.AD_CLICKED:
                hilog.info(0x0000, 'testTag', '%{public}s', 'onAdClick');
                Log.e(RewardVideoAd.TAG, "fullScreenVideoAd click")
                FlutterUnionadEventPlugin.sendContent({
                  "adType": "rewardAd", "onAdMethod": "onClick"
                })
                break;
              case AdStatus.AD_CLOSED:
                hilog.info(0x0000, 'testTag', '%{public}s', 'onAdClose');
                RewardVideoAd.unRegisterPPSReceiver();
                Log.e(RewardVideoAd.TAG, "fullScreenVideoAd close")
                FlutterUnionadEventPlugin.sendContent({
                  "adType": "rewardAd", "onAdMethod": "onClose"
                })
                break;
              case AdStatus.AD_REWARDED:
                const rewardData: Record<string, string | number> =
                  commonEventSubscriber?.parameters?.[KEY_REWARD_DATA];

                const rewardType: string = rewardData?.rewardType as string;
                const rewardAmount: number = rewardData?.rewardAmount as number;
                hilog.info(0x0000, 'testTag', '%{public}s',
                  `onAdReward, rewardType: ${rewardType}, rewardAmount: ${rewardAmount}`);
                FlutterUnionadEventPlugin.sendContent({
                  "adType": "rewardAd",
                  "onAdMethod": "onVerify",
                  "rewardVerify": true,
                  "rewardAmount": rewardAmount,
                  "rewardName": null,
                  "errorCode": 0,
                  "error": null,
                })
                break;
              case AdStatus.AD_VIDEO_START:
                hilog.info(0x0000, 'testTag', '%{public}s', 'onAdVideoStart');
                break;
              case AdStatus.AD_COMPLETED:
                hilog.info(0x0000, 'testTag', '%{public}s', 'onAdCompleted');
                Log.e(RewardVideoAd.TAG, "fullScreenVideoAd complete")
                FlutterUnionadEventPlugin.sendContent({
                  "adType": "rewardAd", "onAdMethod": "onFinish"
                })
                break;
              default:
                break;
            }
          }
        });
      });
  }

  // 取消订阅
  public static unRegisterPPSReceiver(): void {
    commonEventManager.unsubscribe(RewardVideoAd.subscriber, (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, 'testTag', '%{public}s', `Unsubscribe error, ${err.code}, message: ${err.message}}`);
      } else {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded in unsubscribing');
        RewardVideoAd.subscriber = null;
      }
    });
  }

  public static showAd(): void {
    RewardVideoAd.registerPPSReceiver();
    if (RewardVideoAd.mTTAdNative == null) {
      let map: Record<string, Any> = {
        "adType": "rewardAd",
        "onAdMethod": "onUnReady",
        "error": "广告预加载未完成"
      }
      FlutterUnionadEventPlugin.sendContent(map)
      return
    }
    advertising.showAd(RewardVideoAd.mTTAdNative, {
      // 插屏广告视频播放是否静音
      mute: true
    }, getContext(RewardVideoAd.mActivity) as common.UIAbilityContext);
  }
}