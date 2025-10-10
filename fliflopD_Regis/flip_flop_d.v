/*
 * Módulo: flip_flop_d_comportamental
 * Função: Flip-Flop tipo D, sensível à borda de subida, com reset assíncrono.
 * Este é o único módulo do projeto que usará Verilog comportamental,
 */
module flip_flop_d (
    input d,          // Entrada de dados de 1 bit
    input clk,        // Sinal de clock
    input reset_n,    // Sinal de reset assíncrono (ativo em nível baixo)
    output reg q      // Saída de dados de 1 bit
);

    // A lista de sensibilidade (@) define esses momentos.
    always @(posedge clk or negedge reset_n) begin
    
        // A condição de reset é checada primeiro e tem prioridade.
        // Como o reset está na lista de sensibilidade, ele atua imediatamente (assíncrono).
        if (!reset_n) begin // Se reset_n for '0'
            q <= 1'b0;      // A saída é forçada para 0.
        end 
        else begin
            // Se não houver reset, a única outra razão para entrar neste bloco
            // foi a borda de subida do clock (posedge clk).
            q <= d;         // A saída 'q' copia o valor da entrada 'd'.
        end
        
    end

endmodule
