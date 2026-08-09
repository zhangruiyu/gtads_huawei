package com.huazi.gtads_huawei.rewardvideoad

import android.app.Activity
import com.huawei.hms.ads.AdParam
import com.huawei.hms.ads.reward.Reward
import com.huawei.hms.ads.reward.RewardAd
import com.huawei.hms.ads.reward.RewardAdLoadListener
import com.huawei.hms.ads.reward.RewardAdStatusListener
import com.huawei.hms.ads.reward.RewardVerifyConfig
import com.huazi.gtads_huawei.AdRequestState
import com.huazi.gtads_huawei.FlutterHuaweiAdEventPlugin
import com.huazi.gtads_huawei.HuaweiAdError
import com.huazi.gtads_huawei.LogUtil

object RewardVideoAd {
    private const val TAG = "RewardVideoAd"

    private data class RewardRequest(
        val requestId: String,
        val rewardName: String,
        val rewardAmount: Int
    )

    private val state = AdRequestState()
    private var rewardAd: RewardAd? = null
    private var activeRequest: RewardRequest? = null

    fun load(context: Activity, params: Map<*, *>, requestId: String): Boolean {
        val decision = state.beginLoad(requestId)
        if (decision == AdRequestState.LoadDecision.REJECT_BUSY) {
            sendFailure(requestId, AdParam.ErrorCode.AD_LOADING, "激励广告加载失败")
            return false
        }

        if (decision == AdRequestState.LoadDecision.REPLACE_LOADED) {
            destroyAdOnly()
        }

        val codeId = (params["androidId"] as? String)?.trim().orEmpty()
        val userId = params["userID"] as? String ?: ""
        val rewardName = params["rewardName"] as? String ?: ""
        val rewardAmount = params["rewardAmount"] as? Int ?: 0
        val customData = params["customData"] as? String ?: ""
        val request = RewardRequest(requestId, rewardName, rewardAmount)
        val ad = RewardAd(context.applicationContext, codeId)

        activeRequest = request
        rewardAd = ad
        ad.setRewardVerifyConfig(
            RewardVerifyConfig.Builder()
                .setData(customData)
                .setUserId(userId)
                .build()
        )
        ad.loadAd(AdParam.Builder().build(), object : RewardAdLoadListener() {
            override fun onRewardedLoaded() {
                if (!isCurrent(ad, requestId) || !state.markLoaded(requestId)) {
                    ad.destroy()
                    return
                }
                LogUtil.e("$TAG  激励广告视频素材缓存成功 requestId=$requestId")
                sendEvent(requestId, "onReady")
            }

            override fun onRewardAdFailedToLoad(errorCode: Int) {
                if (!isCurrent(ad, requestId)) {
                    ad.destroy()
                    return
                }
                clearCurrentAd()
                sendFailure(requestId, errorCode, "激励广告加载失败")
            }
        })
        return true
    }

    fun showAd(context: Activity, requestId: String): Boolean {
        val ad = rewardAd
        val request = activeRequest
        if (ad == null || request?.requestId != requestId || !ad.isLoaded ||
            !state.markShowing(requestId)
        ) {
            sendEvent(requestId, "onUnReady")
            LogUtil.e("$TAG  激励广告显示失败，广告未加载完成 requestId=$requestId")
            return false
        }

        return try {
            ad.show(context, createStatusListener(ad, request))
            true
        } catch (error: RuntimeException) {
            clearCurrentAd()
            sendFailure(requestId, AdParam.ErrorCode.INNER, "激励广告展示失败")
            false
        }
    }

    fun dispose() {
        destroyAdOnly()
        state.reset()
    }

    private fun createStatusListener(
        ad: RewardAd,
        request: RewardRequest
    ): RewardAdStatusListener {
        return object : RewardAdStatusListener() {
            override fun onRewardAdOpened() {
                if (!isCurrent(ad, request.requestId)) return
                LogUtil.e("$TAG  激励视频广告页面展示 requestId=${request.requestId}")
                sendEvent(request.requestId, "onShow")
            }

            override fun onRewarded(reward: Reward) {
                if (!isCurrent(ad, request.requestId)) return
                LogUtil.e(
                    "$TAG  激励视频广告激励发放 amount: ${reward.amount} " +
                        "name: ${reward.name} requestId=${request.requestId}"
                )
                FlutterHuaweiAdEventPlugin.sendContent(
                    mutableMapOf(
                        "adType" to "rewardAd",
                        "onAdMethod" to "onVerify",
                        "requestId" to request.requestId,
                        "rewardName" to request.rewardName,
                        "rewardAmount" to request.rewardAmount
                    )
                )
            }

            override fun onRewardAdClosed() {
                if (!isCurrent(ad, request.requestId)) return
                LogUtil.e("$TAG  激励视频广告被关闭 requestId=${request.requestId}")
                sendEvent(request.requestId, "onClose")
                clearCurrentAd()
            }

            override fun onRewardAdFailedToShow(errorCode: Int) {
                if (!isCurrent(ad, request.requestId)) return
                clearCurrentAd()
                sendFailure(request.requestId, errorCode, "激励广告展示失败")
            }
        }
    }

    private fun isCurrent(ad: RewardAd, requestId: String): Boolean {
        return rewardAd === ad && state.isCurrent(requestId)
    }

    private fun sendEvent(requestId: String, method: String) {
        FlutterHuaweiAdEventPlugin.sendContent(
            mutableMapOf(
                "adType" to "rewardAd",
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
                "adType" to "rewardAd",
                "onAdMethod" to "onFail",
                "requestId" to requestId,
                "code" to errorCode,
                "message" to message
            )
        )
    }

    private fun clearCurrentAd() {
        destroyAdOnly()
        state.reset()
    }

    private fun destroyAdOnly() {
        rewardAd?.destroy()
        rewardAd = null
        activeRequest = null
    }
}
