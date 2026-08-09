package com.huazi.gtads_huawei.interstitialad

import android.app.Activity
import com.huawei.hms.ads.AdListener
import com.huawei.hms.ads.AdParam
import com.huawei.hms.ads.InterstitialAd
import com.huazi.gtads_huawei.AdRequestState
import com.huazi.gtads_huawei.FlutterHuaweiAdEventPlugin
import com.huazi.gtads_huawei.HuaweiAdError
import com.huazi.gtads_huawei.LogUtil

object InterstitialAd {
    private const val TAG = "InterstitialAd"

    private val state = AdRequestState()
    private var interstitialAd: InterstitialAd? = null

    fun load(context: Activity, androidId: String, requestId: String): Boolean {
        val decision = state.beginLoad(requestId)
        if (decision == AdRequestState.LoadDecision.REJECT_BUSY) {
            sendFailure(requestId, AdParam.ErrorCode.AD_LOADING, "插屏广告加载失败")
            return false
        }

        if (decision == AdRequestState.LoadDecision.REPLACE_LOADED) {
            clearAdOnly()
        }

        val ad = InterstitialAd(context.applicationContext)
        interstitialAd = ad
        ad.adId = androidId
        ad.adListener = createAdListener(ad, requestId)
        ad.loadAd(AdParam.Builder().build())
        return true
    }

    fun showAd(context: Activity, requestId: String): Boolean {
        val ad = interstitialAd
        if (ad == null || !ad.isLoaded || !state.markShowing(requestId)) {
            sendEvent(requestId, "onUnReady")
            LogUtil.e("$TAG  插屏广告显示失败，广告未加载完成 requestId=$requestId")
            return false
        }

        return try {
            ad.show(context)
            true
        } catch (error: RuntimeException) {
            clearCurrentAd()
            sendFailure(requestId, AdParam.ErrorCode.INNER, "插屏广告展示失败")
            false
        }
    }

    fun dispose() {
        clearAdOnly()
        state.reset()
    }

    private fun createAdListener(ad: InterstitialAd, requestId: String): AdListener {
        return object : AdListener() {
            override fun onAdOpened() {
                if (!isCurrent(ad, requestId)) return
                LogUtil.e("$TAG  插屏广告展开 requestId=$requestId")
                sendEvent(requestId, "onShow")
            }

            override fun onAdImpression() {
                if (!isCurrent(ad, requestId)) return
                LogUtil.e("$TAG  插屏广告曝光 requestId=$requestId")
                sendEvent(requestId, "onExpose")
            }

            override fun onAdClicked() {
                if (!isCurrent(ad, requestId)) return
                LogUtil.e("$TAG  插屏广告点击 requestId=$requestId")
                sendEvent(requestId, "onClick")
            }

            override fun onAdClosed() {
                if (!isCurrent(ad, requestId)) return
                LogUtil.e("$TAG  插屏广告关闭 requestId=$requestId")
                sendEvent(requestId, "onClose")
                clearCurrentAd()
            }

            override fun onAdLoaded() {
                if (!isCurrent(ad, requestId) || !state.markLoaded(requestId)) return
                LogUtil.e("$TAG  插屏广告加载成功 requestId=$requestId")
                sendEvent(requestId, "onReady")
            }

            override fun onAdFailed(errorCode: Int) {
                if (!isCurrent(ad, requestId)) return
                clearCurrentAd()
                sendFailure(requestId, errorCode, "插屏广告加载失败")
            }
        }
    }

    private fun isCurrent(ad: InterstitialAd, requestId: String): Boolean {
        return interstitialAd === ad && state.isCurrent(requestId)
    }

    private fun sendEvent(requestId: String, method: String) {
        FlutterHuaweiAdEventPlugin.sendContent(
            mutableMapOf(
                "adType" to "interactAd",
                "onAdMethod" to method,
                "requestId" to requestId
            )
        )
    }

    private fun sendFailure(requestId: String, errorCode: Int, action: String) {
        val message = HuaweiAdError.message(action, errorCode)
        LogUtil.e("$TAG  $message requestId=$requestId")
        FlutterHuaweiAdEventPlugin.sendContent(
            mutableMapOf(
                "adType" to "interactAd",
                "onAdMethod" to "onFail",
                "requestId" to requestId,
                "code" to errorCode,
                "message" to message
            )
        )
    }

    private fun clearCurrentAd() {
        clearAdOnly()
        state.reset()
    }

    private fun clearAdOnly() {
        interstitialAd?.adListener = null
        interstitialAd = null
    }
}
