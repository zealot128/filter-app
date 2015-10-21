

var app = angular.module('frontpage', ['ngRoute']);

var grid = null;
var moreButton = null;
$(document).on("ready page:load", () => {
  grid = $('.js-grid');
  if(grid.length > 0) {
    moreButton = $('.js-more');
  }
});

app.config(($routeProvider, $locationProvider) => {
  $locationProvider.html5Mode(false);
  $routeProvider
    .when('/:sort', {
      templateUrl: 'index.html',
      controller: 'CategoryCtrl'
    })
    .when('/:sort/Category/:category', {
      templateUrl: 'index.html',
      controller: 'CategoryCtrl'
    });
    // .otherwise({
    //   redirectTo: '/popular'
    // });
});

app.service('State', ()=> {
  return {
    currentCategory: -1,
    sort: 'popular',
    hasMore: true
  };
});

app.controller('CategoryCtrl', ($scope, $routeParams, State, PostLoader) => {
  State.sort = $routeParams.sort;
  if($routeParams.category) {
    State.currentCategory = parseInt($routeParams.category);
  } else {
    State.currentCategory = -1;
  }
  $scope.state = State;
  console.log(State);
  PostLoader.loadPosts();
});

app.factory("PostLoader", (State, $http) => {
  return {
    loadPosts: function(page=1) {
      if(!grid) {
        grid = $('.js-grid');
      }
      grid.addClass('leaving');
      grid.addClass('leaving');
      var data = { page: page, category: State.currentCategory, order: State.sort };
      $http({ method: 'get', params: data, url: '/api/news_items/homepage.json'}).success( (data)=> {
        State.hasMore = false;
        if (page === 1) {
          grid.html(data.html);
          grid.addClass('entering');
          grid.removeClass('leaving');
        } else {
          grid.append(data.html);
          grid.addClass('entering').removeClass('leaving');
        }
        if(window.refresh_date) {
          window.refresh_date();
        }
        if (data.pagination.total_pages > page) {
          State.hasMore = true;
          State.currentPage = page;
        } else {
          State.hasMore = false;
        }
        console.log(State);
      });
    }
  };
});


app.controller('NavCtrl', ($scope, State, PostLoader) => {
  $scope.state = State;
});

app.controller('PageCtrl', ($scope, State, PostLoader) => {
  $scope.nextPage = function() {
    State.hasMore = false;
    PostLoader.loadPosts(State.currentPage + 1);
  };
  $scope.hasNextPage = function() {
    return State.hasMore;
  };
});




$(document).on('mousedown', '[data-proxy]', (e) => {
 if (e.target && e.target.dataset.proxy) {
   e.target.href = e.target.dataset.proxy;
  }
});
