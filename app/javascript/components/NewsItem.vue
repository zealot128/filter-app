<template>
  <div class="panel panel-default news-item-panel">
    <div class="panel-heading">
      <h3 class="panel-title">
        <a
          :href="url"
          target="_blank"
          rel="noopener"
          :title="newsItem.title"
        >
          {{ newsItem.title | truncate(100)}}
        </a>
      </h3>
    </div>

    <div :class="{ 'panel-body': true, 'with-background': hasImage }">
        <div v-if="hasImage" class="background-frame background" :style="{ 'background-image': 'url(' + newsItem.image.full_url + ')', 'background-position': 'center', 'background-size': 'cover' }"/>
        <div class="fog-fade"></div>
        <div class="background-text">
          <p class="source"></p>
          <span v-if='!lsr'>{{ newsItem.teaser }}</span>
        </div>
        <div class="fog-fade"></div>
    </div>

    <ul class="list-group">
      <li class="list-group-item" v-if="newsItem.media_url && !show">
        <i class='fa fa-play news-item__play-icon'></i>
        <div style='display: flex; align-items: center;'>
          <div style='margin-right: 7px'>
            <input type="checkbox" @click="chooseMedia"/>
          </div>
          <div style='flex-grow: 1'>
            <small class="text-muted">
              Ich möchte
              <template v-if="!isVideo">den Podcast</template>
              <template v-else>das Video</template>
              von
              <em data-toggle="tooltip" data-placement="bottom" :title="newsItem.source.name">
                {{ mediaUrlHostname }}
              </em>
              einbinden und hier abspielen.
            </small>
          </div>
        </div>
      </li>

      <li class="list-group-item" v-else>
        <div v-for="network in networks" :key="network">
          <ShareButton
            :id="newsItem.id"
            :network="network"
            :title="newsItem.title"
            :url="newsItem.original_url"
          />
        </div>
      </li>
    </ul>

    <div class='panel-footer'>
      <span class='pull-right text-muted'>
        <span v-if='newsItem.paywall' class='label label-warning'>
          <i class='fa fa-euro fa-fw' title='Paywall'></i>
        </span>
        {{ date }}
      </span>
      <span class='source'>
        <img v-if='newsItem.source.logo' :src='newsItem.source.logo' width='16' height='16'/>
        <a title='newsItem.source.name' :href='newsItem.source.url'>
          {{ newsItem.source.name | truncate(30) }}
        </a>
      </span>
    </div>
  </div>
</template>

<script>
import truncate from "utils/truncate-filter"
import ShareButton from "./ShareButton";
import ahoy from 'utils/ahoy'

export default {
  filters: { truncate },
  data() {
    return {
      show: false,
      networks: ["facebook", "twitter", "linkedin", "xing"]
    }
  },
  props: {
    newsItem: { type: Object, required: true }
  },
  methods: {
    chooseMedia() {
      const payload = {
        'url': this.newsItem.media_url,
        'isVideo': this.isVideo,
      };
      ahoy.track("hrfilter/play_media", { id: this.newsItem.id, source_id: this.newsItem.source.id })
      this.$emit("chooseMedia", payload);
      this.show = true;
    }
  },
  computed: {
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
      return this.newsItem.image && this.newsItem.image.full_url && !this.lsr;
    },
    isVideo() {
      return this.newsItem.original_url.indexOf('youtube') !== -1;
    },
    mediaUrlHostname() {
      if (!this.newsItem.media_url) return null

      return this.newsItem.media_url.replace(/https?:\/\/([^\/]+)\/.*/, "$1").replace('www.', '')
    }
  },
  components: {
    ShareButton,
  }
};
</script>

<style scoped>
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
</style>
