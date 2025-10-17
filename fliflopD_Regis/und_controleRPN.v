/*
 * Módulo: unidade_de_controle
 * Função: O sequenciador completo, 100% estrutural.
 */
module unidade_de_controle (
    input clk,
    input reset_n,
    input enter_pulso,
    input executar_pulso,
    output enable_reg_A,
    output enable_reg_B,
    output enable_reg_Resultado
);

    wire [1:0] estado_atual;
    wire [1:0] proximo_estado;

    // 1. Instancia a memória (registrador de estado)
    registrador_de_estado_2bits REG_ESTADO (
        .clk(clk), .reset_n(reset_n), .proximo_estado(proximo_estado), .estado_atual(estado_atual)
    );

    // 2. Instancia a lógica combinacional (agora puramente estrutural)
    logica_do_sequenciador_estrutural LOGICA_SEQ (
        .estado_atual(estado_atual),
        .enter_pulso(enter_pulso),
        .executar_pulso(executar_pulso),
        .proximo_estado(proximo_estado),
        .enable_reg_A(enable_reg_A),
        .enable_reg_B(enable_reg_B),
        .enable_reg_Resultado(enable_reg_Resultado)
    );
endmodule
