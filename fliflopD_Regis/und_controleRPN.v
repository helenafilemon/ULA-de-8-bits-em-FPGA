/*
 * Módulo: unidade_de_controle
 * Função: O sequenciador completo e atualizado para o fluxo de 4 estados.
 * Montado estruturalmente, separando memória (registrador) e lógica.
 */
module unidade_de_controle (
    input clk,
    input reset_n,
    input action_pulso,
    output enable_reg_A,
    output enable_reg_B,
    output enable_reg_Resultado,
    output sel_reg_A_fonte // <-- A NOVA SAÍDA DE COMANDO
);

    // Fios internos para conectar os blocos
    wire [1:0] estado_atual;
    wire [1:0] proximo_estado;

    // 1. Instancia a memória (registrador de estado) - sem mudanças
    registrador_de_estado_2bits REG_ESTADO (
        .clk(clk),
        .reset_n(reset_n),
        .proximo_estado(proximo_estado),
        .estado_atual(estado_atual)
    );

    // 2. Instancia a nova lógica combinacional de 4 estados
    logica_do_sequenciador_estrutural LOGICA_SEQ (
        .estado_atual(estado_atual),
        .action_pulso(action_pulso),
        .proximo_estado(proximo_estado),
        .enable_reg_A(enable_reg_A),
        .enable_reg_B(enable_reg_B),
        .enable_reg_Resultado(enable_reg_Resultado),
        .sel_reg_A_fonte(sel_reg_A_fonte) // <-- Conectando a nova porta
    );
endmodule
