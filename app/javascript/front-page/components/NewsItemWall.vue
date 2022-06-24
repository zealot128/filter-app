<template lang="pug">
  .news-items--wall
    ul.nav.nav-tabs.nav-justified.mb-2(v-if="fullLayout")
      li(v-for="mt in mediaTypes" :key='mt' :class='isChosenMediaType(mt) ? "active" : ""')
          a(role="button" @click="setMediaType(mt)")
            span(style="display: inline-flex")
              | {{ typeTitle(mt) }}
              svg(fill="currentColor" style="margin-left: 5px" height="20px" width="20px" viewBox="0 0 24 24")
                path(:d="iconForType(mt)")

    .news-items--wrapper
      template(v-if="loading")
        NewsItem(
          v-for="ni in newsItemsLoading"
          :key="ni.id"
          :news-item="ni"
        )
        Skeleton(v-for="i in 15" :key="i")
      template(v-else)
        NewsItem(
          v-for="ni in newsItems"
          :key="ni.id"
          :news-item="ni"
        )
        template(v-if="newsItems.length === 0")
          div(style="font-size:5rem")
            i.fa.fa-exclamation-triangle
          h4 Leider gibt es keinen Artikel für ihre ausgewählte Suchmuster, bitte versuchen Sie nochmal mit einem neuen Muster.


    .text-center
      a.btn.btn-default(v-if="hasNextPage && !fullLayout" @click="loadNextPage()" style="margin-bottom: 30px")
        | Mehr

</template>

<script>
import NewsItem from "./NewsItem";
import Skeleton from "./Skeleton"
import { mapState, mapGetters } from 'vuex';
import json from "../icons.json"

const qs = require("qs");

export default {
  components: {
    NewsItem,
    Skeleton
  },
  props: {
    defaultOrder: { type: String, default: () => "all_best" },
    perPage: { type: Number, default: 30 },
    sortOptions: { type: String, default: "few" },
    fullLayout: { type: Boolean, default: true }
  },
  data() {
    return {
      loading: true,
      newsItems: [],
      newsItemsLoading: [],
      order: this.defaultOrder,
      page: 0,
      meta: {},
      firstLoad: true,
    };
  },
  computed: {
    ...mapState([
      'params',
      'mediaTypes'
    ]),
    ...mapGetters([
      'isChosenMediaType',
      'typeTitle'
    ]),
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
        if(this.firstLoad){
          this.loadPages(history.state?.page || 1);
          this.firstLoad = false;
        }
        else {
          this.refresh();
        }
      },
      deep: true,
    },
    order() {
      this.refresh();
    }
  },
  methods: {
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
      this.loading = true;
      let page = 1;
      if(!clearNewsItem) {
        page = this.page+ 1;
        this.newsItemsLoading = this.newsItems;
      }
      const params = {
        ...this.searchParams,
        page,
      };
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
    handleHistory: function() {
      const newState = {
        ...history.state,
        params: this.searchParams,
        lastScrollPosition: window.scrollY,
        page: this.page
      }
      history.pushState(newState, '', location.href);
    },
    autoload() {
      if(this.loading == false && this.hasNextPage) this.loadNextPage();
    },
    iconForType(type) {
      return json[type];
    },
    setMediaType(type) {
      this.$store.commit('set_chosen_type', type);
      this.$store.dispatch("build_params");
    }
  },
  mounted() {
    if ('scrollRestoration' in history) history.scrollRestoration = 'manual';
    window.addEventListener('beforeunload', this.handleHistory);
    try {
      this.$store.commit('set_params_based_on_data', history.state.params);
      this.order = history.state.params.order;
    }
    catch(error){
      this.$store.dispatch('trigger_watch_params');
    }
  },
  beforeDestroy() {
    window.removeEventListener('beforeunload', this.handleHistory);
  }
};
</script>

<style scoped>
.news-items--wall {
  position: relative;
  margin-top: 10px;
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
