<template>
  <div>
    <div class='panel panel-default chart-panel'>
      <Highcharts :options='chartOptions' />
    </div>
    <NewsItemWall :params='params' />
  </div>
</template>

<script>
import 'utils/highcharts'
import NewsItemWall from './NewsItemWall'

export default{
  components: { NewsItemWall },
  props: {
    chart: { type: Object, required: true },
    trend: { type: Object, required: true }
  },
  data() {
    return {
      min: null,
      max: null,
    }
  },
  computed: {
    params() {
      const query = { trend: this.trend.slug }
      if (this.min) {
        query.from = (new Date(this.min)).toISOString()
      }
      if (this.max) {
        query.to = (new Date(this.max)).toISOString()
      }
      return query;
    },
    chartOptions() {
      const that = this
      return {
        ...this.chart,
        xAxis: {
          ...this.chart.xAxis,
          events: {
            setExtremes(e) {
              that.min = e.min
              that.max = e.max
            }
          }
        }
      }
    }
  },
}
</script>

<style scoped>
.chart-panel {
  margin-top: 30px;
  padding-top: 15px;
  padding-right: 5px;
}
</style>
