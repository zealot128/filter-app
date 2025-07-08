// Import application styles (includes Bootstrap 5)
import '../styles/application.scss'

import Automount from 'utils/automount'
// import store from "../front-page/store";
import App from "front-page/components/FrontPage.vue";

import Rails from '@rails/ujs'

if (!window._rails_loaded) {
  Rails.start()
}


// Import Stimulus controllers
import "controllers"

document.addEventListener('DOMContentLoaded', () => {
  Automount('sources', () => import("components/Sources.vue"))
  Automount('embed-head', () => import("components/EmbedHead.vue"))
  Automount('front-page-app', App);
})

import $ from 'jquery'

import 'bootstrap/js/src/tooltip'
import 'bootstrap/js/src/dropdown'
import 'bootstrap/js/src/collapse'
import 'bootstrap/js/src/modal'

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
