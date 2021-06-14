<template lang="pug">
  agile(
    v-if="loaded"
    :options="myOptions"
    :autoplay="true"
    :autoplaySpeed="5000"
    :infinite="true"
    :dots="false"
    :pauseOnHover="true"
  )
    div.slide(v-for="job in jobs", :key="job.id")
      .arbeit-panel
        .panel-header
          .text-center
            a(target="_blank" :href="job.url" style="color: black")
              h4 {{ job.title }}
        .background-frame
          img.job-img(:src="job.company_logo_big" loading="lazy")
          .text-center
            b {{ job.company_name }}
        .panel-body
          .wrapper.tag-wrapper
            template(v-for="v in job.variants")
              span.label.label-default.job-label(v-for="loc in v.locations") {{ loc.ort }}
            template(v-for="i in 5")
              span.label.label-primary.job-label {{ removeTags(job.tags)[i] }}
        .panel-footer
          .row.text-center
            a.btn.btn-primary.btn-job-offer(:href="job.url" target="_blank")
              |Zum Stellenangebot
    div.slide
      .arbeit-panel
        .panel-header
          .text-center
            h4(style="color: black") Nichts gefunden?
        .background-frame
        .panel-body.last-job-body
          h5 Alle Stellen finden Sie aktuell auf
          img.img-responsive.center-block(:src="empfehlungsbundLogo")
          .wrapper.tag-wrapper
        .panel-footer
          .row.text-center
            a.btn.btn-primary.btn-job-offer(href="https://www.empfehlungsbund.de/jobs/search?utf8=%E2%9C%93&q=HR+Personal&position=" target="_blank")
              |www.empfehlungsbund.de


    template(slot="prevButton")
      i.fa.fa-chevron-left
    template(slot="nextButton")
      i.fa.fa-chevron-right

</template>

<script>
import { VueAgile } from 'vue-agile';
import Empfehlungsbund from '../../../assets/images/Empfehlungsbund.png'

export default {
  data() {
    return {
      jobs: [],
      loaded: false,
      myOptions: {
        navButtons: false,
        responsive: [
          {
            breakpoint: 768,
            settings: {
              slidesToShow: 2,
              centerMode: true,
              navButtons: true,
            }
          },
          {
            breakpoint: 900,
            settings: {
              slidesToShow: 3,
              centerMode: true,
              navButtons: true,
            }
          }
        ]
      },
    }
  },
  methods: {
    removeTags(tags) {
      i = tags.indexOf('m/w');
      if(i > -1) {
        tags.splice(i, 1);
      }
      return tags;
    },
  },
  mounted() {
    fetch(`/jobs`)
        .then(stream => stream.json())
        .then(data => {
          this.jobs = data;
          this.loaded = true;
          this.$nextTick(() => {
          })
        })
        .catch(error => console.error(error));
  },
  components: {
    agile: VueAgile,
  },
  computed: {
    empfehlungsbundLogo() {
      return Empfehlungsbund;
    },
  }
}
</script>


<style scoped>
.arbeit-panel {
  display: flex;
  flex-flow: column wrap;
  border: 1px solid #dadce0;
  margin: 0.5rem;
}

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

.last-job-body {
 min-height: 192px;
}

</style>
