package com.huazi.gtads_huawei

import com.huawei.hms.ads.AdParam

internal object HuaweiAdError {
    fun message(action: String, errorCode: Int): String {
        return "$action(code=$errorCode)：${reason(errorCode)}"
    }

    internal fun reason(errorCode: Int): String {
        return when (errorCode) {
            AdParam.ErrorCode.INNER -> "SDK 内部错误"
            AdParam.ErrorCode.INVALID_REQUEST -> "广告请求无效，请检查广告位 ID 和请求参数"
            AdParam.ErrorCode.NETWORK_ERROR -> "网络连接失败"
            AdParam.ErrorCode.NO_AD -> "请求成功，但当前暂无可用广告"
            AdParam.ErrorCode.AD_LOADING -> "广告正在加载，请勿重复请求"
            AdParam.ErrorCode.LOW_API -> "设备上的广告服务 API 版本过低"
            AdParam.ErrorCode.BANNER_AD_EXPIRE -> "广告已过期"
            AdParam.ErrorCode.BANNER_AD_CANCEL -> "广告加载任务已取消"
            AdParam.ErrorCode.HMS_NOT_SUPPORT_SET_APP -> "设备 HMS Core 版本过低"
            else -> "未知错误"
        }
    }
}
