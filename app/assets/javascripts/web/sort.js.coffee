storage =
  load: ->
    if window.localStorage and window.localStorage.getItem('categories')
      console.log 'load from storage' if console
      $('input.slide').each ->
        name = $(this).attr('name')
        if value = window.localStorage.getItem(name)
          $(this).val(value)

      categories = window.localStorage.getItem('categories').split(',' )
      if categories.length > 0
        $('input[name=category\\[\\]]').attr('checked',false)
        for category in categories
          el = $("input[name=category\\[\\]][value=#{category}]")
          el.prop('checked', true)
  save: ->
    if window.localStorage
      categories = $("input[name=category\\[\\]]:checked").map( ->
        this.value
      ).get()
      console.log 'save to storage' if console
      $('input.slide').each ->
        name = $(this).attr('name')
        val = $(this).val()
        window.localStorage.setItem(name, val)
      window.localStorage.setItem('categories', categories)



resort = ->
  categories = $("input[name=category\\[\\]]:checked").map( ->
    this.value
  ).get()

  freshness = $('.slide[name=freshness]').val()
  facebook  = $('.slide[name=facebook]').val()
  twitter   = $('.slide[name=twitter]').val()
  xing      = $('.slide[name=xing]').val()
  linkedin  = $('.slide[name=linkedin]').val()
  gplus     = $('.slide[name=gplus]').val()
  wlength   = $('.slide[name=wlength]').val()



  value = (jquery_object)->
    jquery_object.data("freshness") * freshness +
    jquery_object.data("gplus") * gplus +
    jquery_object.data("facebook") * facebook +
    jquery_object.data("linkedin") * linkedin +
    jquery_object.data("twitter") * twitter +
    jquery_object.data("xing") * xing +
    jquery_object.data("words") * Math.pow(wlength + 1, 1/4) +
    jquery_object.data("bias") * 50

  lis = $('.item')
  iLnH = null
  lis.each (i,el)->
    self = $(this)
    my_categories = self.data('categories')
    visible = false
    for category in categories
      if category =='false' and my_categories.length == 0
        visible = true
        break
      if $.inArray(parseInt(category), my_categories) != -1
        visible = true
        break
    if visible
      self.show()
    else
      self.hide()
      return
  $('#loader').show()
  setTimeout ->
    $('#loader').hide()
  ,200

  $('.item').tsort
    order: "desc"
    sortFunction: (a,b)->
      val_a = value(a.e)
      console.log val_a
      a.e.find('.value').text(val_a)
      val_b = value(b.e)
      b.e.find('.value').text(val_b)
      if val_a < val_b
        1
      else if val_a == val_b
        0
      else
        -1


$ ->
  storage.load()
  $('.slide').each ->
    el = $(@)
    el.val(el.attr("value"))
  .on "change", (ev)->
    storage.save()
    resort()
  $('#filter input').on 'change', ->
    resort()
    storage.save()

  setTimeout ->
    resort()
  , 500

  $('#settings .dropdown-toggle').click ->
    $('#settings .dropdown-menu').toggle()
    $('#filter .dropdown-menu').hide()

  $('#filter .dropdown-toggle').click ->
    $('#settings .dropdown-menu').hide()
    $('#filter .dropdown-menu').toggle()


  c =  $('.page-container')[0]
  $('body').on "click", (a,b)->
    if (a.target) == c
      $('#settings .dropdown-menu').hide()
      $('#filter .dropdown-menu').hide()


