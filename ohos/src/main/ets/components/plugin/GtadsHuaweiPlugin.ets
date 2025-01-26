import {
  AbilityAware,
  AbilityPluginBinding,
  Any,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { UIAbility } from '@kit.AbilityKit';
import { advertising, AutoAdComponent, identifier } from '@kit.AdsKit';
import FlutterUnionadEventPlugin from './FlutterUnionadEventPlugin';
import FullScreenVideoAdInteraction from './FullScreenVideoAdInteraction';
import hilog from '@ohos.hilog';
import { BusinessError } from '@kit.BasicServicesKit';

/** GtadsHuaweiPlugin **/
export default class GtadsHuaweiPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private applicationContext: Context | null = null;
  private uiAbility: UIAbility | null = null;
  // private adCreator = CSJAdSdk.getAdCreator();
  // private rewardAd: CSJRewardAd | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "GtadsHuaweiPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "gtads_huawei");
    this.channel.setMethodCallHandler(this)
    this.applicationContext = binding.getApplicationContext();
    new FlutterUnionadEventPlugin().onAttachedToEngine(binding);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.uiAbility = binding.getAbility()
  }

  onDetachedFromAbility(): void {
    this.uiAbility = null
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "register") {
      result.success(true)
    } else if (call.method == "getOAID") {
      // 使用Promise回调方式获取OAID
      identifier.getOAID().then((data) => {
        result.success(data)
        hilog.info(0x0000, 'testTag', '%{public}s', `Succeeded in getting adsIdentifierInfo by promise`);
      }).catch((error: BusinessError) => {
        result.success("")
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to get adsIdentifierInfo, code: ${error.code}, message: ${error.message}`);
      })
    } else if (call.method == "getSDKVersion") {
      // result.success(CSJAdSdk.getSDKVersion())
    } else if (call.method == "getThemeStatus") {
      //todo 没做
      result.success(0)
    } else if (call.method == "loadRewardVideoAd") {
      // let ohosCodeId: string = call.args.get("ohosCodeId");
      // let adSlot = new AdSlotBuilder()
      //   .setCodeId(ohosCodeId)
      //   .setAdLoadType(AdLoadType.LOAD)// .setMediaExtra(mediaExtra)
      //   .build()
      // let mLoadListener: RewardAdLoadListener = {
      //   onAdLoaded: (rewardAd: CSJRewardAd) => {
      //     console.error("rewardVideoAd loaded 广告类型：${getAdType(ad.rewardVideoAdType)}")
      //     this.rewardAd = rewardAd;
      //     FlutterUnionadEventPlugin.sendContent(
      //       new Map([["adType", "rewardAd"], ["onAdMethod", "onReady"]])
      //     );
      //   },
      //   onAdCached: (rewardAd: CSJRewardAd) => {
      //     console.error("rewardVideoAd video cached2")
      //     let map: Record<string, Any> = {
      //       "adType": "rewardAd", "onAdMethod": "onCache"
      //     };
      //     FlutterUnionadEventPlugin.sendContent(map)
      //   },
      //   onError: (code: number, message: string) => {
      //     console.error("视频加载失败" + code + message);
      //     let map: Record<string, Any> = {
      //       "adType": "rewardAd", "onAdMethod": "onFail", "error": code + message
      //     };
      //     FlutterUnionadEventPlugin.sendContent(map);
      //   }
      // }
      // this.adCreator.loadRewardAd(adSlot, mLoadListener)
      // result.success(true)
    } else if (call.method == "showRewardVideoAd") {
      // let adInteractionListener: RewardAdInteractionListener = {
      //   onShow: () => {
      //     console.error("rewardVideoAd show")
      //     let map: Record<string, Any> = {
      //       "adType": "rewardAd", "onAdMethod": "onShow"
      //     };
      //     FlutterUnionadEventPlugin.sendContent(map)
      //   },
      //   onSkip: () => {
      //     console.error("rewardVideoAd onSkippedVideo")
      //     let map: Record<string, Any> = {
      //       "adType": "rewardAd", "onAdMethod": "onSkip"
      //     };
      //     FlutterUnionadEventPlugin.sendContent(map)
      //   },
      //   onClick: () => {
      //     console.error("rewardVideoAd bar click")
      //     let map: Record<string, Any> = {
      //       "adType": "rewardAd", "onAdMethod": "onClick"
      //     };
      //     FlutterUnionadEventPlugin.sendContent(map)
      //   },
      //   onComplete: () => {
      //     console.error("rewardVideoAd complete")
      //   },
      //   onClose: () => {
      //     console.error("rewardVideoAd close")
      //     let map: Record<string, Any> = {
      //       "adType": "rewardAd", "onAdMethod": "onClose"
      //     };
      //     FlutterUnionadEventPlugin.sendContent(map)
      //   },
      //   onRewardArrived: (isVerify, rewardType, extraInfo) => {
      //     console.error("verify: $p0 amount:$p1 name:$p2 p3:$p3 p4:$p4")
      //     let map: Record<string, Any> = {
      //       "adType": "rewardAd",
      //       "onAdMethod": "onVerify",
      //       "rewardVerify": isVerify,
      //       "rewardAmount": 0,
      //       "rewardName": "0",
      //       "errorCode": 0,
      //       "error": "",
      //     };
      //
      //     FlutterUnionadEventPlugin.sendContent(map)
      //   }
      // }
      // // 广告基础信息加载完成x
      // if (this.uiAbility != null) {
      //   this.rewardAd?.setInteractionListener(adInteractionListener)
      //   this.rewardAd?.showRewardAd(this.uiAbility.context.windowStage)
      // }
      // result.success(true)
    } else if (call.method == "loadInterstitialAD") {
      let ohosCodeId: string = call.args.get("ohosCodeId");
      // let orientation: number = call.args.get("orientation");
      FullScreenVideoAdInteraction.init(
        this.applicationContext!,
        this.uiAbility!.context.windowStage,
        ohosCodeId,
        // orientation!!,
      )
      result.success(true)
      //显示插屏广告 全屏插屏二合一
    } else if (call.method == "showInterstitialAD") {
      FullScreenVideoAdInteraction.showAd()
      result.success(true)
    } else {
      result.notImplemented()
    }
  }
}