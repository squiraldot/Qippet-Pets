package com.squiraldot.qippet_pets

import org.junit.Assert.assertEquals
import org.junit.Test
import java.time.LocalTime

class PetStateResolverTest {
    @Test
    fun overnightWindowSleepsAcrossMidnight() {
        assertState("23:30", "22:00", "07:00", PetState.SLEEPING)
        assertState("03:15", "22:00", "07:00", PetState.SLEEPING)
        assertState("12:00", "22:00", "07:00", PetState.AWAKE)
    }

    @Test
    fun sameDayWindowSleepsOnlyInsideWindow() {
        assertState("14:00", "13:00", "17:00", PetState.SLEEPING)
        assertState("10:00", "13:00", "17:00", PetState.AWAKE)
        assertState("18:00", "13:00", "17:00", PetState.AWAKE)
    }

    @Test
    fun sleepBoundaryIsInclusiveAndWakeBoundaryIsExclusive() {
        assertState("22:00", "22:00", "07:00", PetState.SLEEPING)
        assertState("06:59", "22:00", "07:00", PetState.SLEEPING)
        assertState("07:00", "22:00", "07:00", PetState.AWAKE)
    }

    @Test
    fun identicalTimesDisableScheduledSleep() {
        assertState("23:00", "08:30", "08:30", PetState.AWAKE)
    }

    private fun assertState(
        now: String,
        sleep: String,
        wake: String,
        expected: PetState,
    ) {
        assertEquals(
            expected,
            PetStateResolver(LocalTime.parse(now), sleep, wake).resolve(),
        )
    }
}
