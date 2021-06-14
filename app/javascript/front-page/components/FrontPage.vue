<template lang="pug">
  div
    .news-app-wrapper
      .container
        .row.display-flex
          .col-sm-5.col-md-4(v-if="$store.state.loaded && $store.getters.wideLayout")
            .sticky-top.sticky-top--1.scrollable
              div
                .header
                  a(href="/")
                    img(:src="hrfilterLogo" height="30px")
                  hr(style="margin: 1rem 0.5rem")
                SideComponents
          .col-sm-7.col-md-8
            NewsItemWall(
              default-order="hot_score"
              sort-options="no_best"
            )
        template(v-if="$store.state.loaded")
          SearchBar(:bottom="bottom")
          Modal(
            v-if="!$store.getters.wideLayout"
            @buildPayload="buildPayload"
          )
    .container
      .text-center
        h3(style="margin-top: 0;")
          | HR-Stellenanzeigen
      Jobs(style="margin-bottom: 2rem")
</template>

<script>
import NewsItemWall from "./NewsItemWall";
import SearchBar from "./SearchBar";
import SideComponents from "./SideComponents";
import Modal from "./Modal"
import Jobs from "./Jobs";
import hrfilterLogo from "../../../assets/images/hrfilter/logo-large.png"

export default {
  name: "FrontPage.vue",
  data() {
    return {
      bottom: "0",
    }
  },
  components: {
    NewsItemWall,
    SearchBar,
    Jobs,
    SideComponents,
    Modal,
  },
  computed: {
    hrfilterLogo() {
      return hrfilterLogo
   },
   },
  methods: {
    buildPayload(pl) {
      const payload = {
        selection: pl.selection,
        data: pl.data,
      };
      this.$store.dispatch("add_or_delete_selections", payload);
    },
    scroll () {
      var prevScrollpos = window.pageYOffset;
      window.onscroll = () => {
        let currentScrollPos = window.pageYOffset;
        if (prevScrollpos > currentScrollPos) {
          this.bottom = "0";
        } else {
          this.bottom = "-100px";
        }
        prevScrollpos = currentScrollPos;
      }
    },
  },
  mounted () {
    this.scroll();
    this.$store.dispatch("get_data");
  },
}
</script>

<style scoped>
.news-app-wrapper {
  padding-top: 30px;
}

.scrollable {
  overflow-y: scroll !important;
  max-height: 100vh;
}

::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
  background: #888;
}

::-webkit-scrollbar-thumb:hover {
  background: #555;
}

.header {
  color: #5f6368;
  margin: 10.5px 0;
}

.header i:hover {
  color: #2780e3;
}
</style>
</style>
