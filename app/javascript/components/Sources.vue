<template lang="pug">
  div
    NewsItemWall(default-order="newest" sort-options="all")
    SearchBar(v-bind:expand="true")
</template>

<script>
import NewsItemWall from '../front-page/components/NewsItemWall'
import SearchBar from '../front-page/components/SearchBar'

export default {
  components: {
    NewsItemWall,
    SearchBar
  },
  props: {
    params: { type: Object, required: true },
  },
  mounted() {
    this.$store.commit("expand_params_based_on_data", this.params);
  }
}
</script>