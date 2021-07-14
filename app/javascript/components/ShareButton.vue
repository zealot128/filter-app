<template>
  <a :href="shareProxy" :title="'Auf ' + network.charAt(0).toUpperCase() + network.slice(1) +' teilen.'" @click.prevent.stop='openInPopup'>
    <div v-html='icon'>
    </div>
  </a>
</template>

<script>
import json from './icons.json'

export default {
  props: {
    network: {
      type: String,
      required: true
    },
    title: {
      type: String,
      required: true
    },
    url: {
      type: String,
      required: true
    },
    id: {
      type: Number, required: true,
    }
  },
  methods: {
    openInPopup() {
      this.popupWindow = window.open(
        this.shareProxy,
        'sharer',
        ',height=626'+
        ',width=436'+
        ',left=0' +
        ',top=0' +
        ',screenX=0' +
        ',screenY=0'
      )

      // If popup are prevented (AdBlocker, Mobile App context..), popup.window stays undefined and we can't display it
      if (!this.popupWindow) return

      this.popupWindow.focus()
    }
  },
  computed: {
    shareProxy() {
      return `/share/${this.id}/${this.network}`;
    },
    icon() {
      return json[this.network];
    }
  }
}
</script>

<style scoped>

</style>