<template lang="pug">
div
  filter-box(title="Kategorien" v-model="selectedCategories" :items="categories")
    template(v-slot:default="{item}")
      span
        | {{ item.name }}
      img.category-thumb(:src="item.logo.thumb" loading="lazy" v-if='item.logo')

</template>

<script setup lang="ts">
import FilterBox from "./FilterBox.vue"
import { categories } from "@/front-page/data"
import { chosenCat } from "@/front-page/filter"
import { computed } from "vue"

const selectedCategories = computed({
  get() {
    return chosenCat.value.map((id) => categories.value.find((c) => c.id == id))
  },
  set(value: any[]) {
    chosenCat.value = value.map((e) => e.id)
  },
})
</script>
