/*
 * Módulo: detector_de_borda_ativo_baixo
 * Função: Converte o sinal de um botão ATIVO-BAIXO em um pulso de 1 ciclo.
 * Detecta a borda de descida (transição de 1 para 0).
 */
module detector_de_borda_ativo_baixo (
    input clk,
    input reset_n,
    input sinal_entrada,     // Sinal do botão (1 = solto, 0 = pressionado)
    output pulso_saida      // Pulso de 1 ciclo para a unidade de controle
);

    // Fios para os estágios de sincronização
    wire q_sinc1;
    wire q_sinc2;
    wire q_sinc1_invertido;

    // --- Estágio de Sincronização e Atraso (IDÊNTICO A ANTES) ---
    // A função de sincronizar e atrasar não muda.
    
    // FF1: Armazena o estado atual do botão
    flip_flop_d ff_sinc1 (
        .clk(clk),
        .reset_n(reset_n),
        .d(sinal_entrada),
        .q(q_sinc1)
    );
    
    // FF2: Armazena o estado do botão do ciclo anterior
    flip_flop_d ff_sinc2 (
        .clk(clk),
        .reset_n(reset_n),
        .d(q_sinc1),
        .q(q_sinc2)
    );

    // --- LÓGICA COMBINACIONAL CORRIGIDA (Borda de Descida) ---
    // A borda acontece quando o sinal ATUAL (q_sinc1) é 0 E o ANTERIOR (q_sinc2) era 1.
    // Lógica: pulso_saida = (NOT q_sinc1) AND q_sinc2

    // Instancia uma porta NOT para inverter o sinal atual
    not porta_not (q_sinc1_invertido, q_sinc1);
    
    // Instancia uma porta AND para detectar a condição da borda de descida
    and porta_and (pulso_saida, q_sinc1_invertido, q_sinc2);

endmodule
