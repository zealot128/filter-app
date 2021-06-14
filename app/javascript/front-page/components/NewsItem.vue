<template lang="pug">
  .panel.panel-default.news-item-panel
    .panel-body
      .content-container

        .row(v-if="$store.getters.wideLayout && hasImage")
          .col-xs-9
            h4.panel-title
              a(:href="url"
                :title="newsItem.title"
              )
                | {{ newsItem.title | truncate(100)}}
            div.mt-1(v-if="!lsr")
              i.fa.fa-angle-double-right
              em &nbsp;
                template(v-if="newsItem.teaser.length > 0") {{ newsItem.teaser | truncate(200) }}
                template(v-else) Für diesen Artikel gibt es leider keinen Teaser.

          .col-xs-3
            img.cover(:src="newsItem.image.full_url" loading="lazy" style="margin-bottom:1rem")

        div(v-else)
          img.cover(v-if="hasImage" :src="newsItem.image.full_url" loading="lazy" style="margin-bottom:1rem")
          h4.panel-title
            a(:href="url"
              :title="newsItem.title"
            )
              | {{ newsItem.title | truncate(100)}}
          div.mt-1(v-if="!lsr")
              i.fa.fa-angle-double-right
              em &nbsp;
                template(v-if="newsItem.teaser.length > 0") {{ newsItem.teaser | truncate(200) }}
                template(v-else) Für diesen Artikel gibt es leider keinen Teaser.

        div.block(v-show="!showPlayer && mediaUrlHostname")
          span.text-muted.pull-right.hidden-xs.hidden-sm(style="min-width: 65%; text-align: right")
            | Ich möchte&nbsp;
            template(v-if="!isVideo") den Podcast von&nbsp;
            template(v-else) das Video von&nbsp;
            em(data-toggle="tooltip" data-placement="top" :title="newsItem.source.name") {{ mediaUrlHostname }}
            | &nbsp;einbinden und hier abspielen.
          span.text-muted.pull-right.visible-xs.visible-sm
            | Ich möchte&nbsp;
            template(v-if="!isVideo") den Podcast von&nbsp;
            template(v-else) das Video von&nbsp;
            em(data-toggle="tooltip" data-placement="top" :title="newsItem.source.name") {{ mediaUrlHostname }}
            | &nbsp;einbinden und hier abspielen.
          button.btn-play.pull-right(@click="chooseMedia()") 
            i.fa.fa-play.fa-fw
            |
            |Zustimmen und Abspielen

        Media.mt-1(v-if="showPlayer" :url="newsItem.media_url" :isVideo="isVideo")

        .source.mt-1(style="display:flex; align-items:baseline; justify-content:space-between;")
          span
            img(v-if='newsItem.source.logo' :src='newsItem.source.logo' loading="lazy" width='16' height='16')
            a(title='newsItem.source.name' :href='newsItem.source.url')
              | &nbsp;{{ newsItem.source.name | truncate(30) }}
            | &nbsp;{{ date }}
            span(v-if='newsItem.paywall' class='label label-warning' style="margin-left:1rem")
              i.fa.fa-euro.fa-fw(title='Paywall')
          button(v-if="isMobile && webShareApiSupported" @click="shareViaWebShare()")
            i.fa.fa-share-alt(aria-hidden="true")
          .dropdown(v-else)
            button(data-toggle="dropdown")
              i.fa.fa-share-alt(aria-hidden="true")
            ul.dropdown-menu.dropdown-menu-right(role="menu" aria-labelledby="dLabel")
              li
                div(v-for="network in networks" :key="network")
                  ShareButton(
                    :id="newsItem.id"
                    :network="network"
                    :title="newsItem.title"
                    :url="newsItem.original_url"
                  )
</template>

<script>
import truncate from "utils/truncate-filter";
import ShareButton from "./ShareButton";
import { mapGetters } from 'vuex';
import Media from "./Media";
import ahoy from 'utils/ahoy';

export default {
  filters: { truncate },
  data() {
    return {
      showPlayer: false,
      networks: ["facebook", "twitter", "linkedin", "xing"]
    }
  },
  props: {
    newsItem: { type: Object, required: true },
  },
  methods: {
    chooseMedia() {
      this.$store.dispatch('play_or_pause', false);
      ahoy.track("hrfilter/play_media", { id: this.newsItem.id, source_id: this.newsItem.source.id })
      this.$store.dispatch('play_or_pause', true);
      this.showPlayer = true;
    },
    shareViaWebShare() {
      navigator.share({
        title: this.newsItem.title,
        url: this.newsItem.original_url,
      })
    }
  },
  computed: {
    ...mapGetters([
      'isMobile'
    ]),
    // Leistungsschutzrecht
    lsr() {
      return this.newsItem.source.lsr_active
    },
    url() {
      return this.newsItem.url.split('?')[0]
    },
    date() {
      const d = new Date(Date.parse(this.newsItem.published_at))
      const today = new Date
      const month = ['Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'][d.getMonth()]
      let s = `${d.getDate()}. ${month}`
      if (d.getFullYear() !== today.getFullYear()) {
        s += " " + d.getFullYear()
      }
      return s
    },
    hasImage() {
      return (this.newsItem.image && this.newsItem.image.full_url && !this.lsr) && (!this.showPlayer || !this.isVideo);
    },
    isVideo() {
      return this.newsItem.original_url.indexOf('youtube') !== -1;
    },
    mediaUrlHostname() {
      if (!this.newsItem.media_url) return null
      return this.newsItem.media_url.replace(/https?:\/\/([^\/]+)\/.*/, "$1").replace('www.', '')
    },
    webShareApiSupported() {
      return navigator.share;
    },

  },
  components: {
    ShareButton,
    Media
  }
};
</script>

<style scoped>
.news-item-panel {
  box-shadow: 0 5px 6px #ccc;
}
.panel-footer {
  padding: 2px;
}
.label-warning {
  display: inline-block;
  height: 15px;
  border-radius: 5px;
}
.list-group-item {
  display: flex;
  justify-content: center;
  min-height: 65px;
}
.news-item__play-icon {
  position: absolute;
  color: #666;
  opacity: 0.2;
  font-size: 3rem;
}
.content-container {
  display: flex;
  flex-direction: column;
}

.block {
  margin-top: 1rem;
  display: block;
}

.btn-play {
  margin-top: 0.5rem;
  border: 1px solid #2780E3;
  border-radius: 9999px;
  background-color: white;
  padding: 5px 10px;
  cursor: pointer;
  font-size:14px;
  text-align: center;
  width: 45%;
  color: #2780E3;
}

.panel-body {
  overflow: visible !important;
}

.dropdown-menu {
  padding: 0;
  border: none;
  background: none;
}
.panel-title {
  font-size: 23px;
}

.cover {
  border-radius: 5px;
  height: 100%;
  width: 100%;
  max-height: 200px;
  object-fit: cover;
}

</style>
