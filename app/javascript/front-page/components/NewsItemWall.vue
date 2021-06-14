<template lang="pug">
  .news-items--wall
    //SortTabs.vue
    ul.nav.nav-tabs.nav-justified.mb-2
      li(v-for="(o, i) in orderOptions" :key='i' :class='i == order ? "active" : ""')
        a(role="button" @click="order = i") {{ o }}

    .news-items--wrapper
      template(v-if="loading")
        NewsItem(
          v-for="ni in newsItemsLoading"
          :key="ni.id"
          :news-item="ni"
        )
        Skeleton(v-for="i in 10" :key="i")
      template(v-else)
        NewsItem(
          v-for="ni in newsItems"
          :key="ni.id"
          :news-item="ni"
        )
        //EmptyState.vue
        template(v-if="newsItems.length === 0")
          div(style="font-size:5rem")
            i.fa.fa-exclamation-triangle
          h4 Leider gibt es keinen Artikel für ihre ausgewählte Suchmuster, bitte versuchen Sie nochmal mit einem neuen Muster.

    .text-center
      a.btn.btn-default(v-if="hasNextPage" @click="loadNextPage()" style="margin-bottom: 30px")
        | Mehr
</template>

<script>
import NewsItem from "./NewsItem";
import Skeleton from "./Skeleton"
import { mapState } from 'vuex';


const qs = require("qs");

export default {
  components: {
    NewsItem,
    Skeleton
  },
  props: {
    defaultOrder: { type: String, default: () => "all_best" },
    perPage: { type: Number, default: 15 },
    sortOptions: { type: String, default: "few" },
  },
  data() {
    return {
      savedScrollPosition: 0,
      loading: true,
      newsItems: [],
      newsItemsLoading: [],
      order: this.defaultOrder,
      page: 0,
      meta: {},
      url: null,
    };
  },
  computed: {
    ...mapState([
      'params'
    ]),
    orderOptions() {
      const options = { all_best: "Beste", newest: "Neueste" };
      if (this.sortOptions === "all" || this.sortOptions === 'no_best') {
        options.hot_score = "Hot";
      }
      if (this.sortOptions === "no_best") {
        delete options.all_best
      }
      return options;
    },
    hasNextPage() {
      return this.meta && this.meta.current_page < this.meta.pages;
    },
    searchParams() {
      const params = {
        ...this.params,
        order: this.order,
        limit: this.perPage
      };
      return params;
    },
  },
  watch: {
    params: {
      handler() {
        this.refresh();
      },
      deep: true
    },
    order() {
      this.refresh();
    }
  },
  mounted() {
    if ('scrollRestoration' in history) history.scrollRestoration = 'manual';
    window.addEventListener('beforeunload', () => {
      const newState = {
        ...history.state,
        params: this.searchParams,
        lastScrollPosition: window.scrollY,
        page: this.page
      }
      history.pushState(newState, '', location.href)
    })
    if (history.state) {
      try {
        this.$store.commit('set_params_based_on_data', history.state.params);
        this.order = history.state.params.order;
      }
      catch(error){
        console.error(error, "History is null!");
      }
    }
    this.loadPages(history.state?.page || 1)
  },
  beforeDestroy() {
    window.removeEventListener("beforeunload") ;
  },
  methods: {
    getScrollPosition() {
      return window.scrollY;
    },
    setScrollPosition(position) {
      window.scrollTo(0, position);
    },
    deleteHistory() {
      delete history.state.params;
      delete history.state.lastScrollPosition;
      delete history.state.page;
      history.replaceState({}, '', location.href);
    },
    scrollToLastPosition() {
      if (typeof history.state?.lastScrollPosition !== 'number') return
      this.setScrollPosition(history.state.lastScrollPosition);
      this.deleteHistory();
    },
    async loadPages(pages) {
      if (pages < 1) {
        this.scrollToLastPosition();
        return;
      }
      await this.loadNextPage();
      await this.loadPages(pages - 1);
    },
    refresh() {
      this.page = 1
      return this.loadNextPage(true)
    },
    loadNextPage(clearNewsItem=false) {
      let page = 1;
      if(!clearNewsItem) {
        page = this.page+ 1;
        this.newsItemsLoading = this.newsItems;
      }
      this.loading = true;
      const params = {
        ...this.searchParams,
        page,
      };
      // console.log(`/api/v1/news_items.json?${qs.stringify(params)}`);
      return fetch(`/api/v1/news_items.json?${qs.stringify(params)}`)
          .then(stream => stream.json())
          .then(data => {
            (clearNewsItem) ? this.newsItems = data.news_items : this.newsItems.push(...data.news_items);
            this.meta = data.meta;
            this.newsItemsLoading = [];
            this.loading = false;
            this.page = page
            return true
          })
          .catch(error => console.error(error));
    },
  }
};
</script>

<style scoped>
.news-items--wall {
  position: relative;
  min-height: 400px;
}
.news-items--wrapper {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
}
.news-items--wrapper >>> .news-item-panel {
  width: 100%;
}
.news-items--form {
  display: flex;
  justify-content: flex-start;
  margin: 10px;
}
.news-items--form .form-control {
  height: 32px;
  padding-top: 0;
  padding-bottom: 0;
}

</style>
