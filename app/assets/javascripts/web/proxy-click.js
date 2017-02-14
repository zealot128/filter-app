

$(document).on('mousedown', '[data-proxy]', (e) => {
 if (e.target && e.target.dataset.proxy) {
   e.target.href = e.target.dataset.proxy;
  }
});
