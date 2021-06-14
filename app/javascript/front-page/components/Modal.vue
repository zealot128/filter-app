<template lang="pug">
  .modal.fade#opModal(
    role="dialog"
    aria-hidden="true"
    ref='modal'
  )
    .modal-dialog
      .modal-content
        .modal-header
          button.close(type="button" data-dismiss="modal" aria-hidden="true")
            | &times;
          h4.modal-title Filter auswählen
        .modal-body
          side-components(@select='closeModal')

</template>

<script>
import SideComponents from "./SideComponents.vue"

export default {
  components: { SideComponents },
  methods: {
    closeModal() {
      $(this.$refs.modal).modal("hide")
    },
  },
}
</script>

<style scoped></style>
