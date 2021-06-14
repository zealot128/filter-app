<template lang="pug">
  div(:class='wideLayout ? "search-bar" : "bottom-bar"' :style="cssVar")
    span.icon(v-show="wideLayout")
      i.fa.fa-search.fa-lg
    input#search(
      type="text"
      class="form-control"
      placeholder="Was suchen Sie?"
      v-model="query"
      @keyup.enter="buildPayload()")
    template(v-if="!wideLayout")
      button(:class='expand ? "btn btn-cat disabled" : "btn btn-cat"' data-toggle="modal" data-target="#opModal")
        i.fa.fa-bars.fa-lg(aria-hidden="true")
</template>

<script>
import { mapMutations, mapGetters, mapState } from 'vuex';

export default {
  props: {
    bottom: { type: String, default: "0" },
    expand: {type: Boolean, default: false},
  },
  computed: {
    ...mapGetters([
      'wideLayout',
    ]),
    ...mapState({
      storeQuery: 'query',
    }),
    query: {
      get() {
        return this.storeQuery;
      },
      set(value) {
        this.set_query(value);
      }
    },
    cssVar() {
      return {
        'bottom': this.bottom
      }
    },
  },
  methods: {
    ...mapMutations(['set_query']),
    buildPayload() {
      (this.expand) ? (this.$store.commit("expand_params_based_on_data", {query: this.storeQuery})) : (this.$store.dispatch("build_params"));
    },
  },
}
</script>

<style scoped>
.bottom-bar {
  display: flex;
  justify-content: space-between;
  background: #b9b9b9;
  padding: 5px 15px 5px 15px;
  width: 100%;
  transition: bottom 0.1s;
  position: fixed;
  left: 0;
  z-index: 1002;
}

input {
  margin-right: 1.5rem;
  outline: none;
  border-radius: 3px;
}

.btn-cat {
  color: #333;
  background: white;
  border: 1px solid black;
  border-radius: 3px;
}

.btn:focus {
  outline: 0;
}

.btn-cat:hover {
  background: #f8f9fa;
}

.search-bar {
  width: 300px;
  height: 50px;
  vertical-align: middle;
  white-space: nowrap;
  position: fixed;
  top: 10px !important;
  right: 20px;
}

.search-bar input#search{
  width: 50px;
  height: 50px;
  float: right;
  padding-left: 35px;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 9999px;
  border: 2px solid #4f5b66;
  color: #000;

  -webkit-transition: width .55s ease;
  -moz-transition: width .55s ease;
  -ms-transition: width .55s ease;
  -o-transition: width .55s ease;
  transition: width .55s ease;
}

.search-bar input#search::-webkit-input-placeholder {
  color: #65737e;
}

.search-bar input#search:-moz-placeholder { /* Firefox 18- */
  color: #65737e;
}

.search-bar input#search::-moz-placeholder {  /* Firefox 19+ */
  color: #65737e;
}

.search-bar input#search:-ms-input-placeholder {
  color: #65737e;
}

.search-bar .icon{
  position: absolute;
  top: 13px;
  right: 33px;
  z-index: 1;
  color: grey;
}

.search-bar input#search:focus, .search-bar input#search:active{
  outline:none;
  width: 300px;
}

.search-bar:hover input#search{
  width: 300px;
}

.search-bar:hover .icon{
  color: #93a2ad;
}

.disabled {
  border-color: grey !important;
  color: grey !important;
  opacity: 0.3 !important;
}

</style>
