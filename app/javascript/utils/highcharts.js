import Vue from 'vue'
// import 'utils/moment'

import Highcharts from 'highcharts';
import VueHighcharts from 'vue-highcharts';
// import loadStock from 'highcharts/modules/stock.js';
// import loadHighchartsMore from 'highcharts/highcharts-more.js';


// import highchartsMore from 'highcharts/highcharts-more';
// import solidGauge from 'highcharts/modules/solid-gauge';

// highchartsMore(Highcharts);
// solidGauge(Highcharts);
// loadStock(Highcharts);
// loadHighchartsMore(Highcharts);
Vue.use(VueHighcharts, { Highcharts });

Highcharts.setOptions({
  labels: {
    style: {
      fontFamily: '"Century Gothic", "Apple SD Gothic Neo", "Apple Gothic", AppleGothic, "URW Gothic L", "Avant Garde", Futura, sans-serif'
    }
  },
  tooltip: {
    style: {
      fontFamily: '"Century Gothic", "Apple SD Gothic Neo", "Apple Gothic", AppleGothic, "URW Gothic L", "Avant Garde", Futura, sans-serif'
    }
  },
  lang: {
    loading: 'Lade...',
    months: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
    shortMonths: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
    weekdays: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'],
    decimalPoint: ',',
    numericSymbols: ["k", "M", "G", "T", "P", "E"],
    thousandsSep: ".",
    resetZoom: "Zoom zurücksetzen",
    resetZoomTitle: "Zoom zurücksetzen 1:1",
    printChart: "Drucken",
    downloadPNG: "PNG herunterladen",
    downloadJPEG: "JPEG herunterladen",
    downloadPDF: "PDF herunterladen",
    downloadSVG: "SVG herunterladen",
    contextButtonTitle: "Chart Optionen"
  }
});

Highcharts.dateFormats = {
  W: function (timestamp) {
    var date = new Date(timestamp),
      day = date.getUTCDay() === 0 ? 7 : date.getUTCDay(),
      dayNumber;
    date.setDate(date.getUTCDate() + 4 - day);
    dayNumber = Math.floor((date.getTime() - new Date(date.getUTCFullYear(), 0, 1, -6)) / 86400000);
    return 1 + Math.floor(dayNumber / 7);

  }
};
export default Highcharts
