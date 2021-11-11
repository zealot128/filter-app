<template lang="pug">
.panel.panel-default  
  .img-wrapper
    img.bg-img(width="100%" :src='require("../../../assets/images/img.jpg")')
    .centered
      div(style="font-size: 1.7vw") Auf dem Laufenden bleiben
      div(style="font-size: 1.3vw") Per E-Mail die wichtigsten Beiträge monatlich/wöchentlich erhalten?
      div(style="font-size: 1.3vw") Dann tragen Sie sich hier ein. Das Abo ist kostenfrei und jederzeit mit einem Klick kündbar.
  .panel-body
    .mail-wrapper
      input.mail(
        type="email"
        required="required"
        placeholder="E-Mail Adresse" 
        autocomplete="off"
        v-model="email"
      )
      p(v-if="error" style="margin:0") Bitte geben Sie eine gültige E-Mail Adresse an.
  .panel-footer
    a.btn.btn-default(@click="subscribe()" style="width: 100%")
      i.fa.fa-fw.fa-envelope-o
      | Newsletter abonnieren

</template>

<script>
const qs = require("qs");

export default {
  methods: {
    subscribe() {
      if (this.validEmail(this.email) && this.email) {
        const params = {
          mail_subscription: { email: this.email },
        };
        window.location = `/newsletter?${qs.stringify(params)}`;
      } else this.error = true;
    },
    validEmail(email) {
      var re =
        /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      return re.test(email);
    },
  },
  data() {
    return {
      email: "",
      error: false,
    };
  },
};
</script>

<style scoped>
.panel {
  margin-top: 1rem;
}

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
