import { ref } from "vue"
const categories = ref([])

const mediaTypes = ref([])


const loaded = ref(false)

const loadAll = async () => {

  const promises = [
    fetch("/api/v1/categories.json")
      .then((stream) => stream.json())
      .then((data) => {
        categories.value = data.categories
      })
      .catch((error) => console.error(error))
    ,
    fetch("/api/v1/sources/media-types")
      .then((stream) => stream.json())
      .then((data) => {
        mediaTypes.value = data
      })
      .catch((error) => console.error(error)),
  ]

  await Promise.all(promises)
  loaded.value = true
}


export {
  categories,
  mediaTypes,
  loaded,
  loadAll
}

