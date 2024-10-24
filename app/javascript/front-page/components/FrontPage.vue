<template lang="pug">
div
  .news-app-wrapper
    .container-fluid#top
      .row
        .col-sm-5.col-md-4.col-lg-3(v-show="loaded && wideLayout")
          .top-fixed.top-fixed--f1#sidebar(style="margin-top: 60px; overflow: auto !important")
            SideComponents
        .col-sm-7.col-md-8.col-lg-6
          a#top
          NewsItemWall(
            default-order="hot_score"
            sort-options="no_best"
            style="padding-left: 1rem, padding-right: 1rem"
            :fullLayout="!isMobile"
            :heldenUrl='heldenUrl'
          )
          div(ref='intersectionObsEl')
        .col-lg-3.visible-lg
          Subscribe
          Jobs(v-if="showJobs")
          Events
          .panel.panel-default.mt-2(style="position: sticky; top: 85px")
            .panel-body
              .row
                .col-xs-6(v-for="[key, path] in Object.entries(paths)")
                  .footer-item
                    a(:href="path" target= "_blank")
                      | {{ key }}
                .col-xs-6
                  .footer-item
                    a(href="/" style="color: #555")
                      | HRfilter.de&nbsp;
                    | &copy;&nbsp;{{ year }}



        template(v-if="loaded")
          SearchBar(ref="searchBar")
          a.btn.btn-primary.back-to-top(href="#top")
            i.fa.fa-chevron-up
</template>

<script setup lang="ts">
import NewsItemWall from "./NewsItemWall.vue"
import SearchBar from "./SearchBar.vue"
import SideComponents from "./SideComponents.vue"
import Jobs from "./Jobs.vue"
import Events from "./Events.vue"
import Subscribe from "./Subscribe.vue"
import { ref, onMounted } from "vue"

import { loadAll, loaded } from "@/front-page/data"
import { wideLayout, isMobile } from "@/utils/device"
import { autoload } from "@/front-page/newsItemPaginator"

defineProps({
  logo: { type: String },
  showJobs: { type: Boolean },
  paths: { type: Object, required: true },
  twitter: { type: String, default: "" },
  year: { type: Number, required: true },
  heldenUrl: { type: String, required: false },
})

const intersectionObsEl = ref(null)

onMounted(() => {
  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      console.log("intersecting")
      autoload()
    }
  })
  if (intersectionObsEl.value) {
    observer.observe(intersectionObsEl.value)
  }
  loadAll()
})
</script>

<style scoped>
.scrollable {
  overflow-y: scroll !important;
  max-height: 100vh;
}

::-webkit-scrollbar {
  display: none;
}

.header {
  color: #5f6368;
  margin: 10.5px 0;
}

.header i:hover {
  color: #2780e3;
}

.back-to-top {
  border-radius: 5px;
  position: fixed;
  right: 15px;
  background-color: #2780e3;
  border: none;
  z-index: 100;
  opacity: 0.7;
}

.footer-item {
  padding: 3px;
}

.row {
  display: flex;
  flex-wrap: wrap;
}

.row > [class*="col-"] {
  display: flex;
  flex-direction: column;
}
#top {
  scroll-behavior: smooth;
  scroll-margin-top: 100px;
}
</style>
