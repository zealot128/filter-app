<template>
  <div class="navbar navbar-default">
    <div class="container-fluid">

      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse">
          <div class="sr-only">Toggle navigation</div>
          <i class="fa fa-lg fa-bars" aria-hidden="true"></i>
        </button>
        <a v-if="!wideLayout && webShareApiSupported" class="navbar-toggle" @click="shareViaWebShare()">
          Share
          <i class="fa fa-lg fa-share-alt-square" style="color: #696969" aria-hidden="true"></i>
        </a>
        <a v-else class="navbar-toggle" href="#collapseOne" data-toggle="collapse">
          Share
          <i class="fa fa-lg fa-share-alt-square" style="color: #696969" aria-hidden="true"></i>
        </a>
        <div class="navbar-brand" @click="back()">
          <a href="/" alt="HRfilter Startseite">
            <img alt="logo" title="HRfilter.de" :src="logo" style="height: 30px" />
          </a>
        </div>
      </div>

      <div style="display: flex; justify-content: space-between;">
        <div class="navbar-collapse collapse" style="width: 100vh;" id="navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a href="/">News</a></li>
            <li><a href="/newsletter">Newsletter</a></li>
            <li><a href="/rss">Feeds</a></li>
            <li><a href="/app">Als App</a></li>
            <li>
              <a :href="'/sources/' + source.id" :title="'Mehr News von ' + source.name">
                <img :src="source.logo" v-if="source.logo" />
                <span v-else>QUELLE</span>
              </a>
            </li>

          </ul>
        </div>
        <div class="navbar-collapse collapse" id="navbar-collapse-share">
          <ul class="nav navbar-nav navbar-right">
            <li>
              <a v-if="!wideLayout && webShareApiSupported" class="share-button s-2" @click="shareViaWebShare()">
                Share
                <i class="fa fa-lg fa-share-alt-square" style="color: #696969" aria-hidden="true"></i>
              </a>
              <a v-else class="share-button s-2" href="#collapseOne" data-toggle="collapse">
                Share
                <i class="fa fa-lg fa-share-alt-square" style="color: #696969" aria-hidden="true"></i>
              </a>
            </li>
          </ul>
        </div>
      </div>
      <div class="collapse" id="collapseOne">
        <div class="wrapper">
          <div style="margin: 5px 0px 5px 10px" v-for="network in networks" :key="network">
            <ShareButton :id="newsItem.id" :network="network" :title="newsItem.title" :url="newsItem.url" />
          </div>
        </div>
      </div>
      <div class="message-box" v-if="showTooltip">
        <span>
          Seite nicht korrekt angezeigt?
          <a :href="newsItem.url" target="_blank" rel="noopener">Klicken Sie hier</a>, um die Seite in einem neuen Fenster anzuzeigen
        </span>
        <button class="btn btn-link" @click="showTooltip = false" aria-label="Hinweis schließen">
          <svg style="width: 18px; height: 18px" viewBox="0 0 24 24">
            <path
              fill="currentColor"
              d="M19,6.41L17.59,5L12,10.59L6.41,5L5,6.41L10.59,12L5,17.59L6.41,19L12,13.41L17.59,19L19,17.59L13.41,12L19,6.41Z" />
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue, { PropType } from "vue"
import ShareButton from "../front-page/components/ShareButton.vue"

type Source = {
  id: number
  name: string
  homepage_url: string
  lsr_active: boolean
  language: string
  twitter_account: string
  type: string
  url: string
  logo?: string
  remote_url: string
  statistics: {
    total_news_count: number
    average_word_length: number
    current_news_count: number
    current_top_score: number
    last_posting: string
    current_impression_count: number
  }
}

type NewsItem = {
  id: number
  title: string
  teaser: string
  url: string
  source_id: number
  published_at: string
  value: number
  fb_likes: null
  retweets: null
  guid: string
  xing: null
  created_at: string
  updated_at: string
  full_text: null
  word_length: null
  plaintext: null
  search_vector: string
  incoming_link_count: null
  absolute_score: number
  blacklisted: boolean
  reddit: null
  image_file_name: null
  image_content_type: null
  image_file_size: null
  image_updated_at: null
  impression_count: number
  tweet_id: null
  absolute_score_per_halflife: number
  youtube_likes: number
  youtube_views: number
  category_order: null
  dupe_of_id: null
  trend_analyzed: boolean
  paywall: boolean
  media_url: string
  embeddable: boolean
  image_url_full: string
  gplus: number
  linkedin: number
}

export default Vue.extend({
  components: {
    ShareButton,
  },
  props: {
    newsItem: { type: Object as PropType<NewsItem>, required: true },
    source: { type: Object as PropType<Source>, required: true },
    logo: { type: String },
  },
  data() {
    return {
      showTooltip: true,
      networks: ["facebook", "twitter", "linkedin", "xing"],
    }
  },
  methods: {
    back() {
      history.back()
    },
    shareViaWebShare() {
      navigator.share({
        title: this.newsItem.title,
        url: this.newsItem.url,
      })
    },
  },
  computed: {
    webShareApiSupported() {
      return navigator.share
    },
    wideLayout() {
      return document.body.clientWidth > 767
    },
  },
})
</script>

<style scoped>
.navbar-brand {
  cursor: pointer;
}

.navbar {
  box-shadow: 0 2px 4px #00000033;
}

.navbar-toggle:hover i {
  color: white;
}

.wrapper {
  border-top: 1px solid #bdc1c6;
  display: flex;
  justify-content: center;
  padding: 5px;
}

.message-box {
  border-top: 1px solid #bdc1c6;
  text-align: center;
  padding: 10px;
  color: grey;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.share-button {
  cursor: pointer;
  border-radius: 5px;
  text-align: right;
}

.s-2 {
  min-width: 108px;
}
</style>
