package com.huazi.gtads_huawei

internal class AdRequestState {
    enum class Phase {
        IDLE,
        LOADING,
        LOADED,
        SHOWING
    }

    enum class LoadDecision {
        START,
        REPLACE_LOADED,
        REJECT_BUSY
    }

    var phase: Phase = Phase.IDLE
        private set

    var currentRequestId: String? = null
        private set

    fun beginLoad(requestId: String): LoadDecision {
        return when (phase) {
            Phase.LOADING, Phase.SHOWING -> LoadDecision.REJECT_BUSY
            Phase.IDLE -> {
                currentRequestId = requestId
                phase = Phase.LOADING
                LoadDecision.START
            }
            Phase.LOADED -> {
                currentRequestId = requestId
                phase = Phase.LOADING
                LoadDecision.REPLACE_LOADED
            }
        }
    }

    fun markLoaded(requestId: String): Boolean {
        if (phase != Phase.LOADING || currentRequestId != requestId) return false
        phase = Phase.LOADED
        return true
    }

    fun markShowing(requestId: String): Boolean {
        if (phase != Phase.LOADED || currentRequestId != requestId) return false
        phase = Phase.SHOWING
        return true
    }

    fun isCurrent(requestId: String): Boolean = currentRequestId == requestId

    fun reset() {
        currentRequestId = null
        phase = Phase.IDLE
    }
}
