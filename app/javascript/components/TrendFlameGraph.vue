<template>
  <Highcharts :options='chartOptions' style='height: 100px'/>
</template>

<script>
import 'utils/highcharts'

export default {
  components: {},
  props: {
    chart: { type: Object, required: true },
    trend: { type: Object, required: true }
  },
  computed: {
    chartOptions() {
      const opts = {
        ...this.chart,
        chart: { type: 'column' },
        // tooltip: { enabled: false },
        title: { text: null },
        yAxis: { visible: false },
        xAxis: { type: 'datetime', plotLines: this.chart.xAxis.plotLines },
        series: [this.chart.series[0]]
      }
      return opts
    }
  },
  methods: {},
}
</script>

<style scoped>
</style>
