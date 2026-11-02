package com.squiraldot.qippet_pets

import java.time.Clock
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZonedDateTime
import java.time.format.DateTimeParseException

enum class PetAlarmTransition {
    SLEEP,
    WAKE,
}

data class PetAlarmTrigger(
    val transition: PetAlarmTransition,
    val at: ZonedDateTime,
)

/**
 * Pure schedule math. The injected clock makes "now" deterministic in tests.
 *
 * LocalDateTime.atZone intentionally applies java.time's DST rules: a nonexistent wall time
 * moves forward by the gap, and an ambiguous wall time uses the earlier valid offset.
 */
class PetAlarmTimeCalculator(private val clock: Clock) {
    fun nextTrigger(sleepTime: String, wakeTime: String): PetAlarmTrigger? {
        val sleep = parse(sleepTime) ?: return null
        val wake = parse(wakeTime) ?: return null
        if (sleep == wake) return null

        val now = ZonedDateTime.now(clock)
        val state = PetStateResolver(now.toLocalTime(), sleepTime, wakeTime).resolve()
        val transition = if (state == PetState.SLEEPING) {
            PetAlarmTransition.WAKE
        } else {
            PetAlarmTransition.SLEEP
        }
        val targetTime = if (transition == PetAlarmTransition.WAKE) wake else sleep

        var occurrence = LocalDateTime.of(now.toLocalDate(), targetTime).atZone(now.zone)
        if (!occurrence.isAfter(now)) {
            occurrence = LocalDateTime.of(now.toLocalDate().plusDays(1), targetTime).atZone(now.zone)
        }
        return PetAlarmTrigger(transition, occurrence)
    }

    private fun parse(value: String): LocalTime? = try {
        LocalTime.parse(value)
    } catch (_: DateTimeParseException) {
        null
    }
}
