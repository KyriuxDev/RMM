/*
 * HU-12: gráfica de equipos por unidad (barras horizontales apiladas al 100 %).
 * Cada barra es una unidad; los tramos son En línea / Con alerta / Sin conexión.
 *
 * Uso: <canvas id="x" data-datos="#{json}" data-enlace="url-del-inventario?unidad="></canvas>
 *      RMM.graficaUnidades('x');
 *
 * Requiere Chart.js 4 (se carga en la página).
 */
window.RMM = window.RMM || {};

(function () {
    // Colores de estado (validados para daltonismo; ver comentario en TableroController)
    var SERIES = [
        {clave: 'enLinea', nombre: 'En línea', color: '#1F7A45', estado: 'ONLINE'},
        {clave: 'conAlerta', nombre: 'Con alerta', color: '#E6A817', estado: 'ALERTA'},
        {clave: 'sinConexion', nombre: 'Sin conexión', color: '#9AA6B2', estado: 'OFFLINE'}
    ];
    var graficas = {};

    RMM.graficaUnidades = function (idCanvas) {
        var canvas = document.getElementById(idCanvas);
        if (!canvas || typeof Chart === 'undefined') {
            return;
        }
        var d = JSON.parse(canvas.getAttribute('data-datos') || '{}');
        var enlace = canvas.getAttribute('data-enlace');
        if (graficas[idCanvas]) {           // al actualizar por AJAX se vuelve a dibujar
            graficas[idCanvas].destroy();
        }
        // Alto según el número de unidades: 34 px por barra
        canvas.parentNode.style.height = Math.max(140, 34 * (d.labels || []).length + 70) + 'px';

        var pct = function (n, i) {
            return d.total[i] > 0 ? Math.round(1000 * n / d.total[i]) / 10 : 0;
        };
        var datasets = SERIES.map(function (s) {
            return {
                label: s.nombre,
                data: d[s.clave].map(pct),
                cuentas: d[s.clave],
                estado: s.estado,
                backgroundColor: s.color,
                borderColor: '#FFFFFF',      // separación de 2 px entre tramos
                borderWidth: {left: 0, right: 2, top: 0, bottom: 0},
                borderSkipped: false,
                barThickness: 18
            };
        });

        graficas[idCanvas] = new Chart(canvas, {
            type: 'bar',
            data: {labels: d.labels, datasets: datasets},
            options: {
                indexAxis: 'y',
                maintainAspectRatio: false,
                animation: false,
                scales: {
                    x: {
                        stacked: true, min: 0, max: 100,
                        ticks: {callback: function (v) { return v + ' %'; }, color: '#5C6F7B', font: {size: 11}},
                        grid: {color: '#EEF1F4'}, border: {display: false}
                    },
                    y: {
                        stacked: true,
                        ticks: {color: '#2D3A45', font: {size: 12}, autoSkip: false},
                        grid: {display: false}, border: {color: '#D6DCE2'}
                    }
                },
                plugins: {
                    legend: {
                        position: 'top', align: 'start',
                        labels: {boxWidth: 12, boxHeight: 12, color: '#2D3A45', font: {size: 12}}
                    },
                    tooltip: {
                        mode: 'index', intersect: false,
                        callbacks: {
                            title: function (items) {
                                var i = items[0].dataIndex;
                                return d.labels[i] + ' · ' + d.total[i] + ' equipos';
                            },
                            label: function (c) {
                                return ' ' + c.dataset.label + ': ' + c.dataset.cuentas[c.dataIndex]
                                        + ' (' + c.parsed.x + ' %)';
                            }
                        }
                    }
                },
                // Clic en una barra: abre el inventario de esa unidad con ese estado
                onClick: function (evt, elementos) {
                    if (!enlace || !elementos.length) {
                        return;
                    }
                    var e = elementos[0];
                    window.location = enlace + encodeURIComponent(d.ids[e.index])
                            + '&estado=' + datasets[e.datasetIndex].estado;
                },
                onHover: function (evt, elementos) {
                    evt.native.target.style.cursor = enlace && elementos.length ? 'pointer' : 'default';
                }
            }
        });
    };
})();
