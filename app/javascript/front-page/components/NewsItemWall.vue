<template lang="pug">
.news-items--wall
  ul.nav.nav-tabs.nav-justified.mb-2(v-if="fullLayout")
    li.nav-item(v-for="mt in mediaTypes", :key="mt")
      a.nav-link(role="button" @click="selectMediaType(mt)" :class="{'active': mt == chosenMediaType }")
        span(style="display: inline-flex")
          | {{ typeTitle(mt) }}
          svg(fill="currentColor" style="margin-left: 5px" height="20px" width="20px" viewBox="0 0 24 24")
            path(:d="iconForType(mt)")

  .news-items--wrapper(class='d-flex flex-column gap-2')
    template(v-if="loading")
      NewsItem(v-for="ni in newsItemsLoading", :key="ni.id", :news-item="ni")
      Skeleton(v-for="i in 15", :key="i")
    template(v-else)
      NewsItem(v-for="(ni, idx) in newsItems", :key="ni.id" :news-item="ni")
      template(v-if="newsItems.length === 0")
        div(style="font-size: 5rem")
          i.fa.fa-exclamation-triangle
        h4 Leider gibt es keinen Artikel für ihre ausgewählte Suchmuster, bitte versuchen Sie nochmal mit einem neuen Muster.

  .text-center
    a.btn.btn-secondary(v-if="hasNextPage && !fullLayout" @click="loadNextPage()" style="margin-bottom: 30px")
      | Mehr
</template>

<script lang="ts" setup>
import NewsItem from "./NewsItem.vue"
import Skeleton from "./Skeleton.vue"
import json from "../icons.json"

import { mediaTypes } from "@/front-page/data"
import { chosenMediaType, setParamsBasedOnData } from "@/front-page/filter"

import { loadDataForParams, loadNextPage, handleHistory, order, refresh, newsItems, newsItemsLoading, loading, hasNextPage } from "@/front-page/newsItemPaginator"

const props = defineProps({
  defaultOrder: { type: String, default: () => "all_best" },
  perPage: { type: Number, default: 30 },
  sortOptions: { type: String, default: "few" },
  fullLayout: { type: Boolean, default: true },
})
import { onBeforeUnmount, onMounted } from "vue"

function typeTitle(type: string) {
  if (type === "FeedSource") return "Artikel"
  if (type === "") return "Alle"
  return type.replace("Source", "")
}
function iconForType(type: string) {
  return json[type] || ""
}

onMounted(() => {
  if ("scrollRestoration" in history) {
    history.scrollRestoration = "manual"
  }
  order.value = props.defaultOrder
  window.addEventListener("beforeunload", handleHistory)
  try {
    if (history.state && history.state.params) {
      setParamsBasedOnData(history.state.params)
      order.value = history.state.params.order
      if (!loading.value) {
        loadDataForParams()
      }
    } else {
      refresh()
    }
  } catch (error) {
    refresh()
  }
})
onBeforeUnmount(() => {
  window.removeEventListener("beforeunload", handleHistory)
})
function selectMediaType(mt: string) {
  if (chosenMediaType.value === mt) {
    chosenMediaType.value = ""
  } else {
    chosenMediaType.value = mt
  }
}
</script>

<style scoped>
.news-items--wall {
  position: relative;
  margin-top: 10px;
  min-height: 400px;
}
.news-items--wrapper >>> .news-item-panel {
  width: 100%;
}
.news-items--form {
  display: flex;
  justify-content: flex-start;
  margin: 10px;
}
.news-items--form .form-control {
  height: 32px;
  padding-top: 0;
  padding-bottom: 0;
}
</style>
