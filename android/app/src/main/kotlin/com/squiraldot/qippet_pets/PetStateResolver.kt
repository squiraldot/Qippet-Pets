package com.squiraldot.qippet_pets

import java.time.LocalTime
import java.time.format.DateTimeParseException

enum class PetState {
    AWAKE,
    SLEEPING,
}

/**
 * Resolves the pet's scheduled state using local wall-clock times.
 *
 * The sleep boundary is inclusive and the wake boundary is exclusive.
 * Equal sleep and wake times disable scheduled sleep.
 */
class PetStateResolver(
    private val now: LocalTime,
    private val sleepTime: String,
    private val wakeTime: String,
) {
    fun resolve(): PetState {
        val sleep = parseTime(sleepTime) ?: return PetState.AWAKE
        val wake = parseTime(wakeTime) ?: return PetState.AWAKE

        if (sleep == wake) return PetState.AWAKE

        val isSleeping = if (sleep < wake) {
            now >= sleep && now < wake
        } else {
            now >= sleep || now < wake
        }
        return if (isSleeping) PetState.SLEEPING else PetState.AWAKE
    }

    private fun parseTime(value: String): LocalTime? = try {
        LocalTime.parse(value)
    } catch (_: DateTimeParseException) {
        null
    }
}
