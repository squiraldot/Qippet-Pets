package com.squiraldot.qippet_pets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class PetTapAnimationTest {
    @Test
    fun selectionReturnsAnimationAtRequestedIndex() {
        val animations = PetTapAnimationCatalog.forPet("cat", frameNames("cat", "tap_happy") +
            frameNames("cat", "tap_spin"))

        assertEquals("tap_happy", PetTapAnimationCatalog.select(animations, 0)?.name)
        assertEquals("tap_spin", PetTapAnimationCatalog.select(animations, 1)?.name)
        assertEquals("tap_happy", PetTapAnimationCatalog.select(animations, 2)?.name)
        assertNull(PetTapAnimationCatalog.select(emptyList(), 0))
    }

    @Test
    fun discoversNewAnimationFromAssetsWithoutChangingCatalogCode() {
        val names = frameNames("bunny", "tap_happy") + frameNames("bunny", "tap_wave")
        val animations = PetTapAnimationCatalog.forPet("bunny", names)

        assertEquals(listOf("tap_happy", "tap_wave"), animations.map { it.name })
        assertEquals(
            listOf(
                "pet_bunny_tap_wave_01",
                "pet_bunny_tap_wave_02",
                "pet_bunny_tap_wave_03",
                "pet_bunny_tap_wave_04",
                "pet_bunny_tap_wave_05",
            ),
            animations.last().frameResourceNames,
        )
    }

    @Test
    fun ignoresOtherPetsAndNonTapFrames() {
        val names = frameNames("cat", "tap_happy") +
            frameNames("dog", "tap_spin") +
            listOf("pet_cat_idle_01", "pet_cat_tap_spin_extra.png")
        val animations = PetTapAnimationCatalog.forPet("cat", names)

        assertEquals(listOf("tap_happy"), animations.map { it.name })
    }

    @Test
    fun playbackPreservesFrameOrderAndHonorsTwoSecondLimit() {
        val animation = PetTapAnimation(
            name = "long",
            frameResourceNames = (1..30).map { "frame_$it" },
            frameDelayMs = 120L,
        )

        assertEquals(
            (1..16).map { "frame_$it" },
            PetTapAnimationCatalog.playbackFrames(animation),
        )
    }

    @Test
    fun playbackRejectsInvalidDelaysAndHonorsShorterDuration() {
        val frames = listOf("one", "two", "three")
        assertEquals(
            listOf("one", "two"),
            PetTapAnimationCatalog.playbackFrames(
                PetTapAnimation("short", frames, 120L),
                maxDurationMs = 240L,
            ),
        )
        assertEquals(
            emptyList<String>(),
            PetTapAnimationCatalog.playbackFrames(
                PetTapAnimation("invalid", frames, 0L),
            ),
        )
    }

    private fun frameNames(petId: String, animation: String): List<String> =
        (1..5).map { "pet_${petId}_${animation}_${it.toString().padStart(2, '0')}" }
}
