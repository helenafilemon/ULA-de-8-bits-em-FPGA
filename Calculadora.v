/*
 * Módulo: calculadora_rpn_toplevel
 * Função: O projeto completo, montado para a placa DE10-Lite com 2 botões.
 */
module calculadora_rpn_toplevel (
    // --- Entradas Físicas ---
    input CLOCK_50,
    input [1:0] KEY,        // 2 botões: KEY[0]=Reset, KEY[1]=Ação
    input [9:0] SW,         // 10 chaves seletoras

    // --- Saídas Físicas ---
    output [7:0] LEDR,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
    // --- Renomeando Entradas Físicas para Clareza ---
    wire clk = CLOCK_50;
    wire reset_n = KEY[0];      // Reset ativo baixo
    wire action_botao = KEY[1]; // O botão multifuncional

    // --- FIOS INTERNOS: Dando nomes lógicos a partes do barramento SW ---
    wire [7:0] dados_entrada = SW[7:0];
    wire [2:0] sel_op = SW[2:0];
    wire [1:0] sel_base = SW[9:8];

    // --- Outros Fios Internos ---
    wire action_pulso;
    wire enable_reg_A, enable_reg_B, enable_reg_Resultado;
    wire [7:0] q_reg_A, q_reg_B, resultado_final;
    wire [7:0] resultado_da_ula;
    
    // --- 1. INTERFACE COM O USUÁRIO (APENAS UM Detector de Borda) ---
    detector_de_borda_ativo_baixo DETECTOR_ACAO (
        .clk(clk),
        .reset_n(reset_n),
        .sinal_entrada(action_botao),
        .pulso_saida(action_pulso)
    );

    // --- 2. UNIDADE DE CONTROLE (O Cérebro) ---
    unidade_de_controle CONTROLE (
        .clk(clk),
        .reset_n(reset_n),
        .enter_pulso(action_pulso), // <-- Conectado ao pulso de ação único
        .executar_pulso(action_pulso), // <-- Conectado ao mesmo pulso
        .enable_reg_A(enable_reg_A),
        .enable_reg_B(enable_reg_B),
        .enable_reg_Resultado(enable_reg_Resultado)
    );
    // Nota: O módulo 'unidade_de_controle' usará o 'logica_do_sequenciador_estrutural' atualizado.

    // --- 3. DATAPATH (Os Músculos) ---
    registrador_8bits_com_enable REG_A (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_A), .d(dados_entrada), .q(q_reg_A)
    );
    registrador_8bits_com_enable REG_B (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_B), .d(dados_entrada), .q(q_reg_B)
    );
    ula_8bits ULA (
        .a(q_reg_A), .b(q_reg_B), .sel_op(sel_op), .resultado_ula(resultado_da_ula)
    );
    registrador_8bits_com_enable REG_RESULTADO (
        .clk(clk), .reset_n(reset_n), .enable(enable_reg_Resultado), .d(resultado_da_ula), .q(resultado_final)
    );

    // --- 4. SAÍDA ---
    assign LEDR = resultado_final;

    // Conecte aqui seu módulo de exibição quando estiver pronto
    // modulo_exibicao DISPLAY (.resultado(resultado_final), .base(sel_base), ...);

endmodule
