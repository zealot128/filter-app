<template lang="pug">
div
  filter-box(title="Kategorien" v-model="selectedCategories" :items="categories")
    template(v-slot:default="{item}")
      span
        | {{ item.name }}
      img.category-thumb(:src="item.logo.thumb" loading="lazy" v-if='item.logo')

  filter-box(title="Trends" v-model="selectedTrends" :items="trends")
</template>

<script setup lang="ts">
import FilterBox from "./FilterBox.vue"
import { categories, trends } from "@/front-page/data"
import { chosenCat, chosenTrends } from "@/front-page/filter"
import { computed } from "vue"

const selectedCategories = computed({
  get() {
    return chosenCat.value.map((id) => categories.value.find((c) => c.id == id))
  },
  set(value: any[]) {
    chosenCat.value = value.map((e) => e.id)
  },
})
const selectedTrends = computed({
  get() {
    return chosenTrends.value.map((id) => trends.value.find((c) => c.slug == id))
  },
  set(value) {
    chosenTrends.value = value.map((e) => e.slug)
  },
})
</script>
