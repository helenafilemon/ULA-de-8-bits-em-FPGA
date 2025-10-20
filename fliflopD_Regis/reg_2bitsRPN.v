/*
 * Módulo: registrador_de_estado_2bits
 * Função: Bloco SEQUENCIAL. Armazena o estado atual do sequenciador.
 */
module registrador_de_estado_2bits (
    input clk,
    input reset_n,
    input [1:0] proximo_estado,
    output [1:0] estado_atual
);
    // Instancia um flip-flop para cada bit do estado
    flip_flop_d ff_bit0 (
        .clk(clk), .reset_n(reset_n), .d(proximo_estado[0]), .q(estado_atual[0])
    );
    flip_flop_d ff_bit1 (
        .clk(clk), .reset_n(reset_n), .d(proximo_estado[1]), .q(estado_atual[1])
    );
endmodule
