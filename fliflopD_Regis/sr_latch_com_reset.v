/*
 * Módulo: sr_latch_com_reset
 * Função: Célula de memória básica (Latch SR) com reset assíncrono.
 * Construído com portas NAND cruzadas.
 * s_n e r_n são ativos em nível baixo.
 * reset_n é ativo em nível baixo.
 */
module sr_latch_com_reset (
    input s_n,
    input r_n,
    input reset_n,
    output q,
    output q_n
);

    // Estrutura de portas NAND cruzadas.
    // O reset_n no g2 força q_n para 1, que por sua vez força q para 0.
    nand g1 (q, s_n, q_n);
    nand g2 (q_n, r_n, q, reset_n);

endmodule