<template>
  <div>
    <template v-if="!isVideo">
      <audio controls>
        <source :src="url" type="audio/mp3">
      </audio>
    </template>
    <template v-if="isVideo">
      <iframe width="854" height="480" :src="url">
      </iframe>
    </template>
  </div>
</template>

<script>
export default {
  props: {
    url: {
      type: String,
      required: true
    },
    isVideo: {
      type: Boolean,
      required: true
    }
  },
}
</script>

<style scoped>
audio {
  width: 500px;
}
</style>