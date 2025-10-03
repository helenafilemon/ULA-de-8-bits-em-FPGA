/*
 * Módulo: flip_flop_d_estrutural
 * Função: Flip-Flop tipo D, sensível à borda de subida, com reset assíncrono.
 * Construído 100% estruturalmente com uma arquitetura Mestre-Escravo.
 * Este é o "tijolo" que você usará para construir seus registradores.
 */
module flip_flop_d_estrutural (
    input d,
    input clk,
    input reset_n, // Reset ativo em nível baixo
    output q
);

    wire clk_n;
    wire saida_mestre;

    // Inversor para o sinal de clock.
    not g_inv_clk (clk_n, clk);

    // O Latch Mestre: é transparente quando o clock está em 0.
    // Ele captura o valor de 'd' na primeira metade do ciclo.
    d_latch_com_reset mestre (
        .d(d),
        .enable(clk_n),
        .reset_n(reset_n),
        .q(saida_mestre)
    );

    // O Latch Escravo: é transparente quando o clock está em 1.
    // Ele captura o valor da saída do mestre na segunda metade do ciclo.
    // A saída 'q' só muda na transição de 0 para 1 do clock.
    d_latch_com_reset escravo (
        .d(saida_mestre),
        .enable(clk),
        .reset_n(reset_n),
        .q(q)
    );

endmodule