<template>
  <div>
    <div v-if='trendsMonth.length > 0' class='trend-wrapper'>
      <TrendWordCloud v-if='trendsWeek.length > 0' :trends='trendsWeek' title='Trends der Woche'/>
      <TrendWordCloud v-if='trendsMonth.length > 0' :trends='trendsMonth' title='Trends der letzten 30 Tage'/>
    </div>
  </div>
</template>

<script>

import TrendWordCloud from './TrendWordCloud'

export default {
  components: { TrendWordCloud },
  data() {
    return {
      trendsMonth: [],
      trendsWeek: [],
      loading: true
    }
  },
  mounted() {
    fetch(`/js/trends.json`)
      .then(stream => stream.json())
      .then(data => {
        this.trendsWeek = data.week;
        this.trendsMonth = data.month;
        this.loading = false;
        this.$nextTick(() => {
        })
      })
      .catch(error => console.error(error));
  },
  methods: {}
}
</script>

<style scoped>
.trend-wrapper {
  display: flex;
  justify-content: space-around;
}
.trend-wrapper >>> .panel {
  width: 500px;
  margin-left: 20px;
  margin-right: 20px;
}
@media screen and (max-width: 1100px) {
  .trend-wrapper {
    display: block;
  }
  .trend-wrapper >>> .panel {
    margin: auto;
    margin-bottom: 20px;
  }
}
</style>
