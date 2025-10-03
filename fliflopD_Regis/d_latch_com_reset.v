/*
 * Módulo: d_latch_com_reset
 * Função: Latch tipo D (sensível a nível) com reset.
 * Construído estruturalmente usando um sr_latch_com_reset.
 * Quando 'enable' está em 1, a saída 'q' segue a entrada 'd'.
 * Quando 'enable' está em 0, a saída 'q' mantém o último valor.
 */
module d_latch_com_reset (
    input d,
    input enable,
    input reset_n,
    output q
);

    wire s_n, r_n;
    wire d_n;

    // Lógica de portas na entrada para controlar o Latch SR interno.
    not g1 (d_n, d);
    nand g2 (s_n, d, enable);
    nand g3 (r_n, d_n, enable);

    // Instanciação do nosso bloco fundamental SR Latch.
    sr_latch_com_reset latch_interno (
        .s_n(s_n),
        .r_n(r_n),
        .reset_n(reset_n),
        .q(q)
        // .q_n não é necessário na saída deste módulo
    );

endmodule