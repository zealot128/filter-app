<template lang="pug">
  div
    NewsItemWall(default-order="newest" sort-options="all" :fullLayout="false")
</template>

<script>
import NewsItemWall from '../front-page/components/NewsItemWall'
export default {
  components: {
    NewsItemWall,
  },
  props: {
    params: { type: Object, required: true },
  },
  created() {
    this.$store.commit("expand_params_based_on_data", this.params);
    this.$store.commit("set_size", document.body.clientWidth);
  }
}
</script>
