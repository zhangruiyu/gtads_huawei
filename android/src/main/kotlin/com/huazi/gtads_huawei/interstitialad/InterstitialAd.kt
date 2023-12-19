package com.huazi.gtads_huawei.interstitialad

import android.annotation.SuppressLint
import android.app.Activity
import com.huawei.hms.ads.AdListener
import com.huawei.hms.ads.AdParam
import com.huawei.hms.ads.InterstitialAd
import com.huazi.gtads_huawei.FlutterHuaweiAdEventPlugin
import com.huazi.gtads_huawei.LogUtil

@SuppressLint("StaticFieldLeak")
object InterstitialAd {
    private val TAG = "InterstitialAd"

    private lateinit var context: Activity
    private var unifiedInterstitialAD: InterstitialAd? = null

    private var codeId: String? = null


    fun init(context: Activity, androidId: String) {
        this.context = context
        this.codeId = androidId
        loadInterstitialAD()
    }

    private fun loadInterstitialAD() {
        unifiedInterstitialAD = InterstitialAd(context)
        unifiedInterstitialAD?.adId = codeId
        unifiedInterstitialAD?.adListener = interstitialADListener
        // 加载插屏广告
        val adParam = AdParam.Builder().build()
        unifiedInterstitialAD?.loadAd(adParam)
    }

    fun showAd() {
        if (unifiedInterstitialAD == null) {
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "interactAd", "onAdMethod" to "onUnReady")
            FlutterHuaweiAdEventPlugin.sendContent(map)
            LogUtil.e("$TAG  插屏全屏视频广告显示失败，无广告")
            return
        }
        unifiedInterstitialAD?.show(context)
    }

    private var interstitialADListener = object : AdListener() {


        //插屏全屏视频广告展开时回调
        override fun onAdOpened() {
            LogUtil.e("$TAG  插屏全屏视频广告展开时回调")
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "interactAd", "onAdMethod" to "onShow")
            FlutterHuaweiAdEventPlugin.sendContent(map)
        }

        //插屏全屏视频广告曝光时回调
        override fun onAdImpression() {
            LogUtil.e("$TAG  插屏全屏视频广告曝光时回调")
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "interactAd", "onAdMethod" to "onExpose")
            FlutterHuaweiAdEventPlugin.sendContent(map)
        }

        //插屏全屏视频广告点击时回调
        override fun onAdClicked() {
            LogUtil.e("$TAG  插屏全屏视频广告点击时回调")
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "interactAd", "onAdMethod" to "onClick")
            FlutterHuaweiAdEventPlugin.sendContent(map)
        }

        //插屏全屏视频广告关闭时回调
        override fun onAdClosed() {
            LogUtil.e("$TAG  插屏全屏视频广告关闭时回调")
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "interactAd", "onAdMethod" to "onClose")
            FlutterHuaweiAdEventPlugin.sendContent(map)
            unifiedInterstitialAD = null
        }

        //	插屏全屏视频视频广告，渲染成功
        override fun onAdLoaded() {
            LogUtil.e("$TAG  插屏全屏视频视频广告，渲染成功")
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "interactAd", "onAdMethod" to "onReady")
            FlutterHuaweiAdEventPlugin.sendContent(map)
        }

        //插屏全屏视频视频广告，渲染失败
        override fun onAdFailed(errorCode: Int) {
            LogUtil.e("$TAG  插屏全屏视频视频广告，渲染失败 errorCode: $errorCode")
            var map: MutableMap<String, Any?> = mutableMapOf(
                "adType" to "interactAd",
                "onAdMethod" to "onFail",
                "code" to errorCode,
                "message" to "插屏全屏视频视频广告渲染失败"
            )
            FlutterHuaweiAdEventPlugin.sendContent(map)
            unifiedInterstitialAD = null
        }

    }


}