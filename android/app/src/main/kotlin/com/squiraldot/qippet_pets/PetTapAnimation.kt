package com.squiraldot.qippet_pets

/**
 * Animation definitions are data: frame names are discovered from drawable resources and
 * playback consumes only the ordered names and delay. Adding correctly named frame assets
 * (pet_<petId>_tap_<animation>_<NN>) automatically registers another tap animation.
 */
data class PetTapAnimation(
    val name: String,
    val frameResourceNames: List<String>,
    val frameDelayMs: Long,
)

object PetTapAnimationCatalog {
    const val DEFAULT_FRAME_DELAY_MS = 120L
    const val MAX_DURATION_MS = 2_000L

    fun forPet(
        petId: String,
        availableFrameResourceNames: Collection<String>,
        frameDelayMs: Long = DEFAULT_FRAME_DELAY_MS,
    ): List<PetTapAnimation> {
        val framePattern = Regex("^pet_${Regex.escape(petId)}_(tap_[a-z0-9_]+)_(\\d{2})$")
        return availableFrameResourceNames.mapNotNull { resourceName ->
            framePattern.matchEntire(resourceName)?.let { match ->
                match.groupValues[1] to (match.groupValues[2].toInt() to resourceName)
            }
        }.groupBy(
            keySelector = { it.first },
            valueTransform = { it.second },
        ).map { (animationName, frames) ->
            PetTapAnimation(
                name = animationName,
                frameResourceNames = frames.sortedBy { it.first }.map { it.second },
                frameDelayMs = frameDelayMs,
            )
        }.sortedBy { it.name }
    }

    fun select(animations: List<PetTapAnimation>, randomIndex: Int): PetTapAnimation? {
        if (animations.isEmpty()) return null
        return animations[Math.floorMod(randomIndex, animations.size)]
    }

    fun playbackFrames(
        animation: PetTapAnimation,
        maxDurationMs: Long = MAX_DURATION_MS,
    ): List<String> {
        if (animation.frameDelayMs <= 0L || maxDurationMs <= 0L) return emptyList()
        val allowedFrames = (maxDurationMs / animation.frameDelayMs)
            .coerceAtLeast(1L)
            .coerceAtMost(Int.MAX_VALUE.toLong())
            .toInt()
        return animation.frameResourceNames.take(allowedFrames)
    }
}
