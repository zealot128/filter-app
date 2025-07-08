<template lang="pug">
div
  NewsItemWall(default-order="newest" sort-options="all", :fullLayout="false")
</template>

<script lang="ts" setup>
import NewsItemWall from "@/front-page/components/NewsItemWall.vue"
import { setParamsBasedOnData } from "@/front-page/filter"
const props = defineProps({
  params: { type: Object, required: true },
})
//import { onMounted } from "vue"
setParamsBasedOnData(props.params)
</script>
