import { computed, ref } from 'vue'

const size = ref(document.body.clientWidth)
window.onresize = () => {
  size.value = document.body.clientWidth
}

const wideLayout = computed(() => {
  return size.value > 767
})

const isMobile = computed(() => {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  )
})

export {
  wideLayout,
  isMobile
}
