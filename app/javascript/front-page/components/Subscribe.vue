<template lang="pug">
.card
  .img-wrapper
    img.bg-img(width="100%", :src="bgImage")
    .centered
      div(style="font-size: 1.7vw") Auf dem Laufenden bleiben
      div(style="font-size: 1.3vw") Per E-Mail die wichtigsten Beiträge monatlich/wöchentlich erhalten?
      div(style="font-size: 1.3vw") Dann tragen Sie sich hier ein. Das Abo ist kostenfrei und jederzeit mit einem Klick kündbar.
  form.card-body(@submit.prevent="subscribe()")
    .mail-wrapper
      input.mail(type="email" required placeholder="E-Mail Adresse" v-model="email" autocomplete="email" inputmode="email" @keyup.enter="subscribe()")
      p(v-if="error" style="margin: 0") Bitte geben Sie eine gültige E-Mail Adresse an.
  .card-footer
    button.btn.btn-secondary(@click="subscribe()" style="width: 100%" type="submit")
      i.fa.fa-fw.fa-envelope
      | Newsletter abonnieren
</template>

<script lang="ts" setup>
import qs from "qs"

import bgImage from "../../../assets/images/img.jpg"

function validEmail(email: string) {
  var re =
    /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  return re.test(email)
}
import { ref } from "vue"
const email = ref("")
const error = ref(false)

function subscribe() {
  const emailValue = email.value
  if (validEmail(emailValue) && emailValue) {
    const params = {
      mail_subscription: { email: emailValue },
    }
    window.location = `/newsletter?${qs.stringify(params)}`
  } else {
    error.value = true
  }
}
</script>

<style scoped>

.img-wrapper {
  position: relative;
  text-align: center;
  color: white;
  overflow: hidden;
}

.bg-img {
  filter: brightness(170%) contrast(70%) opacity(0.7) blur(2px);
  margin: -2px;
}

.centered {
  width: 100%;
  color: #444;
  position: absolute;
  top: 50%;
  left: 50%;
  font-weight: 500;
  transform: translate(-50%, -50%);
  text-shadow: 0 0 7px #eee;
  padding: 10px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.mail {
  font-size: 17px;
  height: 35px;
  width: 100%;
}
</style>
