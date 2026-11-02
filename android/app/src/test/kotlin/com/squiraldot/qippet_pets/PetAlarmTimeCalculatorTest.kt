package com.squiraldot.qippet_pets

import org.junit.Assert.assertEquals
import org.junit.Test
import java.time.Clock
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId

class PetAlarmTimeCalculatorTest {
    @Test
    fun overnightWindowSchedulesWakeAfterMidnight() {
        val zone = ZoneId.of("Asia/Kolkata")
        val clock = Clock.fixed(Instant.parse("2026-04-12T17:30:00Z"), zone)

        val trigger = PetAlarmTimeCalculator(clock).nextTrigger("22:00", "07:00")

        assertEquals(PetAlarmTransition.WAKE, trigger?.transition)
        assertEquals(LocalDate.parse("2026-04-13"), trigger?.at?.toLocalDate())
        assertEquals(LocalTime.of(7, 0), trigger?.at?.toLocalTime())
    }

    @Test
    fun timesAlreadyPassedTodayScheduleNextSleepTomorrow() {
        val zone = ZoneId.of("Asia/Kolkata")
        val clock = Clock.fixed(Instant.parse("2026-04-12T09:30:00Z"), zone)

        val trigger = PetAlarmTimeCalculator(clock).nextTrigger("08:00", "09:00")

        assertEquals(PetAlarmTransition.SLEEP, trigger?.transition)
        assertEquals(LocalDate.parse("2026-04-13"), trigger?.at?.toLocalDate())
        assertEquals(LocalTime.of(8, 0), trigger?.at?.toLocalTime())
    }

    @Test
    fun nonexistentDstWakeTimeMovesForwardAcrossSpringGap() {
        val zone = ZoneId.of("America/New_York")
        val clock = Clock.fixed(Instant.parse("2026-03-08T06:30:00Z"), zone)

        val trigger = PetAlarmTimeCalculator(clock).nextTrigger("22:00", "02:30")

        assertEquals(PetAlarmTransition.WAKE, trigger?.transition)
        assertEquals(LocalTime.of(3, 30), trigger?.at?.toLocalTime())
        assertEquals(Instant.parse("2026-03-08T07:30:00Z"), trigger?.at?.toInstant())
    }

    @Test
    fun identicalTimesDisableTransitions() {
        val clock = Clock.fixed(
            Instant.parse("2026-04-12T09:30:00Z"),
            ZoneId.of("UTC"),
        )

        assertEquals(null, PetAlarmTimeCalculator(clock).nextTrigger("08:00", "08:00"))
    }
}
