<template lang="pug">
div
  .news-app-wrapper
    .container-fluid
      .row
        .col-sm-5.col-md-4.col-lg-3(v-show="loaded && wideLayout")
           .top-fixed.top-fixed--f1#sidebar(style="margin-top: 60px; overflow: auto !important")
             SideComponents
        .col-sm-7.col-md-8.col-lg-6
          a#top
          NewsItemWall(
             ref="niw"
             default-order="hot_score"
             sort-options="no_best"
             style="padding-left: 1rem, padding-right: 1rem"
             :fullLayout="!isMobile"
             :heldenUrl='heldenUrl'
           )
        .col-lg-3.visible-lg
          Subscribe
          Jobs(v-if="showJobs")
          Events
          .panel.panel-default.mt-2(style="position: sticky; top: 85px")
            .panel-body
              .row
                .col-xs-6(v-for="[key, path] in Object.entries(paths)")
                  .footer-item
                    a(:href="path" target= "_blank")
                      | {{ key }}
                .col-xs-6(v-if="twitter.length > 0")
                  .footer-item
                    a(:href="twitterUrl")
                      | Twitter
                      i.fa.fa-fw.fa-twitter
                .col-xs-6
                  .footer-item
                    a(href="/" style="color: #555")
                      | HRfilter.de&nbsp;
                    | &copy;&nbsp;{{ year }}



        template(v-if="loaded")
          SearchBar(:bottom="bottom" ref="searchBar")
          Modal(
            v-if="!wideLayout"
          )
          a.btn.btn-primary.back-to-top(:style="anchorPos" href="#top")
            i.fa.fa-chevron-up
</template>

<script>
import NewsItemWall from "./NewsItemWall";
import SearchBar from "./SearchBar";
import SideComponents from "./SideComponents";
import Modal from "./Modal"
import Jobs from "./Jobs";
import Events from "./Events"
import Subscribe from "./Subscribe"
import { mapGetters, mapState } from 'vuex';

export default {
  name: "FrontPage",
  props: {
    logo: { type: String, },
    showJobs: { type: Boolean },
    paths: { type: Object, required: true },
    twitter: { type: String, default: "" },
    year: { type: Number, required: true},
    heldenUrl: { type: String, required: false },
  },
  data() {
    return {
      bottom: "-100px",
      width: "0",
      aPos: "10px",
    }
  },
  components: {
    NewsItemWall,
    SearchBar,
    Jobs,
    SideComponents,
    Events,
    Modal,
    Subscribe,
  },
  computed: {
    ...mapGetters([
      'wideLayout',
      'isMobile'
    ]),
    ...mapState([
      'loaded',
    ]),
    anchorPos(){
      return {
        "bottom": this.aPos,
      }
    },
    twitterUrl() {
      return `https://twitter.com/${this.twitter}`
    },
  },
  methods: {
    scroll () {
      var prevScrollPos = window.pageYOffset;
      window.onscroll = () => {
	let bottomOfWindow = document.documentElement.scrollTop + window.innerHeight > document.documentElement.offsetHeight - 100;
        let currentScrollPos = window.pageYOffset;
        if(bottomOfWindow && !this.isMobile) this.$refs.niw.autoload();
        if(prevScrollPos > currentScrollPos){
          this.bottom = "0";
          if(!this.wideLayout) this.aPos = "60px";
        }
        else{
          this.bottom = "-100px";
          this.aPos = "10px";
        }
        prevScrollPos = currentScrollPos;
      }
    },
    resize() {
      window.onresize = () => {
        this.$store.commit("set_size", document.body.clientWidth);
        this.$nextTick(()=>{this.$refs.searchBar.calWidth()})
      }
    }
  },
  mounted () {
    this.resize();
    this.scroll();
    this.$store.commit("set_size", document.body.clientWidth);
    this.$store.dispatch("get_data");
  },
}
</script>

<style scoped>

.scrollable {
  overflow-y: scroll !important;
  max-height: 100vh;
}

::-webkit-scrollbar {
  display: none;
}

.header {
  color: #5f6368;
  margin: 10.5px 0;
}

.header i:hover {
  color: #2780e3;
}

.back-to-top {
  border-radius: 5px;
  position: fixed;
  right: 15px;
  background-color: #2780E3;
  border: none;
  z-index: 100;
  opacity: 0.7;
}

.footer-item {
  padding: 3px;
}

.row {
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display:         flex;
  flex-wrap: wrap;
}

.row > [class*='col-'] {
  display: flex;
  flex-direction: column;
}

</style>
