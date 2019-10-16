<template>
  <div class="panel panel-default news-item-panel">
    <div class="panel-heading">
      <h3 class="panel-title">
        <a
          :href="url"
          target="_blank"
          rel="noopener"
          :title="newsItem.title"
        >
          {{ newsItem.title | truncate(70)}}
        </a>
      </h3>
    </div>
    <div :class="{ 'panel-body': true, 'with-background': hasImage }">
      <div v-if="hasImage" class="background-frame">
        <img class="background" :src="newsItem.image.full_url" />
      </div>
      <div class="background-text">
        <p class="source"></p>
        <span>{{ newsItem.teaser }}</span>
      </div>
      <div class="fog-fade"></div>
    </div>
    <div class='panel-footer'>
      <span class='pull-right text-muted'> {{ date }}</span>
      <span class='source'>
        <img v-if='newsItem.source.logo' :src='newsItem.source.logo' width='16' height='16'/>
        <a title='newsItem.source.name' :href='newsItem.source.url'>
          {{newsItem.source.name | truncate(30) }}
        </a>
      </span>

    </div>
  </div>
</template>

<script>
import truncate from "utils/truncate-filter"

export default {
  filters: { truncate },
  props: {
    newsItem: { type: Object, required: true }
  },
  computed: {
    url() {
      return this.newsItem.url.split('?')[0]
    },
    date() {
      const d = new Date(Date.parse(this.newsItem.published_at))
      const today = new Date
      const month = ['jan', 'feb', 'mar', 'apr', 'mai', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dez'][d.getMonth()]
      let s = `${d.getDate()}. ${month}`
      if (d.getFullYear() !== today.getFullYear()) {
        s += " " + d.getFullYear()
      }
      return s
    },
    hasImage() {
      return this.newsItem.image && this.newsItem.image.full_url;
    }
  }
};
</script>

<style scoped>
.panel-footer {
  padding: 2px;
}
.panel-default.news-item-panel .panel-heading {
  height: 60px;
}
</style>
