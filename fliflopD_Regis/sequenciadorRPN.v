/*
 * Módulo: logica_do_sequenciador_estrutural
 * Função: Bloco COMBINACIONAL totalmente estrutural. Decide o próximo estado
 * e gera os 'enables' com base no estado atual e em um ÚNICO botão de ação.
 */
module logica_do_sequenciador_estrutural (
    input [1:0] estado_atual,
    input action_pulso,
    output [1:0] proximo_estado,
    output enable_reg_A,
    output enable_reg_B,
    output enable_reg_Resultado
);

    // --- Fios para sinais invertidos e termos intermediários ---
    wire s1_n, s0_n;
    wire a_n;
    wire ns1_termo_a, ns1_termo_b;
    wire ns0_termo_a, ns0_termo_b;

    // --- Inversores para os sinais de estado e entrada ---
    not inv_s1(s1_n, estado_atual[1]);
    not inv_s0(s0_n, estado_atual[0]);
    not inv_a(a_n, action_pulso);
    
    // --- Implementação da Lógica de Próximo Estado ---
    // NS1 = (~s1 & s0 & a) | (s1 & ~s0 & ~a)
    and and_ns1_a(ns1_termo_a, s1_n, estado_atual[0], action_pulso);
    and and_ns1_b(ns1_termo_b, estado_atual[1], s0_n, a_n);
    or  or_ns1(proximo_estado[1], ns1_termo_a, ns1_termo_b);

    // NS0 = (~s1 & ~s0 & a) | (~s1 & s0 & ~a)
    and and_ns0_a(ns0_termo_a, s1_n, s0_n, action_pulso);
    and and_ns0_b(ns0_termo_b, s1_n, estado_atual[0], a_n);
    or  or_ns0(proximo_estado[0], ns0_termo_a, ns0_termo_b);
    
    // --- Implementação da Lógica de Saída (Enables) ---
    // enable_reg_A = ~s1 & ~s0 & action_pulso
    and and_enA(enable_reg_A, s1_n, s0_n, action_pulso);

    // enable_reg_B = ~s1 & s0 & action_pulso
    and and_enB(enable_reg_B, s1_n, estado_atual[0], action_pulso);
    
    // enable_reg_Resultado = s1 & ~s0 & action_pulso
    and and_enR(enable_reg_Resultado, estado_atual[1], s0_n, action_pulso);

endmodule
