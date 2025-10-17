/*
 * Módulo: calculadora_rpn_toplevel (Versão Final - 100% Estrutural)
 * Função: O projeto completo, sem o uso de 'assign' para a saída.
 */
module calculadora_rpn_toplevel (
    input CLOCK_50,
    input [1:0] KEY,
    input [9:0] SW,
    output [7:0] LEDR, // <-- A saída do registrador será conectada diretamente aqui
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
    // --- Renomeando Entradas e Definindo Fios Lógicos ---
    wire clk = CLOCK_50;
    wire reset_n = KEY[0];
    wire action_botao = KEY[1];

    wire [7:0] dados_entrada_sw = SW[7:0];
    wire [2:0] sel_op = SW[2:0];
    wire [1:0] sel_base = SW[9:8];

    // --- Fios Internos ---
    wire action_pulso;
    wire enable_reg_A, enable_reg_B, enable_reg_Resultado;
    wire [7:0] q_reg_A, q_reg_B; // O fio 'resultado_final' não é mais necessário
    wire [7:0] resultado_da_ula;
    wire sel_fonte_para_reg_A;
    wire [7:0] dados_para_reg_A;

    // --- 1. INTERFACE COM O USUÁRIO ---
    detector_de_borda_ativo_baixo DETECTOR_ACAO (
        .clk(clk), .reset_n(reset_n), .sinal_entrada(action_botao), .pulso_saida(action_pulso)
    );

    // --- 2. UNIDADE DE CONTROLE ---
    unidade_de_controle CONTROLE (
        .clk(clk), .reset_n(reset_n), .action_pulso(action_pulso),
        .enable_reg_A(enable_reg_A), .enable_reg_B(enable_reg_B), 
        .enable_reg_Resultado(enable_reg_Resultado),
        .sel_reg_A_fonte(sel_fonte_para_reg_A)
    );

    // --- 3. DATAPATH ---
    mux_2para1_8bits_estrutural MUX_PARA_REG_A (
        .in0(dados_entrada_sw), .in1(LEDR), // <-- O MUX agora pega o feedback da saída final
        .sel(sel_fonte_para_reg_A), .out(dados_para_reg_A)
    );
    registrador_8bits_com_enable REG_A (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_A), .d(dados_para_reg_A), .q(q_reg_A)
    );
    registrador_8bits_com_enable REG_B (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_B), .d(dados_entrada_sw), .q(q_reg_B)
    );
    ula_8bits ULA (
        .a(q_reg_A), .b(q_reg_B), .sel_op(sel_op), .resultado_ula(resultado_da_ula)
    );
    
    // **A MUDANÇA PRINCIPAL ESTÁ AQUI**
    // A saída 'q' do registrador de resultado é conectada DIRETAMENTE à porta
    // de saída 'LEDR' do módulo toplevel.
    registrador_8bits_com_enable REG_RESULTADO (
        .clk(clk), 
        .reset_n(reset_n), 
        .enable(enable_reg_Resultado), 
        .d(resultado_da_ula), 
        .q(LEDR) // <-- Conexão direta com a saída
    );

    // --- 4. SAÍDA (O assign foi removido) ---
    // O módulo de exibição também se conectaria diretamente a LEDR.
    // modulo_exibicao DISPLAY (.resultado(LEDR), .base(sel_base), ...);

endmodule
