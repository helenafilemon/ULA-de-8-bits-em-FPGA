/*
 * Módulo: mux_2para1_8bits_estrutural
 * Função: Um Multiplexador 2-para-1 para um barramento de 8 bits.
 * Construído 100% estruturalmente instanciando o seu módulo 'mux_2para1' 8 vezes.
 */
module mux_2para1_8bits_estrutural (
    input [7:0] in0, // Fonte 0 (dos Switches)
    input [7:0] in1, // Fonte 1 (do Resultado)
    input sel,       // Sinal de seleção (único para todos os bits)
    output [7:0] out
);

    // Instanciando um MUX de 1 bit (o seu módulo 'mux_2para1') para cada
    // bit do barramento. O 'generate for' é a forma estruturalmente correta
    // e elegante de fazer isso.
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bloco_mux_bit
        
            // A cada iteração, um novo 'mux_2para1' é criado e conectado.
            mux_2para1 mux_individual (
                .in0(in0[i]),    // Conecta o bit 'i' da entrada 0
                .in1(in1[i]),    // Conecta o bit 'i' da entrada 1
                .sel(sel),       // Conecta o mesmo seletor a todos
                .out(out[i])     // Conecta o bit 'i' da saída
            );

        end
    endgenerate

endmodule
