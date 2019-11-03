<template>
  <div v-show='trends.length > 0' class='panel panel-default'>
    <h3 class='text-center mt-0'>{{ title }}</h3>
    <div ref='canvas' class='word-cloud--html-canvas' :style='{height: height + "px"}'></div>
  </div>
</template>

<script>
import Wordcloud from './../../../vendor/assets/javascripts/wordcloud_fork.js'
import _max from 'lodash/max'

export default {
  components: {},
  props: {
    trends: { type: Array, required: true },
    title: { type: String, required: true }
  },
  data() {
    return {}
  },
  computed: {
    list() {
      return this.trends.map(t => ([t.name, t.count, t.slug]));
    },
    height() {
      if (this.trends.length < 10) {
        return 120
      } else if (this.trends.length < 20) {
        return 200
      } else {
        return 300
      }
    }
  },
  mounted() {
    if (this.trends.length === 0) {
      return
    }
    this.createCloud()
  },
  methods: {
    createCloud() {
      const el = this.$refs.canvas
      const max = _max(this.trends.map(e => e.count))
      Wordcloud(el, {
        list: this.list,
        gridSize: 13,
        createTextElement(item) {
          const w = document.createElement('a')
          const slug = item[2]
          w.href = `/trends/${slug}`
          w.target = "_blank"
          return w
        },
        color(word, weight, _fontSize, _distance, _theta) {
          const percent = weight * 100 / max
          return `hsl(233, ${80 - (percent * 0.5)}%, ${90 - percent * 0.8}%)`;
        },
        shape: 'triangle-forward',
        weightFactor: 2,
      })
    }
  },
}
</script>

<style scoped>
.word-cloud--html-canvas {
  margin-bottom: 25px;
  width: auto;
  min-width: 300px;
}
.word-cloud--html-canvas >>> a {
  opacity: 0.8;
  transition: all 0.1s ease-out;
  cursor: pointer;
}
.word-cloud--html-canvas >>> a:hover {
  opacity: 1.0;
  text-decoration: none;
}
.panel {
  padding: 20px;
}
h3 {
  margin-top: 0
}
</style>
