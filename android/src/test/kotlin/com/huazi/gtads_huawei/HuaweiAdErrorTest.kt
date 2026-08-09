package com.huazi.gtads_huawei

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

internal class HuaweiAdErrorTest {
    @Test
    fun noAdError_explainsThatTheRequestSucceededWithoutInventory() {
        assertEquals("请求成功，但当前暂无可用广告", HuaweiAdError.reason(3))
    }

    @Test
    fun networkError_keepsTheNumericCodeInTheCallbackMessage() {
        val message = HuaweiAdError.message("激励广告加载失败", 2)

        assertTrue(message.contains("code=2"))
        assertTrue(message.contains("网络连接失败"))
    }

    @Test
    fun unknownError_keepsTheOriginalNumericCode() {
        assertEquals("广告加载失败(code=99)：未知错误", HuaweiAdError.message("广告加载失败", 99))
    }
}
