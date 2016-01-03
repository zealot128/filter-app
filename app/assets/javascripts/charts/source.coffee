jQuery ->
  $('.js-chart').each ->
    el = $(this)
    data = el.data('hc')
    console.log data
    el.highcharts(data)
