<template lang="pug">
  div
    filter-box(title="Kategorien" v-model="selectedCategories" :items="categories")
      template(v-slot:default="{item}")
        span
          | {{ item.name }}
        img.category-thumb(:src="item.logo.thumb" loading="lazy")

    filter-box(title="Medientyp" v-model="selectedMediatypes" :items="mediaTypes")
      template(v-slot:default="{item}")
        span
          | {{ typeTitle(item.id) }}
        svg.category-thumb(viewBox="0 0 24 24")
          path(fill="currentColor" :d="iconForType(item.id)")

    filter-box(title="Trends" v-model="selectedTrends" :items="trends")

</template>

<script>
import { mapState, mapGetters } from "vuex"
import FilterBox from "./FilterBox.vue"
import json from "../icons.json"

export default {
  components: { FilterBox },
  computed: {
    ...mapState(["mediaTypes", "categories", "trends"]),
    ...mapGetters(["typeTitle"]),
    selectedCategories: {
      get() {
        return this.$store.state.chosenCat.map((id) =>
          this.categories.find((c) => c.id == id)
        )
      },
      set(value) {
        this.$store.commit(
          "set_chosen_cat",
          value.map((e) => e.id)
        )
        this.$store.dispatch("build_params")
        this.$emit("select")
      },
    },
    selectedMediatypes: {
      get() {
        return this.$store.state.chosenTypes.map((id) =>
          this.mediaTypes.find((c) => c.id == id)
        )
      },
      set(value) {
        this.$store.commit(
          "set_chosen_type",
          value.map((e) => e.id)
        )
        this.$store.dispatch("build_params")
        this.$emit("select")
      },
    },
    selectedTrends: {
      get() {
        return this.$store.state.chosenTrends.map((id) =>
          this.trends.find((c) => c.slug == id)
        )
      },
      set(value) {
        this.$store.commit(
          "set_chosen_trend",
          value.map((e) => e.slug)
        )
        this.$store.dispatch("build_params")
        this.$emit("select")
      },
    },
  },
  methods: {
    iconForType(type) {
      return json[type]
    },
  },
}
</script>
