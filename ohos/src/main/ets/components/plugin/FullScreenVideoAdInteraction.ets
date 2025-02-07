import { Any, Log } from '@ohos/flutter_ohos';
import FlutterUnionadEventPlugin from './FlutterUnionadEventPlugin';
import { window } from '@kit.ArkUI';
import { advertising, identifier } from '@kit.AdsKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';

/**
 * @Description:
 * @Author: gstory0404@gmail
 * @CreateDate: 2020/8/21 15:48
 */
enum AdStatus {
  AD_OPEN = 'onAdOpen',
  AD_CLICKED = 'onAdClick',
  AD_CLOSED = 'onAdClose',
  AD_VIDEO_START = 'onVideoPlayBegin',
  AD_COMPLETED = 'onVideoPlayEnd'
}

const KEY_INTERSTITIAL_STATUS = 'interstitial_ad_status';

export default class FullScreenVideoAdInteraction {
  private static TAG = "FullScreenVideoExpressAd"
  static mContext: Context | null = null
  static mActivity: window.WindowStage | null = null
  // 用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
  static subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private static mttFullVideoAd: advertising.Advertisement | null = null

  // //广告所需参数
  private static mCodeId: string | null = null
  // private static orientation: number = 1
  // private static mAdCreator: CSJAdCreator | null

  static init(
    context: Context,
    mActivity: window.WindowStage | null,
    mCodeId: string | null,
    // orientation: number | null,
  ): void {
    FullScreenVideoAdInteraction.mContext = context
    FullScreenVideoAdInteraction.mActivity = mActivity
    FullScreenVideoAdInteraction.mCodeId = mCodeId
    // FullScreenVideoAdInteraction.orientation = orientation!!
    FullScreenVideoAdInteraction.loadFullScreenVideoAd()
  }

  private static async loadFullScreenVideoAd() {
    let adLoader: advertising.AdLoader = new advertising.AdLoader(FullScreenVideoAdInteraction.mContext!);
    const adRequestParam: advertising.AdRequestParams = {
      // 广告类型：插屏广告
      adType: 12,
      // 'testb4znbuh3n2'为测试专用的广告位ID，App正式发布时需要改为正式的广告位ID
      adId: FullScreenVideoAdInteraction.mCodeId!,
      // 开放匿名设备标识符
      oaid: await identifier.getOAID()
    };
    const adOption: advertising.AdOptions = {
      // 是否允许流量下载  0不允许 1允许，不设置以广告主设置为准
      allowMobileTraffic: 0,
      // 是否希望根据 COPPA 的规定将您的内容视为面向儿童的内容，: -1默认值，不确定 0不希望 1希望
      tagForChildProtection: -1,
      // 是否希望按适合未达到法定承诺年龄的欧洲经济区 (EEA) 用户的方式处理该广告请求 -1默认值，不确定 0不希望 1希望
      tagForUnderAgeOfPromise: -1,
      // 设置广告内容分级上限: W: 3+,所有受众 PI: 7+,家长指导 J:12+,青少年 A: 16+/18+，成人受众
      adContentClassification: 'A'
    };
    const adLoaderListener: advertising.AdLoadListener = {
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to request ad, message: ${errorMsg}, error code: ${errorCode}`);
        Log.e(FullScreenVideoAdInteraction.TAG, "fullScreenVideoAd加载失败  $code === > $message")
        let map: Record<string, Any> = {
          "adType": "interactAd",
          "onAdMethod": "onFail",
          "code": errorCode,
          "message": errorMsg,
        }
        FlutterUnionadEventPlugin.sendContent(map)
      },
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded in requesting ad!');
        FullScreenVideoAdInteraction.mttFullVideoAd = ads[0];
        // 广告基础信息加载完成
        Log.e(FullScreenVideoAdInteraction.TAG, "fullScreenVideoAdInteraction loaded")
        let map: Record<string, Any> = {
          "adType": "interactAd", "onAdMethod": "onReady"
        }
        FlutterUnionadEventPlugin.sendContent(map)
      },
    };
    // //加载全屏视频
    adLoader.loadAd(adRequestParam, adOption, adLoaderListener);
  }

  // 订阅方法，需要在每次展示广告前调用
  public static registerPPSReceiver(): void {
    if (FullScreenVideoAdInteraction.subscriber) {
      FullScreenVideoAdInteraction.unRegisterPPSReceiver();
    }
    // 订阅者信息
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['com.huawei.hms.pps.action.PPS_INTERSTITIAL_STATUS_CHANGED'],
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
        FullScreenVideoAdInteraction.subscriber = commonEventSubscriber;
        // 订阅公共事件回调
        if (!FullScreenVideoAdInteraction.subscriber) {
          hilog.warn(0x0000, 'testTag', '%{public}s', 'Need to create subscriber');
          return;
        }
        commonEventManager.subscribe(FullScreenVideoAdInteraction.subscriber,
          (err: BusinessError, commonEventData: commonEventManager.CommonEventData) => {
            if (err) {
              hilog.error(0x0000, 'testTag', '%{public}s', `Subscribe error, ${err.code}, message: ${err.message}`);
            } else {
              // 订阅者成功接收到公共事件
              hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded subscribing data');
              // 获取插屏广告页面变化状态
              const status: string = commonEventData?.parameters?.[KEY_INTERSTITIAL_STATUS];
              switch (status) {
                case AdStatus.AD_OPEN:
                  hilog.info(0x0000, 'testTag', '%{public}s', 'onAdOpen');
                  Log.e(FullScreenVideoAdInteraction.TAG, "fullScreenVideoAdInteraction show")
                  FlutterUnionadEventPlugin.sendContent({
                    "adType": "interactAd", "onAdMethod": "onShow"
                  })
                  break;
                case AdStatus.AD_CLICKED:
                  hilog.info(0x0000, 'testTag', '%{public}s', 'onAdClick');
                  Log.e(FullScreenVideoAdInteraction.TAG, "fullScreenVideoAd click")
                  FlutterUnionadEventPlugin.sendContent({
                    "adType": "interactAd", "onAdMethod": "onClick"
                  })
                  break;
                case AdStatus.AD_CLOSED:
                  hilog.info(0x0000, 'testTag', '%{public}s', 'onAdClose');
                  FullScreenVideoAdInteraction.unRegisterPPSReceiver();
                  Log.e(FullScreenVideoAdInteraction.TAG, "fullScreenVideoAd close")
                  FlutterUnionadEventPlugin.sendContent({
                    "adType": "interactAd", "onAdMethod": "onClose"
                  })
                  break;
                case AdStatus.AD_VIDEO_START:
                  hilog.info(0x0000, 'testTag', '%{public}s', 'onAdVideoStart');
                  break;
                case AdStatus.AD_COMPLETED:
                  hilog.info(0x0000, 'testTag', '%{public}s', 'onAdCompleted');
                  Log.e(FullScreenVideoAdInteraction.TAG, "fullScreenVideoAd complete")
                  FlutterUnionadEventPlugin.sendContent({
                    "adType": "interactAd", "onAdMethod": "onFinish"
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
    commonEventManager.unsubscribe(FullScreenVideoAdInteraction.subscriber, (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, 'testTag', '%{public}s', `Unsubscribe error, ${err.code}, message: ${err.message}}`);
      } else {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded in unsubscribing');
        FullScreenVideoAdInteraction.subscriber = null;
      }
    });
  }

  static showAd() {
    FullScreenVideoAdInteraction.registerPPSReceiver();
    if (FullScreenVideoAdInteraction.mttFullVideoAd == null) {
      let map: Record<string, Any> = {
        "adType": "interactAd",
        "onAdMethod": "onUnReady",
        "error": "广告预加载未完成"
      }
      FlutterUnionadEventPlugin.sendContent(map)
      return
    }
    advertising.showAd(FullScreenVideoAdInteraction.mttFullVideoAd, {
      // 插屏广告视频播放是否静音
      mute: true
    }, getContext(FullScreenVideoAdInteraction.mActivity) as common.UIAbilityContext);
  }
}