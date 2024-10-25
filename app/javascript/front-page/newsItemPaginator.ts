import { ref, computed, watch } from "vue"
import { params } from "front-page/filter"
import qs from "qs"

const firstLoad = ref(true)
const page = ref(0)
const loading = ref(false)

const newsItems = ref([])
const newsItemsLoading = ref([])

const order = ref("all_best")
const limit = ref(30)

const meta = ref({
  current_page: 0,
  pages: 0,
})

function refresh() {
  page.value = 1
  return loadNextPage(true)
}
function loadNextPage(clearNewsItem = false) {
  loading.value = true
  let lpage = 1
  if (!clearNewsItem) {
    lpage = page.value + 1
    newsItemsLoading.value = newsItems.value
  }
  const params = {
    ...searchParams.value,
    page: lpage,
  }
  const keys = Object.keys(params) as Array<keyof typeof params>
  keys.forEach((key) => {
    if (params[key] === "" || params[key] === undefined || params[key] == null) {
      delete params[key]
    }
  })
  return fetch(`/api/v1/news_items.json?${qs.stringify(params)}`)
    .then((stream) => stream.json())
    .then((data) => {
      if (clearNewsItem) {
        newsItems.value = data.news_items
      } else {
        // newsItems.push(...data.news_items)
        newsItems.value = newsItems.value.concat(data.news_items)
      }
      meta.value = data.meta
      newsItemsLoading.value = []
      loading.value = false
      page.value = lpage
      return true
    })
    .catch((error) => console.error(error))
}
const hasNextPage = computed(() => {
  return meta.value && meta.value.current_page && meta.value.current_page < meta.value.pages
})
const searchParams = computed(() => {
  const lParams = {
    ...params.value,
    order: order.value,
    limit: limit.value,
  }
  return lParams
})
function handleHistory() {
  const newState = {
    ...history.state,
    params: searchParams.value,
    lastScrollPosition: window.scrollY,
    page: page.value,
  }
  history.pushState(newState, "", location.href)
}

function loadDataForParams () {
  if (loading.value) return
  if (firstLoad.value) {
    loadPages(history.state?.page || 1)
    firstLoad.value = false
  } else {
    refresh()
  }
}
watch(
  params,
  () => {
    loadDataForParams()
  },
  { deep: true }
)
watch(order, () => {
  refresh()
})

function deleteHistory() {
  delete history.state.params
  delete history.state.lastScrollPosition
  delete history.state.page
  history.replaceState({}, "", location.href)
}
function setScrollPosition(position: number) {
  window.scrollTo(0, position)
}
function scrollToLastPosition() {
  if (typeof history.state?.lastScrollPosition !== "number") return
  setScrollPosition(history.state.lastScrollPosition)
  deleteHistory()
}
async function loadPages(pages: number) {
  if (pages < 1) {
    scrollToLastPosition()
    return
  }
  await loadNextPage()
  await loadPages(pages - 1)
}

function autoload() {
  if (loading.value == false && hasNextPage.value) {
    loadNextPage()
  }
}

export { handleHistory, loading, order, refresh, autoload, newsItems, newsItemsLoading, hasNextPage, loadNextPage, loadDataForParams }
