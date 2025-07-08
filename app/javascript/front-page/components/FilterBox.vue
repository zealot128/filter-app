<template lang="pug">
.filter-box.mt-1.mb-2
  .header
    | {{ title }}
    button.btn.btn-sm.btn-link(
      @click='reset'
      type='button'
      :disabled='value.length == 0'
    )
      i.fa.fa-trash.fa-lg

  hr.mt-1.mb-1.p-0
  .filter-wrapper
    div.btn.btn-sm.btn-filter(
      v-for="item in items"
      @click="toggle(item)"
      :class="{'selected' : isSelected(item.id)}"
    )
      slot(:item="item")
        span
          | {{ item.name }}
</template>

<script>
export default {
  props: {
    title: { type: String, required: true },
    items: { type: Array, required: true },
    value: { type: Array, required: true },
  },
  methods: {
    isSelected(id) {
      return this.value.some((e) => e.id == id)
    },
    toggle(item) {
      this.resetScroll();
      if (this.isSelected(item.id)) {
        const newVal = this.value.filter((el) => el.id != item.id)
        this.$emit("input", newVal)
      } else {
        this.$emit("input", [...this.value, item])
      }
    },
    reset() {
      this.resetScroll();
      this.$emit("input", [])
    },
    resetScroll() {
      window.scrollTo(0, 0);
    }
  },
}
</script>

<style scoped>
.filter-box {
  background: #f8f9fa;
  padding: 5px 10px;
}
.filter-box .header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.filter-box .btn:not(.disabled) {
  color: #555;
}
.filter-wrapper {
  display: flex;
  align-content: flex-start;
  flex-wrap: wrap;
}
* >>> .category-thumb {
  width: 22px;
  height: 22px;
  margin-left: 3px;
}
.header {
  color: #5f6368;
  margin: 10.5px 0;
}

.header i:hover {
  color: #2780e3;
}

.btn-filter {
  color: #5f6368;
  margin: 0.3rem;
  border: 1px solid #dadce0;
  border-radius: 5px;
  background: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.btn-filter:hover {
  box-shadow: 0 1px 5px 0 rgba(0, 0, 0, 0.1);
  color: #3c4043;
  border-color: #b2b3b5;
}
.btn-filter.selected {
  border: 1px solid black;
}
</style>
