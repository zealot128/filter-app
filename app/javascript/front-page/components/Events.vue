<template lang="pug">
.event-wrapper(v-if="loaded")
  h5.section-title Kommende Veranstaltungen
  .panel.panel-default(v-for="event in events")
    a(:href="event.url" rel="noopener" target="_blank")
      img(width="100%" :src="event.image" loading="lazy" alt="Upcoming event")
    .panel-body
      h5
        a(:href="event.url" rel="noopener" target="_blank")
          | {{ event.title }}
      p  {{ event.from }}
</template>

<script lang='ts'>
export default {
  data() {
    return {
      events: [],
      loaded: false,
    }
  },
  methods: {
    async fetchEvents() {
      const stream = await fetch(`/events`)
      if (stream.status === 404) return

      const data =  stream.json()
      this.events = data;
      this.loaded = true;
    }
  },
  mounted() {
    this.fetchEvents()
  },
}
</script>

<style scoped>
.event-wrapper {
  background-color: #f5f5f5;
  border: 1px solid #ddd;
  /* text-align: center; */
  padding: 5px 10px;
}

.panel {
  margin: 10px 0px;
}

.panel-body {
  text-align: center;
}

.section-title {
  font-size: 17px;
}
</style>
