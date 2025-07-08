<template lang="pug">
div(:class="wideLayout ? 'search-bar' : 'bottom-bar'", :style="{ bottom: bottom }")
  span.icon(v-show="wideLayout")
    i.fa.fa-search.fa-lg
  input#search.form-control(
    :style="customWidth"
    autocomplete="off"
    type="text"
    placeholder="Was suchen Sie?"
    v-model="localQuery"
    @keyup.enter="buildPayload()"
    @blur="buildPayload()")
  template(v-if="!wideLayout")
    button(:class="expand ? 'btn btn-cat disabled' : 'btn btn-cat'" data-bs-toggle="modal" data-bs-target="#opModal")
      i.fa.fa-bars.fa-lg(aria-hidden="true")
</template>

<script setup lang="ts">
import { wideLayout } from "utils/device"

defineProps({
  bottom: { type: String, default: "0" },
  expand: { type: Boolean, default: false },
})
import { ref, computed, onMounted, watch } from "vue"
import { query } from "@/front-page/filter"

const localQuery = ref(query.value)
watch(query, (val) => {
  localQuery.value = val
})

const width = ref("250px")
const customWidth = computed(() => {
  if (!wideLayout.value) return ""
  return {
    width: width.value,
  }
})
function buildPayload() {
  query.value = localQuery.value
}
function calWidth() {
  let sb = document.getElementById("sidebar")
  if (sb != null) {
    width.value = `${sb.clientWidth - 30}px`
  }
}
onMounted(() => {
  calWidth()
})
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
  box-shadow: 0px 10px white;
  height: 50px;
  vertical-align: middle;
  white-space: nowrap;
  position: fixed;
  max-width: 200px;
  top: 95px !important;
  left: 15px;
  z-index: 1000;
}

.search-bar input#search {
  height: 50px;
  float: left;
  padding-left: 35px;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 5px;
  border: 1px solid #4f5b66;
  color: #000;
}

.search-bar input#search::-webkit-input-placeholder {
  color: #65737e;
}

.search-bar input#search:-moz-placeholder {
  /* Firefox 18- */
  color: #65737e;
}

.search-bar input#search::-moz-placeholder {
  /* Firefox 19+ */
  color: #65737e;
}

.search-bar input#search:-ms-input-placeholder {
  color: #65737e;
}

.search-bar .icon {
  position: absolute;
  top: 13px;
  left: 15px;
  z-index: 10;
  color: grey;
}

.search-bar input#search:focus,
.search-bar input#search:active {
  outline: none;
}

.disabled {
  border-color: grey !important;
  color: grey !important;
  opacity: 0.3 !important;
}
</style>
