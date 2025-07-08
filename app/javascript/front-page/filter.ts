import { ref, computed } from "vue"

const chosenMediaType = ref("")
const chosenCat = ref([])
const query = ref("")
const sourceId = ref(null)
const isPlaying = ref(false)

const params = computed(() => {
  const base = {
    categories: chosenCat.value.join(","),
    media_type: chosenMediaType.value,
    query: query.value,
    source_id: sourceId.value,
  }
  return base
})

function setParamsBasedOnData(newParams: any) {
  if (newParams.query) query.value = newParams.query
  if (newParams.categories) {
    chosenCat.value = newParams.categories.split(",").map(Number)
  }
  if (newParams.media_type) {
    chosenMediaType.value = newParams.media_type
  }
  if (newParams.source_id) {
    sourceId.value = newParams.source_id
  }
}

export {
  chosenMediaType,
  chosenCat,
  query,
  params,
  isPlaying,
  setParamsBasedOnData,
}
