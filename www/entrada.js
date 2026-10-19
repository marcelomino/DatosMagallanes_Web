/* ═══════════════════════════════════════════════════════════════════════════
   entrada.js — La entrada (index.html)

   Una sola cosa, y ninguna cifra: "> entrar". La banda del prompt (la que se
   dibuja sobre la palabra al pasar, como texto seleccionado en una terminal)
   se estira hasta cubrir la pantalla, y recien entonces se navega. La otra
   mitad del viaje (la banda que se retira sobre la portada) es
   www/transicion.css. El giro del terreno es CSS puro.

   Sin JS, el prompt es un enlace comun. Bajo prefers-reduced-motion tambien:
   se entra sin banda.
   ═══════════════════════════════════════════════════════════════════════════ */
(function () {
  "use strict";

  var raiz = document.querySelector(".entrada");
  if (!raiz) return;
  var boton = raiz.querySelector(".entrada-prompt");
  var telon = raiz.querySelector(".entrada-telon");
  var banda = raiz.querySelector(".prompt-palabra");
  var quieto = window.matchMedia("(prefers-reduced-motion: reduce)");
  var yendo = null;

  // La curva de la banda del Boletin (--curva-mov en styles.css).
  var CURVA = "cubic-bezier(0.65, 0, 0.35, 1)";

  // ── Entrar ────────────────────────────────────────────────────────────
  // La banda se estira en dos tiempos, como una banda de imprenta: primero
  // corre de borde a borde a la altura de "entrar", y despues inunda la
  // pagina hacia arriba y hacia abajo.
  // Devuelve true si se hizo cargo de la navegacion.
  function entrar() {
    if (yendo) return true;
    // La portada sabe por esta marca que llega desde aqui (el respaldo sin
    // transicion nativa, en R/50_sitio.R).
    try { sessionStorage.setItem("dm-entrada", "1"); } catch (e) { /* sin almacenamiento */ }
    if (quieto.matches || !telon.animate || !banda) return false;

    // El telon arranca exactamente sobre la banda de "entrar": no aparece un
    // rectangulo nuevo, se estira el que ya estaba (en raton, ya dibujado por
    // el hover; en pantalla tactil, nace ahi mismo).
    var r = banda.getBoundingClientRect();
    var w = document.documentElement.clientWidth, h = window.innerHeight;
    var desde = "inset(" + r.top + "px " + (w - r.right) + "px " +
                (h - r.bottom) + "px " + r.left + "px)";
    var franja = "inset(" + r.top + "px 0px " + (h - r.bottom) + "px 0px)";

    raiz.classList.add("es-entrando");
    telon.style.visibility = "visible";
    yendo = telon.animate(
      [{ clipPath: desde, easing: CURVA },
       { clipPath: franja, offset: 0.46, easing: CURVA },
       { clipPath: "inset(0px 0px 0px 0px)" }],
      { duration: 820, fill: "forwards" }
    );
    yendo.finished.then(function () { window.location.href = boton.href; });
    return true;
  }

  boton.addEventListener("click", function (e) {
    // Abrir en otra pestana o ventana sigue siendo del lector.
    if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
    if (entrar()) e.preventDefault();
  });

  // Enter desde cualquier lugar de la pagina: no hay otra cosa que hacer aqui.
  document.addEventListener("keydown", function (e) {
    if (e.key !== "Enter" || e.target !== document.body) return;
    e.preventDefault();
    if (!entrar()) window.location.href = boton.href;
  });

  // Volver con "Atras" restaura la pagina desde la cache tal como quedo:
  // cubierta. Se la deja como estaba antes de pulsar.
  window.addEventListener("pageshow", function (e) {
    if (!e.persisted) return;
    if (yendo) { yendo.cancel(); yendo = null; }
    telon.style.visibility = "";
    raiz.classList.remove("es-entrando");
  });
})();
