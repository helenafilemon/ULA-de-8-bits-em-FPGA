/*
 * Módulo: mux_2para1
 * Função: Multiplexador 2-para-1 de 1 bit.
 * Construído com portas lógicas básicas.
 */
module mux_2para1 (
    input in0,       // Entrada de dados 0 (caminho "MANTER")
    input in1,       // Entrada de dados 1 (caminho "CARREGAR")
    input sel,       // Seletor ('enable')
    output out
);
    wire sel_n, a, b;

    not g1 (sel_n, sel);
    and g2 (a, in0, sel_n);
    and g3 (b, in1, sel);
    or  g4 (out, a, b);

endmodule