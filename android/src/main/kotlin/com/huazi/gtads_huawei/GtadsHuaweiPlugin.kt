package com.huazi.gtads_huawei

import android.app.Activity
import android.content.Context
import com.huawei.hms.ads.HwAds
import com.huazi.gtads_huawei.interstitialad.InterstitialAd
import com.huazi.gtads_huawei.rewardvideoad.RewardVideoAd
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** GtadsHuaweiPlugin */
class GtadsHuaweiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var applicationContext: Context? = null
    private var mActivity: Activity? = null
    private var eventPlugin: FlutterHuaweiAdEventPlugin? = null
    private var isInitialized = false

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gtads_huawei")
        channel.setMethodCallHandler(this)
        eventPlugin = FlutterHuaweiAdEventPlugin().also {
            it.onAttachedToEngine(flutterPluginBinding)
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
//        Log.e("GtadsHuaweiPlugin->","onAttachedToActivity")
//        FlutterTencentAdViewPlugin.registerWith(mFlutterPluginBinding!!,mActivity!!)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mActivity = binding.activity
//        Log.e("GtadsHuaweiPlugin->","onReattachedToActivityForConfigChanges")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        mActivity = null
//        Log.e("GtadsHuaweiPlugin->","onDetachedFromActivityForConfigChanges")
    }

    override fun onDetachedFromActivity() {
        mActivity = null
        disposeAds()
//        Log.e("GtadsHuaweiPlugin->","onDetachedFromActivity")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> {
                val context = applicationContext
                if (context == null) {
                    result.error("NO_CONTEXT", "华为广告初始化失败：应用 Context 不可用", null)
                    return
                }
                val debug = call.argument<Boolean>("debug") ?: false
                HwAds.init(context)
                LogUtil.setAppName("flutter_huaweiad")
                LogUtil.setShow(debug)
                isInitialized = true
                result.success(true)
            }

            "loadInterstitialAD" -> {
                val activity = requireActivity(result) ?: return
                val adId = requireAdId(call, result) ?: return
                val requestId = requireRequestId(call, result) ?: return
                if (!requireInitialized(result)) return
                result.success(InterstitialAd.load(activity, adId, requestId))
            }

            "showInterstitialAD" -> {
                val activity = requireActivity(result) ?: return
                val requestId = requireRequestId(call, result) ?: return
                result.success(InterstitialAd.showAd(activity, requestId))
            }

            "loadRewardVideoAd" -> {
                val activity = requireActivity(result) ?: return
                requireAdId(call, result) ?: return
                val requestId = requireRequestId(call, result) ?: return
                if (!requireInitialized(result)) return
                val params = call.arguments as? Map<*, *>
                if (params == null) {
                    result.error("INVALID_ARGUMENTS", "华为激励广告参数无效", null)
                    return
                }
                result.success(RewardVideoAd.load(activity, params, requestId))
            }

            "showRewardVideoAd" -> {
                val activity = requireActivity(result) ?: return
                val requestId = requireRequestId(call, result) ?: return
                result.success(RewardVideoAd.showAd(activity, requestId))
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventPlugin?.onDetachedFromEngine(binding)
        eventPlugin = null
        applicationContext = null
        isInitialized = false
        disposeAds()
    }

    private fun requireActivity(result: Result): Activity? {
        val activity = mActivity
        if (activity == null || activity.isFinishing || activity.isDestroyed) {
            result.error("NO_ACTIVITY", "华为广告调用失败：当前页面 Activity 不可用", null)
            return null
        }
        return activity
    }

    private fun requireAdId(call: MethodCall, result: Result): String? {
        val adId = call.argument<String>("androidId")?.trim()
        if (adId.isNullOrEmpty()) {
            result.error("INVALID_AD_ID", "华为广告位 ID 为空", null)
            return null
        }
        return adId
    }

    private fun requireRequestId(call: MethodCall, result: Result): String? {
        val requestId = call.argument<String>("requestId")?.trim()
        if (requestId.isNullOrEmpty()) {
            result.error("INVALID_REQUEST_ID", "华为广告请求 ID 为空", null)
            return null
        }
        return requestId
    }

    private fun requireInitialized(result: Result): Boolean {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "请先调用华为广告 initAd", null)
            return false
        }
        return true
    }

    private fun disposeAds() {
        RewardVideoAd.dispose()
        InterstitialAd.dispose()
    }
}
