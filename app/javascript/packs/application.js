import "core-js/stable";

import Automount from 'utils/automount'

document.addEventListener('DOMContentLoaded', () => {
  Automount('trend-page', () => import("components/TrendPage"))
  Automount('news-item-wall', () => import("components/NewsItemWall"))
  Automount('trend-flame-graph', () => import("components/TrendFlameGraph"))
})
