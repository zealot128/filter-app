jQuery ->
  $('.js-chart').each ->
    el = $(this)
    data = el.data('hc')
    el.highcharts(data)
