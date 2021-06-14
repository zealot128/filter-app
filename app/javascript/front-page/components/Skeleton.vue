<template lang="pug">
  .skeleton-box
    .skeleton-box--title
    .skeleton-box--content
    .skeleton-box--content
    .skeleton-box--footer
</template>

<style scoped>
.skeleton-box {
  width: 100%;
  height: 180px;
  border: 1px solid #ddd;
  box-shadow: 0 5px 6px #ccc;
  padding: 15px;
  margin-bottom: 2rem;
}
.skeleton-box--title {
  width: 70%;
  height: 30px;
  animation: pulse 1.5s infinite;
}
.skeleton-box--content {
  width: 100%;
  height: 20px;
  margin-top: 1rem;
  animation: pulse 1.5s infinite;
}
.skeleton-box--footer {
  width: 20%;
  height: 15px;
  margin-top: 4rem;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0% {
    background-color: rgba(165, 165, 165, 0.1);
  }
  50% {
    background-color: rgba(165, 165, 165, 0.3);
  }
  100% {
    background-color: rgba(165, 165, 165, 0.1);
  }
}

</style>