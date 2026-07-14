document.addEventListener('DOMContentLoaded', () => {
  const animateElements = document.querySelectorAll('.animate-fade-in, .animate-slide-up');

  if (!animateElements.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px',
    }
  );

  animateElements.forEach((el) => observer.observe(el));
});
