<template>
  <span>
    <template v-if="!isVideo">
      <audio ref="audio" controls autoplay>
        <source :src="url" type="audio/mp3">
      </audio>
    </template>
    <div class="video-container" v-if="isVideo">
      <iframe frameborder="0" allowfullscreen="allowfullscreen" :src="url"/>
    </div>
  </span>
</template>

<script>
import { mapGetters } from 'vuex';

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
  methods: {
    pause() {
      if(!this.isVideo) {
        this.$refs.audio.pause();
      }
    },
  },
  computed: {
    ...mapGetters(['play']),
  },
  watch: {
    play: {
      handler() {
        this.pause();
      },
      deep: true
    }
  }
}
</script>

<style scoped>
audio {
  border-radius: 10px;
  width: 100%;
  min-height: 30px;
}

.video-container {
  position: relative;
  padding-bottom: 56.25%;
  padding-top: 0;
  height: 0;
  overflow: hidden;
}

.video-container iframe,
.video-container object,
.video-container embed {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
</style>
