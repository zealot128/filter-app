import "core-js/stable";

import Automount from 'utils/automount'
import store from "../front-page/store";

document.addEventListener('DOMContentLoaded', () => {
  Automount('trend-page', () => import("components/TrendPage"), {store})
  Automount('trend-flame-graph', () => import("components/TrendFlameGraph"))
  Automount('sources', () => import("components/Sources"), {store})
})
