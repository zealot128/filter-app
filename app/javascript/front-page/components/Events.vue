<template lang="pug">
.card(v-if="loaded")
  .card-header
    strong Kommende Veranstaltungen
  .card-body
    .event-item(v-for="event in events")
      a(:href="event.url" rel="noopener" target="_blank")
        img.event-image(width="100%" :src="event.image" loading="lazy" alt="Upcoming event")
      .event-content
        h6
          a(:href="event.url" rel="noopener" target="_blank")
            | {{ event.title }}
        p.text-muted.small {{ event.from }}
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
.event-item {
  margin-bottom: 1rem;
  border-bottom: 1px solid #eee;
  padding-bottom: 1rem;
}

.event-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.event-image {
  border-radius: 0.375rem;
  margin-bottom: 0.5rem;
}

.event-content {
  text-align: center;
}

.event-content h6 {
  margin-bottom: 0.25rem;
}

.event-content p {
  margin-bottom: 0;
}
</style>
