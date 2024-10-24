<template>
  <div>
    <div class='panel panel-default chart-panel'>
      <Highcharts :options='chartOptions' style='height: 200px'/>
    </div>
    <NewsItemWall default-order='hot_score' sort-options='all'/>
    <SearchBar v-bind:expand="true"/>
  </div>
</template>

<script>
import 'utils/highcharts'
import NewsItemWall from '../front-page/components/NewsItemWall.vue'
import SearchBar from '../front-page/components/SearchBar.vue'

export default{
  components: {
    NewsItemWall,
    SearchBar
  },
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
  mounted() {
    this.$store.commit('expand_params_based_on_data', this.params);
  }
}
</script>

<style scoped>
.chart-panel {
  margin-top: 30px;
  padding-top: 15px;
  padding-right: 5px;
}
</style>
