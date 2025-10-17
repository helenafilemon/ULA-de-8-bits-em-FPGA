/*
 * Módulo: logica_do_sequenciador_estrutural_corrigido
 * Função: Bloco COMBINACIONAL que usa um único botão de ação.
 */
module logica_do_sequenciador_estrutural (
    input [1:0] estado_atual,
    input action_pulso, // <-- ÚNICA ENTRADA DE AÇÃO
    output [1:0] proximo_estado,
    output enable_reg_A,
    output enable_reg_B,
    output enable_reg_Resultado
);
    // ... (Fios e inversores como antes) ...
    // ...
    
    // NS1 = (s1 & s0_n & action_pulso_n) | (s1_n & s0 & action_pulso) // Equação atualizada
    // NS0 = (s1_n & s0 & action_pulso_n) | (s1_n & s0_n & action_pulso) // Equação atualizada

    // enable_reg_A = s1_n & s0_n & action_pulso
    and and_enA(enable_reg_A, s1_n, s0_n, action_pulso);

    // enable_reg_B = s1_n & s0 & action_pulso
    and and_enB(enable_reg_B, s1_n, estado_atual[0], action_pulso);
    
    // enable_reg_Resultado = s1 & s0_n & action_pulso
    and and_enR(enable_reg_Resultado, estado_atual[1], s0_n, action_pulso);
endmodule
