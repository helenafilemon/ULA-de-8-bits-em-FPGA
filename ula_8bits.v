/*
 * Módulo: ula_8bits
 * Função: ULA que realiza 8 operações em paralelo e seleciona uma saída.
 */
module ula_8bits (
    input [7:0] a,
    input [7:0] b,
    input [2:0] sel_op,
    output [7:0] resultado_ula
    // Adicione aqui as saídas para os flags (Zero, Overflow, etc.)
);
    // Fios para guardar o resultado de CADA operação
    wire [7:0] res_soma, res_sub, res_mult, res_div;
    wire [7:0] res_and, res_or, res_xor, res_not;

    // --- 1. INSTANCIE SEUS MÓDULOS DE OPERAÇÃO ---
    // Eles estão todos trabalhando em paralelo, o tempo todo.
    // **IMPORTANTE: Ajuste os nomes dos módulos e das portas (.a, .b, .soma, etc.)
    // para corresponderem exatamente aos que você criou!**

    somador_8bits      MOD_SOMA (.a(a), .b(b), .soma(res_soma));
    subtrator_8bits    MOD_SUB  (.a(a), .b(b), .sub(res_sub));
    multiplicador_8bits MOD_MULT (.a(a), .b(b), .mult(res_mult)); // Módulo sequencial que você fará
    divisor_8bits      MOD_DIV  (.a(a), .b(b), .div(res_div));   // Módulo sequencial que você fará
    and_8bits          MOD_AND  (.a(a), .b(b), .res(res_and));
    or_8bits           MOD_OR   (.a(a), .b(b), .res(res_or));
    xor_8bits          MOD_XOR  (.a(a), .b(b), .res(res_xor));
    not_8bits          MOD_NOT  (.a(a), .res(res_not)); // NOT só precisa de uma entrada

    // --- 2. INSTANCIE O MUX SELETOR ---
    // O MUX seleciona qual dos resultados vai para a saída final.
    mux_8para1_8bits MUX_SELETOR (
        .in0(res_soma),
        .in1(res_sub),
        .in2(res_mult),
        .in3(res_div),
        .in4(res_and),
        .in5(res_or),
        .in6(res_xor),
        .in7(res_not),
        .sel(sel_op),
        .out(resultado_ula)
    );

endmodule
