document.addEventListener("click", function (e) {
  const target = e.target.closest(".ripple");
  if (!target) return;

  const rect = target.getBoundingClientRect();
  const ripple = document.createElement("span");

  const size = Math.max(rect.width, rect.height);
  const x = e.clientX - rect.left - size / 2;
  const y = e.clientY - rect.top - size / 2;

  ripple.style.width = ripple.style.height = `${size}px`;
  ripple.style.left = `${x}px`;
  ripple.style.top = `${y}px`;
  ripple.className = "ripple-effect";

  target.appendChild(ripple);
  setTimeout(() => ripple.remove(), 600);
});
