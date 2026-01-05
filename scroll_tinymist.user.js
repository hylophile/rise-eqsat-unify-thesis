// ==UserScript==
// @name        scroll tinymist
// @namespace   Violentmonkey Scripts
// @match       http://127.0.0.1:23635/*
// @grant       none
// @version     1.0
// @author      -
// @description 29/12/2025, 12.24.49
// ==/UserScript==

window.addEventListener("keydown", (e) => {
  let handled = true;
  const el = document.getElementById("typst-container-main");
  const scrollDelta = 50;
  switch (e.key) {
    case "ArrowDown":
      el.scrollBy({ top: scrollDelta, behavior: "instant" });
      break;
    case "ArrowUp":
      el.scrollBy({ top: -scrollDelta, behavior: "instant" });
      break;
    case "ArrowLeft":
      el.scrollBy({ top: -scrollDelta * 10, behavior: "smooth" });
      break;
    case "ArrowRight":
      el.scrollBy({ top: scrollDelta * 10, behavior: "smooth" });
      break;
    default:
      handled = false;
  }

  if (handled) {
    e.preventDefault();
  }
});
