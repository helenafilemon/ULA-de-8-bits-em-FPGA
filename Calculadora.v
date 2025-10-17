/*
 * Módulo: calculadora_rpn_toplevel
 * Função: O projeto completo. Conecta todos os sub-módulos.
 */
module calculadora_rpn_toplevel (
    // --- Entradas Físicas ---
    input CLOCK_50,         // Clock de 50MHz da placa
    input [1:0] KEY,        // Botões (KEY0 para Reset, KEY1 para Enter)
    input [9:0] SW,         // 10 chaves seletoras

    // --- Saídas Físicas ---
    output [7:0] LEDR,      // LEDs para visualização do resultado
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 // Displays de 7 segmentos
);
    // --- Renomeando Entradas para Clareza ---
    wire clk = CLOCK_50;
    wire reset_n = KEY[0];      // Reset ativo baixo
    wire enter_botao = KEY[1]; // Usaremos outro botão para executar
    wire executar_botao = KEY[2]; // Assumindo que você pode usar KEY[2]

    // --- Fios Internos (O Sistema Nervoso do Circuito) ---
    wire enter_pulso, executar_pulso;
    wire enable_reg_A, enable_reg_B, enable_reg_Resultado;
    wire [7:0] q_reg_A, q_reg_B, resultado_final;
    wire [7:0] dados_entrada = SW[7:0];
    wire [2:0] sel_op = SW[2:0]; // Operação selecionada em SW[2:0]
    wire [7:0] resultado_da_ula;
    
    // --- 1. INTERFACE COM O USUÁRIO (Detectores de Borda) ---
    detector_de_borda_ativo_baixo DETECTOR_ENTER (
        .clk(clk), .reset_n(reset_n), .sinal_entrada(enter_botao), .pulso_saida(enter_pulso)
    );
    detector_de_borda_ativo_baixo DETECTOR_EXECUTAR (
        .clk(clk), .reset_n(reset_n), .sinal_entrada(executar_botao), .pulso_saida(executar_pulso)
    );

    // --- 2. UNIDADE DE CONTROLE (O Cérebro) ---
    unidade_de_controle CONTROLE (
        .clk(clk), .reset_n(reset_n), .enter_pulso(enter_pulso), .executar_pulso(executar_pulso),
        .enable_reg_A(enable_reg_A), .enable_reg_B(enable_reg_B), .enable_reg_Resultado(enable_reg_Resultado)
    );

    // --- 3. DATAPATH (Os Músculos) ---
    // Registrador para o Operando A
    registrador_8bits_com_enable REG_A (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_A), .d(dados_entrada), .q(q_reg_A)
    );
    // Registrador para o Operando B
    registrador_8bits_com_enable REG_B (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_B), .d(dados_entrada), .q(q_reg_B)
    );
    // A ULA fazendo os cálculos
    ula_8bits ULA (
        .a(q_reg_A), .b(q_reg_B), .sel_op(sel_op), .resultado_ula(resultado_da_ula)
    );
    // Registrador para o Resultado Final
    registrador_8bits_com_enable REG_RESULTADO (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_Resultado), .d(resultado_da_ula), .q(resultado_final)
    );

    // --- 4. SAÍDA ---
    // Por enquanto, para testar, vamos conectar o resultado final diretamente aos LEDs
    assign LEDR = resultado_final;

    // O módulo de exibição para os HEX viria aqui.
    // modulo_exibicao DISPLAY (.resultado(resultado_final), .base(SW[9:8]), .HEX0(HEX0), ...);

endmodule
