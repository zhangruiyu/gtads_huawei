package com.huazi.gtads_huawei.rewardvideoad

import android.annotation.SuppressLint
import android.app.Activity
import com.huawei.hms.ads.AdParam
import com.huawei.hms.ads.reward.Reward
import com.huawei.hms.ads.reward.RewardAd
import com.huawei.hms.ads.reward.RewardAdLoadListener
import com.huawei.hms.ads.reward.RewardAdStatusListener
import com.huawei.hms.ads.reward.RewardVerifyConfig
import com.huazi.gtads_huawei.FlutterHuaweiAdEventPlugin
import com.huazi.gtads_huawei.LogUtil


@SuppressLint("StaticFieldLeak")
object RewardVideoAd {
    private val TAG = "RewardVideoAd"

    private lateinit var context: Activity
    private var rewardVideoAD: RewardAd? = null

    private var codeId: String? = null
    private var userID: String = ""
    private var rewardName: String = ""
    private var rewardAmount: Int = 0
    private var customData: String = ""


    fun init(context: Activity, params: Map<*, *>) {
        RewardVideoAd.context = context
        codeId = params["androidId"] as String
        userID = params["userID"] as String
        rewardName = params["rewardName"] as String
        rewardAmount = params["rewardAmount"] as Int
        customData = params["customData"] as String
        loadRewardVideoAd()
    }

    private fun loadRewardVideoAd() {
        rewardVideoAD = RewardAd(context, codeId)
        val listener: RewardAdLoadListener = object : RewardAdLoadListener() {
            override fun onRewardedLoaded() {
                // 激励广告加载成功
                LogUtil.e("$TAG  激励广告视频素材缓存成功")
                var map: MutableMap<String, Any?> =
                    mutableMapOf("adType" to "rewardAd", "onAdMethod" to "onReady")
                FlutterHuaweiAdEventPlugin.sendContent(map)
            }

            override fun onRewardAdFailedToLoad(errorCode: Int) {
                // 激励广告加载失败
            }
        }
        // 设置自定义数据
        val config = RewardVerifyConfig.Builder().setData(customData)
            .setUserId(userID)
            .build()
        rewardVideoAD?.setRewardVerifyConfig(config)
        rewardVideoAD?.loadAd(AdParam.Builder().build(), listener)
    }

    fun showAd() {
        if (rewardVideoAD == null) {
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "rewardAd", "onAdMethod" to "onUnReady")
            FlutterHuaweiAdEventPlugin.sendContent(map)
            return
        }
        rewardVideoAD?.show(context, rewardVideoADListener)

    }

    private var rewardVideoADListener = object : RewardAdStatusListener() {

        override fun onRewardAdOpened() {
            LogUtil.e("$TAG  激励视频广告页面展示")
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "rewardAd", "onAdMethod" to "onShow")
            FlutterHuaweiAdEventPlugin.sendContent(map)
        }

        override fun onRewarded(reward: Reward) {
            LogUtil.e("$TAG  激励视频广告激励发放 amount: ${reward.amount} name: ${reward.name}")

            var map: MutableMap<String, Any?> = mutableMapOf(
                "adType" to "rewardAd",
                "onAdMethod" to "onVerify",
                "rewardName" to rewardName,
                "rewardAmount" to rewardAmount
            )
            FlutterHuaweiAdEventPlugin.sendContent(map)
        }


        override fun onRewardAdClosed() {
            LogUtil.e("$TAG  激励视频广告被关闭")
            var map: MutableMap<String, Any?> =
                mutableMapOf("adType" to "rewardAd", "onAdMethod" to "onClose")
            FlutterHuaweiAdEventPlugin.sendContent(map)
            rewardVideoAD = null
        }

        override fun onRewardAdFailedToShow(errorCode: Int) {
            LogUtil.e("$TAG  广告流程出错 $errorCode")
            var map: MutableMap<String, Any?> = mutableMapOf(
                "adType" to "rewardAd",
                "onAdMethod" to "onFail",
                "code" to errorCode,
            )
            FlutterHuaweiAdEventPlugin.sendContent(map)
        }

    }
}