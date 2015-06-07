var currentCategory = null;
var grid = null;

var routes = {
  'category/:categoryId': function(categoryId) {
    currentCategory = parseInt(categoryId);
    setCategoryActive();
    reshuffle();
  },
  '/': function(){
    currentCategory = null;
    setCategoryActive();
    reshuffle();
  }
};

var reshuffle = function() {
  grid.shuffle('shuffle', function(el, shuffle) {
    if (currentCategory === null) {
      return true;
    }
    var data = el.data('item');
    if (currentCategory === 0) {
      return data.categories.length === 0;
    }
    return data.categories.indexOf(currentCategory) != -1;
  });
};

var setCategoryActive = function() {
  var currentPath = window.location.hash.replace('#','');
  $('[data-active-on]').each(function() {
    var el = $(this);
    el.removeClass('active');
    if(el.data('active-on') === currentPath) {
      el.addClass('active');
    }
  });
};

var loadAllPosts = function(then) {
  $.get('/api/news_items/homepage.json', (data) => {
    grid.html(data.html);
    then();
  });
};

$(document).on("ready page:load", () => {
  grid = $('.js-grid');
  var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
  if(h < 600) {
    Shuffle.options.speed = 1;
  }
  if(grid.length > 0) {
    loadAllPosts(function() {
      grid.shuffle('sort', {
        itemSelector: '.js-grid-item'
      });
      var router = Router(routes);
      router.init();
      window.router = router;
    });
  }
});

