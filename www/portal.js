/* ═══════════════════════════════════════════════════════════════════════════
   portal.js — La entrada de las seis series del pulso de la portada

   Bajo prefers-reduced-motion los trazos quedan dibujados de inmediato.
   ═══════════════════════════════════════════════════════════════════════════ */
(function () {
  "use strict";

  // ── La entrada de las seis series del pulso ──────────────────────────────
  // El pulso vive bajo la linea de flotacion. Si sus trazos se dibujaran al
  // cargar la pagina, la unica animacion del bloque ocurriria fuera de cuadro
  // y nadie la veria nunca: para cuando el lector llega, ya termino. Se deja
  // en pausa y se suelta cuando la retícula entra en pantalla.
  function armarPulso() {
    var rejilla = document.querySelector(".pulso");
    if (!rejilla || rejilla.dataset.armado) return;
    rejilla.dataset.armado = "1";
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches ||
        !("IntersectionObserver" in window)) {
      rejilla.classList.add("es-trazado");
      return;
    }
    var obs = new IntersectionObserver(function (ent) {
      if (!ent[0].isIntersecting) return;
      rejilla.classList.add("es-trazado");
      obs.disconnect();
    }, { threshold: 0.22 });
    obs.observe(rejilla);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", armarPulso);
  } else {
    armarPulso();
  }
  // Reintento por si el script corre antes de que el pulso este en el DOM.
  setTimeout(armarPulso, 400);
})();
