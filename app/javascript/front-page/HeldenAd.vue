<template lang="pug">
div
  .panel.panel-primary
    .panel-heading
      div(style='display: flex; justify-content: space-between')
        span
          |Fahrrad/E-Bike Vollkasko Versicherung von helden.de
        span.badge.badge-dark Werbung
    a(:href='heldenUrl' @click='trackClick')
      img(:src='image' alt='helden.de E-Bike und Fahrradschutz Banner.')

    .bottom
      div
        a.btn.btn-primary(:href='heldenUrl' @click='trackClick' @click.middle='trackClick')
          |Jetzt Rabatt sichern
        br
        small mit Helden Code SWIE2 dauerhaft einen Monatsbeitrag sparen
      ul.list-check
        li Entschädigung bei Diebstahl des Fahrrads &amp; Zubehör
        li Übernahme Reparaturkosten inkl. Verschleißkosten
        li Radsport- & Downhillfahrten sind mitversichert
        li Schutzbrief für Pannen- & Unfallhilfe inklusive
        li 0 € Selbstbeteiligung im Schadensfall

</template>

<script lang="ts">
import Vue from "vue"
import ahoy from 'utils/ahoy'

import image from "../../assets/images/fahrrad-filter/heldende.jpg"

export default Vue.extend({
  props: {
    heldenUrl: { type: String, required: true },
  },
  data() {
    return { image }
  },
  methods: {
    trackClick() {
      ahoy.track('helden_click')
    }
  }
})
</script>

<style scoped>
img {
  width: 100%;
  aspect-ratio: 31 / 6;
}
.panel {
  border-radius: 15px;
  overflow: hidden;
}

.list-check li:before {
  content: "✔";
  color: #5cb85c;
  margin-right: 10px;
}
.list-check {
  max-width: fit-content;
  list-style: none;
  padding-left: 0;

  font-size: 1.5rem;
  flex-grow: 1;
}
.bottom {
  display: flex;
  justify-content: space-around;
  width: 100%;
  gap: 15px;
  align-items: center;
  padding: 15px;
}
.btn-primary {
  border-radius: 15px;
  box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.2);
}
@media (max-width: 550px) {
  .list-check {
    font-size: 1.3rem;
  }
  .bottom {
    flex-direction: column-reverse;
  }
}
</style>
