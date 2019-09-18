const observer = new IntersectionObserver(
  ([e]) => e.target.toggleAttribute('stuck', e.intersectionRatio < 1),
  {threshold: [1]}
);

jQuery(function() {
  Array.from(document.querySelectorAll('.day-title')).forEach(function(el) {
    observer.observe(el);
  })
})
