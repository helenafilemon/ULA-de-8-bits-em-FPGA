/*
 * Módulo: registrador_8bits_com_enable
 * Função: Registrador de 8 bits que só carrega um novo valor
 * quando o sinal 'enable' está ativo.
 */
module registrador_8bits_com_enable (
    input clk,
    input reset_n,
    input enable,         // O seletor para todos os MUXes
    input [7:0] d,        // O novo dado vindo da ULA
    output [7:0] q
);

    wire [7:0] d_para_ff; // Fio que conecta a saída dos MUXes à entrada dos FFs

    // Instanciando 8 MUXes e 8 Flip-Flops
    // Usaremos um laço generate para simplificar o código
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bloco_registrador
            
            // O MUX decide o que vai para a entrada do Flip-Flop
            mux_2para1 mux_bit (
                .in0(q[i]),          // Caminho 0: realimenta o valor atual
                .in1(d[i]),          // Caminho 1: o novo valor
                .sel(enable),
                .out(d_para_ff[i])
            );

            // O Flip-Flop armazena o que quer que o MUX tenha decidido
            flip_flop_d ff_bit (
                .clk(clk),
                .reset_n(reset_n),
                .d(d_para_ff[i]),
                .q(q[i])
            );
            
        end
    endgenerate


endmodule
