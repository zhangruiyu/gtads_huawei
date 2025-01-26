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
import { abilityAccessCtrl, common, UIAbility } from '@kit.AbilityKit';
import { advertising, AutoAdComponent, identifier } from '@kit.AdsKit';
import FlutterUnionadEventPlugin from './FlutterUnionadEventPlugin';
import FullScreenVideoAdInteraction from './FullScreenVideoAdInteraction';
import hilog from '@ohos.hilog';
import { BusinessError } from '@kit.BasicServicesKit';
import RewardVideoAd from 'gtads_huawei/src/main/ets/components/plugin/RewardVideoAd';

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

  private requestOAIDTrackingConsentPermissions(context: common.Context): void {
    // 进入页面时，向用户请求授权广告跨应用关联访问权限
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']).then((data) => {
        // if (data.authResults[0] === 0) {
        //   hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in requesting permission');
          identifier.getOAID().then((data: string) => {
            // this.oaid = data;
            hilog.info(0x0000, "TAG", '%{public}s', `Succeeded in getting adsIdentifierInfo by promise`);
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, "TAG", '%{public}s', `Failed to get AdsIdentifierInfo , message: ${error.message}`);
          })
        // } else {
        //   hilog.info(0x0000, TAG, '%{public}s', 'user rejected');
        // }
      }).catch((err: BusinessError) => {
        // hilog.error(0x0000, TAG, '%{public}s', `request permission failed, error: ${err.code} ${err.message}`);
      })
    } catch (err) {
      hilog.error(0x0000, "TAG", '%{public}s', `catch err, code:${err.code}, message: ${err.message}`);
    }
  }
  onMethodCall(call: MethodCall, result: MethodResult): void {

    if (call.method == "init") {
      this.requestOAIDTrackingConsentPermissions(getContext(this.uiAbility!));
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
    } else if (call.method == "loadRewardVideoAd") {
      let ohosCodeId: string = call.args.get("ohosCodeId");
      RewardVideoAd.init(
        this.applicationContext!,
        this.uiAbility!.context.windowStage,
        ohosCodeId,
        // orientation!!,
      )
      result.success(true)
    } else if (call.method == "showRewardVideoAd") {
      RewardVideoAd.showAd()
      result.success(true)
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