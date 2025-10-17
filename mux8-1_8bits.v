/*
 * Módulo: mux_8para1_8bits_estrutural
 * Função: Um Multiplexador 8-para-1 para um barramento de 8 bits.
 * Construído 100% estruturalmente instanciando o seu módulo 'mux_8x1' 8 vezes.
 */
module mux_8para1_8bits (
    // 8 entradas, cada uma sendo um barramento de 8 bits
    input [7:0] in0, in1, in2, in3, in4, in5, in6, in7,
    
    // 1 seletor de 3 bits
    input [2:0] sel,
    
    // 1 saída, que é um barramento de 8 bits
    output [7:0] out
);

    // O laço 'generate for' cria 8 instâncias do seu módulo 'mux_8x1'.
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bloco_mux_por_bit
        
            // Instanciando seu módulo 'mux_8x1' para cada fatia de bit
            mux_8x1 mux_individual (
                // Conectando o i-ésimo bit de cada barramento de entrada
                .I0(in0[i]),
                .I1(in1[i]),
                .I2(in2[i]),
                .I3(in3[i]),
                .I4(in4[i]),
                .I5(in5[i]),
                .I6(in6[i]),
                .I7(in7[i]),

                // Conectando os bits do barramento 'sel' às entradas S0, S1, S2
                .S0(sel[0]),
                .S1(sel[1]),
                .S2(sel[2]),

                // Conectando a saída de cada MUX de 1 bit para formar o barramento final
                .Y(out[i])
            );

        end
    endgenerate

endmodule
