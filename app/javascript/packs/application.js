import Automount from 'utils/automount'
// import store from "../front-page/store";
import App from "front-page/components/FrontPage.vue";

document.addEventListener('DOMContentLoaded', () => {
  Automount('trend-page', () => import("components/TrendPage.vue"))
  Automount('trend-flame-graph', () => import("components/TrendFlameGraph.vue"))
  Automount('sources', () => import("components/Sources.vue"))
  Automount('embed-head', () => import("components/EmbedHead.vue"))
  Automount('front-page-app', App);
})

import $ from 'jquery'

window.$ = $
window.jQuery = $

$(document).on('mousedown', '[data-proxy]', (e) => {
 if (e.target && e.target.dataset.proxy) {
   e.target.href = e.target.dataset.proxy;
  }
});

import Highcharts from '@/utils/highcharts'

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.js-chart').forEach((el) => {
    const data = JSON.parse(el.dataset.chart || el.dataset.hc)
    Highcharts.chart(el, data)
  })
})
