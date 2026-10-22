// ═════════════════════════════════════════════════════════════════════════════
// js/sitio.js — El comportamiento de las paginas
//
// Cinco tareas (en el dashboard Shiny las cumplian los mod_*_server):
//
//   1. Montar cada lamina cuando el lector abre su entrada, y no antes: un
//      grafico dentro de un panel cerrado mide cero.
//   2. El conmutador "Eje desde cero" de cada pieza y la descarga del CSV del
//      rango.
//   3. Los rangos de anos que comparten II.1/II.2 y III.1/III.2, y el selector
//      de censo de I.3 (un rango de un solo ano)
//      y el de la piramide de I.2, que suma la opcion Superpuestos.
//   4. El filtro y la busqueda de las fichas del capitulo VI.
//   5. La navegacion: el indice colgado de cada pestana y las direcciones de
//      cita en la URL (economia.html#cuadro-II-1, metodologia.html?pieza=215).
//      Los enlaces ya traen su href real desde R; aqui solo se despliega la
//      entrada y se desplaza hasta ella. Abrir una pieza a mano la acomoda
//      igual y deja su direccion en la URL.
//
// NINGUNA CIFRA SE CALCULA AQUI. Cada dibujo viene hecho desde R (ver lienzo()
// en R/30_ui_components.R); este archivo solo elige cual mostrar.
// ═════════════════════════════════════════════════════════════════════════════
(function () {
  'use strict';

  var $$ = function (sel, raiz) {
    return Array.prototype.slice.call((raiz || document).querySelectorAll(sel));
  };

  // ── 1. Las laminas ─────────────────────────────────────────────────────────

  // Los formateadores de eje_cifra(), tip_eje() y compania viajan como texto,
  // y `evals` dice donde estan. Es lo que hace htmlwidgets
  // (HTMLWidgets.evaluateStringMember) antes de entregarle el widget al binding
  // de echarts4r: recorrer cada ruta y evaluar el texto como funcion.
  function evaluar(o, ruta) {
    var partes = ruta.split('.');
    for (var i = 0; i < partes.length; i++) {
      var p = partes[i];
      if (o === null || typeof o !== 'object' || !(p in o)) return;
      if (i === partes.length - 1) {
        if (typeof o[p] === 'string') o[p] = eval('(' + o[p] + ')');
      } else o = o[p];
    }
  }

  var graficos = {};   // id del lienzo -> instancia de ECharts

  function datosDe(lienzo) {
    if (!lienzo._datos) {
      var s = document.querySelector('script[data-for="' + lienzo.id + '"]');
      lienzo._texto = s.textContent;
      lienzo._datos = JSON.parse(lienzo._texto);
    }
    return lienzo._datos;
  }

  // La clave del rango vigente de un grupo ("2018-2023"). Si el lector invierte
  // el rango se intercambian, en vez de dejar el cuadro vacio. Un selector de
  // ano suelto (corte_anio() en R) es el rango de un solo ano: "2017-2017".
  function claveRango(grupo) {
    var u = document.getElementById(grupo + '-anio');
    if (u) return u.value + '-' + u.value;
    var d = document.getElementById(grupo + '-anio_desde');
    var h = document.getElementById(grupo + '-anio_hasta');
    var a = Number(d.value), b = Number(h.value);
    return Math.min(a, b) + '-' + Math.max(a, b);
  }

  // El dibujo que corresponde al estado de los controles de la pieza.
  function dibujoDe(lienzo) {
    var datos = datosDe(lienzo);
    var rango = lienzo.dataset.rango ? claveRango(lienzo.dataset.rango) : 'todo';
    var variantes = datos.dibujos[rango];
    var cero = lienzo.dataset.cero ? document.getElementById(lienzo.dataset.cero) : null;
    var clave = cero ? (cero.checked ? 'si' : 'no') : 'fijo';
    // Se parte de una copia fresca: evaluar modifica el objeto, y el mismo
    // dibujo se puede volver a pedir.
    var v = JSON.parse(JSON.stringify(variantes[clave]));
    [].concat(v.evals || []).forEach(function (r) { evaluar(v.opts, r); });
    return v.opts;
  }

  function dibujar(lienzo) {
    var g = graficos[lienzo.id];
    if (!g) {
      // Registrar el tema es idempotente; asegura que exista aunque el primer
      // dibujo le gane al reintento de script_tema_echarts().
      if (window.DM && DM.tema) echarts.registerTheme('catalogo', DM.tema);
      g = echarts.init(lienzo, 'catalogo');
      graficos[lienzo.id] = g;
    }
    // notMerge: un dibujo reemplaza al anterior. Fusionarlos dejaria en pie el
    // min o el intervalo del eje del estado anterior.
    g.setOption(dibujoDe(lienzo), true);
  }

  // Se dibuja al terminar de abrirse la entrada, no al empezar: recien ahi el
  // lienzo tiene ancho.
  document.addEventListener('shown.bs.collapse', function (e) {
    $$('.lamina-lienzo', e.target).forEach(function (l) {
      if (graficos[l.id]) graficos[l.id].resize(); else dibujar(l);
    });
  });

  window.addEventListener('resize', function () {
    Object.keys(graficos).forEach(function (id) { graficos[id].resize(); });
  });

  // ── 2 y 3. El conmutador del cero y el rango de anos ──────────────────────
  // Un control solo redibuja lo que ya esta dibujado; lo que sigue plegado
  // tomara el estado vigente cuando se abra.
  document.addEventListener('change', function (e) {
    var el = e.target;
    $$('.lamina-lienzo').forEach(function (l) {
      if (!graficos[l.id]) return;
      var esCero  = l.dataset.cero && el.id === l.dataset.cero;
      var esRango = l.dataset.rango &&
        (el.id === l.dataset.rango + '-anio_desde' || el.id === l.dataset.rango + '-anio_hasta' ||
         el.id === l.dataset.rango + '-anio');
      if (esCero || esRango) dibujar(l);
    });
  });

  // La descarga de una pieza con rango: el CSV del rango que el cuadro muestra,
  // armado en R al construir. La BOM se agrega aqui (ver texto_csv()).
  document.addEventListener('click', function (e) {
    var a = e.target.closest('a[data-descarga-de]');
    if (!a) return;
    e.preventDefault();
    var lienzo = document.getElementById(a.dataset.descargaDe);
    var csv = datosDe(lienzo).csv[claveRango(lienzo.dataset.rango)];
    var url = URL.createObjectURL(new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8' }));
    var tmp = document.createElement('a');
    tmp.href = url; tmp.download = a.getAttribute('download');
    document.body.appendChild(tmp); tmp.click(); tmp.remove();
    setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
  });


  // ── 4. Las fichas del capitulo VI ─────────────────────────────────────────
  function filtrarFichas() {
    var sec = document.getElementById('met-filtro_sec');
    var caja = document.getElementById('met-busqueda');
    if (!sec || !caja) return;
    var t = caja.value.trim().toLowerCase();
    var items = $$('.fichas-acc > .accordion-item');
    var n = 0;
    items.forEach(function (it) {
      // accordion_panel() deja los atributos data-* en el cuerpo del asiento.
      var d = it.querySelector('.accordion-body').dataset;
      var ok = (sec.value === 'Todas' || d.seccion === sec.value) &&
               (!t || d.buscar.indexOf(t) !== -1);
      it.hidden = !ok;
      if (ok) n++;
    });
    document.getElementById('met-cuenta').textContent =
      n === items.length ? n + ' asientos' : n + ' de ' + items.length + ' asientos';
    document.querySelector('.fichas .vacio').hidden = n > 0;
  }

  // La busqueda espera 300 ms de pausa antes de filtrar.
  var espera;
  document.addEventListener('input', function (e) {
    if (e.target.id !== 'met-busqueda') return;
    clearTimeout(espera); espera = setTimeout(filtrarFichas, 300);
  });
  document.addEventListener('change', function (e) {
    if (e.target.id === 'met-filtro_sec') filtrarFichas();
  });

  // ── 5. Navegacion ─────────────────────────────────────────────────────────

  // Sin movimiento si el lector lo pidio: el salto llega igual, sin deslizarse.
  function desplazamiento() {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth';
  }

  // Abrir una pieza a mano hace lo mismo que llegar por su direccion: la
  // cabecera sube a la vista y la barra del navegador toma la direccion de cita
  // (economia.html#cuadro-II-3), lista para copiarla. replaceState y no
  // pushState: abrir cinco piezas no deja cinco pasos en "Atras", y no dispara
  // hashchange. Al plegarla, la direccion se retira si era la suya. Se acomoda
  // al terminar de abrir (shown) y no al empezar: con el cuerpo aun plegado,
  // una pieza al final de la pagina no tiene recorrido para subir.
  document.addEventListener('shown.bs.collapse', function (e) {
    var item = e.target.closest('.piezas-acc > .accordion-item');
    if (!item || !item.id) return;
    item.scrollIntoView({ block: 'start', behavior: desplazamiento() });
    if (location.hash !== '#' + item.id) history.replaceState(null, '', '#' + item.id);
  });
  document.addEventListener('hide.bs.collapse', function (e) {
    var item = e.target.closest('.piezas-acc > .accordion-item');
    if (item && item.id && location.hash === '#' + item.id)
      history.replaceState(null, '', location.pathname + location.search);
  });

  // Abrir la entrada de una pieza y llevar al lector hasta ella. La entrada
  // cuyo valor es el ancla es la de ese cuadro (ver pieza_cuadro()).
  function abrir(selector, destino) {
    var item = document.querySelector(selector);
    if (!item) return;
    var btn = item.querySelector('.accordion-button');
    // El ancla vive en la entrada (pieza_cuadro()): se aterriza sobre su
    // cabecera, con direccion y nombre a la vista, y el foco queda en el boton
    // que la nombra, que es lo que un lector de pantalla anuncia.
    var ir = function () {
      var el = document.getElementById(destino) || item;
      el.scrollIntoView({ block: 'start', behavior: desplazamiento() });
      if (btn) btn.focus({ preventScroll: true });
      else { el.setAttribute('tabindex', '-1'); el.focus({ preventScroll: true }); }
    };
    if (btn && btn.classList.contains('collapsed')) { btn.click(); setTimeout(ir, 420); }
    else ir();
  }

  function seguirAncla() {
    var ancla = decodeURIComponent(location.hash.replace(/^#/, ''));
    if (/^cuadro-/.test(ancla))
      abrir('.piezas-acc .accordion-item[data-value="' + ancla + '"]', ancla);
  }
  window.addEventListener('hashchange', seguirAncla);

  // Del cuadro a su ficha: metodologia.html?pieza=215 (el href del enlace "Ver
  // ficha tecnica detallada") deja esa ficha sola en la busqueda y la abre. El
  // lector ve por que la lista quedo en un solo asiento.
  function seguirPieza() {
    var pieza = new URLSearchParams(location.search).get('pieza');
    var caja = document.getElementById('met-busqueda');
    if (!pieza || !caja) return;
    caja.value = pieza;
    filtrarFichas();
    abrir('.fichas-acc [data-value="ind_' + pieza + '"]', null);
  }

  // Un enlace a un cuadro de la misma pagina no recarga: se cambia el ancla y
  // se abre la entrada aqui mismo, aunque el ancla ya fuera esa (sin
  // hashchange). A otra pagina, el enlace navega normalmente.
  function irDentro(a, e) {
    var u = new URL(a.href, location.href);
    if (u.pathname !== location.pathname || !u.hash) return;
    e.preventDefault();
    history.pushState(null, '', u.hash);
    seguirAncla();
  }

  // El menu de telefono (menu_movil()). Abre y cierra solo, por ser <details>;
  // aqui se cierra con Escape, al tocar fuera, al elegir un enlace o al volver
  // a ancho de escritorio, y mientras esta abierto el fondo no se desplaza.
  function enlazarMenuMovil() {
    var menu = document.querySelector('.menu-movil');
    if (!menu) return;
    var boton = menu.querySelector('.menu-movil-boton');
    var raiz = document.documentElement;
    var barra = document.querySelector('.navbar');
    // La barra es fija en telefono: su alto dice donde empieza el panel y cuanto
    // margen deja un cuadro al saltar a su ancla (scroll-margin-top).
    function medir() {
      raiz.style.setProperty('--alto-barra', barra.offsetHeight + 'px');
    }
    function cerrar(devolverFoco) {
      if (!menu.open) return;
      menu.open = false;
      if (devolverFoco) boton.focus();
    }
    medir();
    window.addEventListener('resize', medir);
    menu.addEventListener('toggle', function () {
      if (menu.open) medir();
      raiz.classList.toggle('menu-abierto', menu.open);
    });
    menu.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') cerrar(true);
    });
    document.addEventListener('click', function (e) {
      if (menu.open && !menu.contains(e.target)) cerrar(false);
    });
    $$('.menu-movil-panel a', menu).forEach(function (a) {
      a.addEventListener('click', function (e) { cerrar(false); irDentro(a, e); });
    });
    window.matchMedia('(min-width: 769px)').addEventListener('change', function (m) {
      if (m.matches) cerrar(false);
    });
  }

  // El indice colgado de cada pestana: se abre al pasar o al enfocar la
  // pestana, flecha abajo entra, Escape sale. Cada entrada es un enlace real a
  // la pagina y al ancla de su cuadro (ver menu_indices()).
  function enlazarIndices() {
    var abierto = null, sobreIndice = false;
    function cerrar() {
      if (!abierto) return;
      abierto.panel.classList.remove('es-visible');
      abierto.link.setAttribute('aria-expanded', 'false');
      abierto = null;
    }
    function mostrar(link, panel) {
      if (abierto && abierto.panel === panel) return;
      cerrar();
      var r = link.getBoundingClientRect();
      panel.style.top = (r.bottom + window.scrollY) + 'px';
      panel.style.left = (r.left + window.scrollX) + 'px';
      panel.classList.add('es-visible');
      link.setAttribute('aria-expanded', 'true');
      abierto = { link: link, panel: panel };
    }
    var links = $$('.navbar-nav .nav-link');
    $$('.indice').forEach(function (panel) {
      var link = links.filter(function (a) {
        return a.textContent.trim() === panel.dataset.seccion;
      })[0];
      if (!link) return;
      link.setAttribute('aria-haspopup', 'true');
      link.setAttribute('aria-expanded', 'false');
      link.addEventListener('mouseenter', function () { mostrar(link, panel); });
      link.addEventListener('focus', function () { mostrar(link, panel); });
      link.addEventListener('mouseleave', function () {
        setTimeout(function () { if (!sobreIndice) cerrar(); }, 120);
      });
      link.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowDown') {
          e.preventDefault(); mostrar(link, panel);
          var primero = panel.querySelector('.indice-item');
          if (primero) { primero.setAttribute('tabindex', '0'); primero.focus(); }
        }
      });
      panel.addEventListener('mouseenter', function () { sobreIndice = true; });
      panel.addEventListener('mouseleave', function () { sobreIndice = false; cerrar(); });
      panel.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { cerrar(); link.focus(); }
      });
      $$('.indice-item', panel).forEach(function (a) {
        a.setAttribute('tabindex', '0');
        a.addEventListener('click', function (e) { cerrar(); irDentro(a, e); });
      });
    });
    document.addEventListener('click', function (e) {
      if (abierto && !e.target.closest('.indice') && !e.target.closest('.nav-link')) cerrar();
    });
    window.addEventListener('scroll', cerrar, { passive: true });
    window.addEventListener('resize', cerrar);
  }

  // La pestana del capitulo actual no navega: ya se esta en el.
  function anclarPestanaActiva() {
    $$('.navbar-nav .nav-link.active').forEach(function (a) {
      a.setAttribute('aria-current', 'page');
      a.addEventListener('click', function (e) { e.preventDefault(); });
    });
  }

  // Las laminas que no viven en una entrada plegada (el sankey VII.1) se
  // dibujan al cargar: ningun panel se va a abrir para pedirlas.
  function dibujarVisibles() {
    $$('.lamina-lienzo').forEach(function (l) {
      if (!l.closest('.accordion-collapse') && !graficos[l.id]) dibujar(l);
    });
  }

  function iniciar() {
    // ECharts carga diferido, igual que este archivo y antes que el: cuando
    // DOMContentLoaded dispara, los dos ya corrieron.
    dibujarVisibles();
    anclarPestanaActiva();
    enlazarIndices();
    enlazarMenuMovil();
    seguirAncla();
    seguirPieza();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', iniciar);
  else iniciar();
})();
