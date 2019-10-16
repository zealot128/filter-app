// babel polyfill reicht iwie nicht fuer Promise...
import 'core-js/modules/es6.promise';
import Vue from 'vue';
import axios from 'axios';
import VueAxios from 'vue-axios'

import $ from 'jquery'

Vue.use(VueAxios, axios)

axios.defaults.baseURL = '/';
axios.defaults.withCredentials = false;
axios.defaults.headers.common['Accept'] = 'application/json'

$(document).ready(() => {
  const tokenDom = document.getElementsByName('csrf-token')[0]
  if (tokenDom) {
    const token = tokenDom.getAttribute('content')
    axios.defaults.headers.common['X-CSRF-Token'] = token
  }
})

export default axios
