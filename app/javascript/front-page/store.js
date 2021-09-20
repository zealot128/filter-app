import Vue from "vue"
import Vuex from "vuex"

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    chosenCat: [],
    categories: [],
    chosenTypes: [],
    chosenTrends: [],
    mediaTypes: [],
    loaded: false,
    params: {},
    query: null,
    play: false,
    trends: [],
  },
  mutations: {
    set_categories(state, cat) {
      state.categories = cat
    },
    set_loaded(state) {
      state.loaded = true
    },
    set_query(state, query) {
      state.query = query
    },
    set_play(state, bool) {
      state.play = bool
    },
    set_media_types(state, media_types) {
      state.mediaTypes = media_types.map(el => ({ id: el, name: el }))
    },
    set_trends(state, trends) {
      state.trends = trends
    },
    set_chosen_cat(state, categories) {
      state.chosenCat = categories
    },
    set_chosen_type(state, types) {
      state.chosenTypes = types
    },
    set_chosen_trend(state, types) {
      state.chosenTrends = types
    },
    set_params_based_on_state(state) {
      state.params = {
        categories: state.chosenCat.join(","),
        media_type: state.chosenTypes.join(","),
        trend: state.chosenTrends.join(","),
      }
      if (state.query) {
        state.params.query = state.query
      }
    },
    set_params_based_on_data(state, params) {
      state.params = params
      if (params.query) state.query = params.query
      if (params.categories)
        state.chosenCat = params.categories.split(",").map(Number)
      if (params.media_type)
        state.chosenTypes = params.media_type.split(",")
      if (params.trend)
        state.chosenTrends = params.trend.split(",")
    },
    expand_params_based_on_data(state, params) {
      state.params = {
        ...state.params,
        ...params,
      }
    },
  },
  actions: {
    get_categories(context) {
      fetch("/api/v1/categories.json")
        .then((stream) => stream.json())
        .then((data) => {
          context.commit("set_categories", data.categories)
        })
        .catch((error) => console.error(error))
    },
    get_media_types(context) {
      fetch("/api/v1/sources/media-types")
        .then((stream) => stream.json())
        .then((data) => {
          context.commit("set_media_types", data)
        })
        .catch((error) => console.error(error))
    },
    get_trends(context) {
      fetch(`/js/trends.json`)
        .then((stream) => stream.json())
        .then((data) => {
          context.commit("set_trends", data.month)
        })
        .catch((error) => console.error(error))
    },
    get_data(context) {
      context.dispatch("get_categories")
      context.dispatch("get_media_types")
      context.dispatch("get_trends")
      context.commit("set_loaded")
    },
    build_params(context) {
      context.commit("set_params_based_on_state")
    },
    play_or_pause(context, bool) {
      context.commit("set_play", bool)
    },
  },
  modules: {},
  getters: {
    isMobile: () => {
      return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
        navigator.userAgent
      )
    },
    wideLayout: () => {
      return document.body.clientWidth > 767
    },
    play: (state) => {
      return state.play
    },
    isChosen: (state) => (id) => {
      asdasdasd
      return state.chosenCat.includes(id)
    },
    isChosenType: (state) => (type) => {
      return state.chosenTypes.includes(type)
    },
    typeTitle: () => (type) => {
      if (type === "FeedSource") return "Artikel"
      return type.replace("Source", "")
    },
  },
})
