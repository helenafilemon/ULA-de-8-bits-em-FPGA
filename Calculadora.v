/*
 * Módulo: calculadora_rpn_toplevel
 * Função: O projeto completo com a lógica de reutilização de resultado.
 */
module calculadora_rpn_toplevel (
    input CLOCK_50,
    input [1:0] KEY,
    input [9:0] SW,
    output [7:0] LEDR,
    // ... saídas dos displays ...
);
    // --- Renomeando Entradas e Definindo Fios Lógicos ---
    wire clk = CLOCK_50;
    wire reset_n = KEY[0];
    wire action_botao = KEY[1];

    wire [7:0] dados_entrada_sw = SW[7:0];
    wire [2:0] sel_op = SW[2:0];
    // ... outros fios ...
    wire sel_fonte_para_reg_A;
    wire [7:0] dados_para_reg_A;

    // --- 1. INTERFACE COM O USUÁRIO (Detector de Borda) ---
    detector_de_borda_ativo_baixo DETECTOR_ACAO (
        .clk(clk), .reset_n(reset_n), .sinal_entrada(action_botao), .pulso_saida(action_pulso)
    );

    // --- 2. UNIDADE DE CONTROLE (O Cérebro com 4 estados) ---
    unidade_de_controle CONTROLE (
        .clk(clk), .reset_n(reset_n), .action_pulso(action_pulso),
        .enable_reg_A(enable_reg_A), .enable_reg_B(enable_reg_B), 
        .enable_reg_Resultado(enable_reg_Resultado),
        .sel_reg_A_fonte(sel_fonte_para_reg_A) // Conectando a nova saída
    );

    // --- 3. DATAPATH (Os Músculos com o novo MUX) ---

    // NOVO: MUX para selecionar a fonte de dados para o Registrador A
    mux_2para1_8bits MUX_PARA_REG_A (
        .in0(dados_entrada_sw),   // Fonte 0: As chaves
        .in1(resultado_final),    // Fonte 1: O resultado anterior
        .sel(sel_fonte_para_reg_A),
        .out(dados_para_reg_A)
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
    registrador_8bits_com_enable REG_RESULTADO (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_Resultado), .d(resultado_da_ula), .q(resultado_final)
    );

    // --- 4. SAÍDA ---
    assign LEDR = resultado_final; // Mostra o resultado final nos LEDs
    
endmodule
