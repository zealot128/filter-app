var currentCategory = null;
var grid = null;
var currentPage = false;
var posts = [];
var moreButton = null;

var routes = {
  'category/:categoryId': function(categoryId) {
    currentCategory = parseInt(categoryId);
    setCategoryActive();
    loadPosts(currentCategory);
  },
  '/': function(){
    currentCategory = null;
    setCategoryActive();
    loadPosts(currentCategory);
  }
};

var loadPosts = function(currentCategory,page=1) {
  var data = { page: page, category: currentCategory };
  $.get('/api/news_items/homepage.json', data , (data)=> {
    if (page === 1) {
      grid.html(data.html);
      grid.addClass('entering');
      grid.removeClass('leaving');
    } else {
      grid.append(data.html);
    }
    if (data.pagination.total_pages > page) {
      moreButton.show();
      currentPage = page;
    } else {
      moreButton.hide();
      currentPage = false;
    }
  });
};

$(document).on('click', '.js-more', (e)=> {
  e.preventDefault();
  loadPosts(currentCategory, currentPage + 1);
  moreButton.hide();
  return false;
});

var setCategoryActive = function() {
  grid.addClass('leaving');
  var currentPath = window.location.hash.replace('#','');
  $('[data-active-on]').each(function() {
    var el = $(this);
    el.removeClass('active');
    if(el.data('active-on') === currentPath) {
      el.addClass('active');
    }
  });
};

$(document).on("ready page:load", () => {
  grid = $('.js-grid');
  if(grid.length > 0) {
    moreButton = $('.js-more');
    var router = Router(routes);
    router.init();
    window.router = router;
  }
});

