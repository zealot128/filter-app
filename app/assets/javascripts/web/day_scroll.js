var loader = $("<div class='text-center'><i class='fa fa-spinner fa-spin fa-3x'></i></div>")
var container = null;

var lock = false
var nextLink = null

var checkLoad = function() {
  if ($(window).scrollTop() >= $(document).height() - $(window).height() - 300) {
    if (lock) return;

    lock = true
    container.append(loader)
    loader.show()
    $.get(nextLink, function(response) {
      var r = $(response).find('.day-container').html()
      container.append(r)
      nextLink = $('a.jscroll-next').remove().attr('href')
      loader.hide()
      lock = false
    })
    var el = $('.js-follow-me');
    if (el.length > 0) {
      stickyHeaders.load(el);
    }
  }
}
var scrollListener = function () {
  $(window).one("scroll", function () { //unbinds itself every time it fires
    checkLoad()
    setTimeout(scrollListener, 10); //rebinds itself after 200ms
  });
};
$(document).ready(function () {
  if ($('.day-container').length > 0) {
    container = $('.day-container').first()
    nextLink = $('a.jscroll-next').remove().attr('href')
    scrollListener();
    checkLoad();
  }
});
