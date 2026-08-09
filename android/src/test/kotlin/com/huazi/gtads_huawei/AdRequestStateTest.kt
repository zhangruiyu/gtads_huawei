package com.huazi.gtads_huawei

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class AdRequestStateTest {
    @Test
    fun loadedAd_isReplacedWhenANewRequestStarts() {
        val state = AdRequestState()

        assertEquals(AdRequestState.LoadDecision.START, state.beginLoad("request-a"))
        assertTrue(state.markLoaded("request-a"))

        assertEquals(AdRequestState.LoadDecision.REPLACE_LOADED, state.beginLoad("request-b"))
        assertEquals("request-b", state.currentRequestId)
        assertEquals(AdRequestState.Phase.LOADING, state.phase)
    }

    @Test
    fun concurrentLoad_isRejectedWithoutReplacingTheActiveRequest() {
        val state = AdRequestState()

        assertEquals(AdRequestState.LoadDecision.START, state.beginLoad("request-a"))

        assertEquals(AdRequestState.LoadDecision.REJECT_BUSY, state.beginLoad("request-b"))
        assertEquals("request-a", state.currentRequestId)
        assertTrue(state.markLoaded("request-a"))
        assertFalse(state.markLoaded("request-b"))
    }

    @Test
    fun show_requiresTheMatchingLoadedRequest() {
        val state = AdRequestState()
        state.beginLoad("request-a")
        state.markLoaded("request-a")

        assertFalse(state.markShowing("request-b"))
        assertTrue(state.markShowing("request-a"))
        assertEquals(AdRequestState.Phase.SHOWING, state.phase)
    }

    @Test
    fun reset_clearsAnInFlightRequest() {
        val state = AdRequestState()
        state.beginLoad("request-a")

        state.reset()

        assertEquals(AdRequestState.Phase.IDLE, state.phase)
        assertEquals(null, state.currentRequestId)
        assertEquals(AdRequestState.LoadDecision.START, state.beginLoad("request-b"))
    }
}
