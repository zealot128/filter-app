<template>
  <div class="news-items--wall" :class="{ 'is-loading': loading }">
    <div class="news-items--form">
      <form class="form-inline" @submit.stop.prevent="refresh">
        <input
          v-model="query"
          class="form-control"
          placeholder="Suchbegriff"
          @keyup.enter="refresh"
        />
      </form>
      <B-Dropdown menu-right>
        <a class="btn btn-sm btn-primary dropdown-toggle">
          <i class="fa fa-sort-amount-desc" aria-hidden="true"></i>
          {{ orderOptions[order] }} <span class="caret"></span>
        </a>
        <template slot="dropdown">
          <li v-for="(o, i) in orderOptions" :key='i' :class='i == order ? "active" : ""'>
            <a role="button" @click="order = i">{{ o }}</a>
          </li>
        </template>
      </B-Dropdown>
    </div>
    <div v-if="loading" class="loader">
      <i class="fa fa-spinner fa-spin fa-3x"></i>
    </div>
    <div class="news-items--wrapper">
      <NewsItem
          v-for="ni in newsItems"
          :key="ni.id"
          :news-item="ni"
          @chooseMedia="setMedia"
      />
    </div>
    <div class="text-center">
      <a v-if="hasNextPage" class="btn btn-default" @click="loadNextPage">
        Mehr
      </a>
    </div>
    <div style="flex-grow: 1"></div>

    <div :class="{ 'media-fixed': true, 'audio': !isVideo }" v-if="showPlayer">
      <button
          type="button"
          class="close pull-right"
          aria-label="Close"
          @click="showPlayer=!showPlayer"
          style="color: #000; -webkit-text-stroke: 1px white;}"
      >
        <span aria-hidden="true">&times;</span>
      </button>
      <Media :url="url" :isVideo="isVideo" :key="url"/>
    </div>
  </div>
</template>

<script>
import { Dropdown } from "uiv";
import NewsItem from "./NewsItem";
import Media from "./Media"

const qs = require("qs");

export default {
  components: { NewsItem, Media, BDropdown: Dropdown },
  props: {
    params: { type: Object, required: true },
    defaultOrder: { type: String, default: () => "all_best" },
    perPage: { type: Number, default: 30 },
    sortOptions: { type: String, default: "few" }
  },
  data() {
    return {
      query: null,
      loading: true,
      newsItems: [],
      order: this.defaultOrder,
      meta: {},
      url: null,
      isVideo: false,
      showPlayer: false,
    };
  },
  computed: {
    orderOptions() {
      const options = { all_best: "Beste", newest: "Neuste" };
      if (this.sortOptions === "all" || this.sortOptions === 'no_best') {
        // options["best"] = "Top 30% je Tag";
        options.week_best = "Top 30% je Woche";
        options.month_best = "Top 30% je Monat";
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
      if (this.query) {
        params.query = this.query;
      }
      return params;
    }
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
    this.refresh();
  },
  methods: {
    refresh() {
      this.loading = true;
      fetch(`/api/v1/news_items.json?${qs.stringify(this.searchParams)}`)
        .then(stream => stream.json())
        .then(data => {
          this.newsItems = data.news_items;
          this.meta = data.meta;
          this.loading = false;
        })
        .catch(error => console.error(error));
    },
    loadNextPage() {
      this.loading = true;
      const params = {
        ...this.searchParams,
        page: this.meta.current_page + 1
      };
      fetch(`/api/v1/news_items.json?${qs.stringify(params)}`)
        .then(stream => stream.json())
        .then(data => {
          this.newsItems = [...this.newsItems, ...data.news_items];
          this.meta = data.meta;
          this.loading = false;
        })
        .catch(error => console.error(error));
    },
    setMedia(payload) {
      this.showPlayer = true;
      this.url = payload.url;
      this.isVideo = payload.isVideo;
    }
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
  width: 320px;
  margin-right: 5px;
  margin-left: 5px;
}
.loader {
  position: absolute;
  left: 0;
  text-align: center;
  right: 0;
  z-index: 5;
}
.news-items--wrapper {
  opacity: 1;
  transition: opacity 0.3s ease-in;
}
.is-loading .news-items--wrapper {
  opacity: 0.5;
}
.news-items--form {
  display: flex;
  justify-content: flex-end;
  margin: 10px;
}
.news-items--form .form-control {
  height: 32px;
  padding-top: 0;
  padding-bottom: 0;
}
.media-fixed {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 2000;
}

.audio {
  opacity: 0.9;
}
</style>
