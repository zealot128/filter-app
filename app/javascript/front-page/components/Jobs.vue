<template lang="pug">
.panel.panel-default(v-if="loaded")
  .panel-heading
    h3.panel-title
      | HR-Stellenanzeigen
  .panel-body
    .job(v-for="job in jobs", :key="job.id")
      a(:href="job.url" rel="noopener" target="_blank")
        | {{ job.title }}
        |
        i.text-muted
          | {{ job.company_name }}
  .panel-footer
    h5(style="margin: 0; margin-bottom: 1rem; text-align: center") Alle Stellen finden Sie aktuell auf
    a(href="https://www.empfehlungsbund.de/jobs/search?utf8=%E2%9C%93&q=HR+Personal&position=" target="_blank")
      img.img-responsive.center-block(:src="empfehlungsbundLogo")
</template>

<script lang="ts" setup>
import { onMounted, ref } from "vue"
import empfehlungsbundLogo from "../../../assets/images/Empfehlungsbund.png"

const shuffle = (a: any[]) => {
  var j, x, i
  for (i = a.length - 1; i > 0; i--) {
    j = Math.floor(Math.random() * (i + 1))
    x = a[i]
    a[i] = a[j]
    a[j] = x
  }
  return a
}

const jobs = ref<any[]>([])
const loaded = ref(false)
onMounted(() => {
  fetch(`/jobs`)
    .then((stream) => stream.json())
    .then((data) => {
      jobs.value = shuffle(data).slice(0, 5)
      loaded.value = true
    })
    .catch((error) => console.error(error))
})
</script>

<style scoped>
.panel-header {
  padding-right: 5px;
  padding-left: 5px;
  min-height: 90px;
  background-color: #f8f9fa;
}

.panel-footer {
  background-color: #f8f9fa;
}

.label {
  font-size: 12px;
}

.job {
  margin-bottom: 10px;
}

.panel {
  margin-top: 10px;
}
</style>
