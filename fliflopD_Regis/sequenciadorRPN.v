/*
 * Módulo: logica_do_sequenciador_estrutural
 * Função: Bloco COMBINACIONAL. Decide o próximo estado E gera os 'enables'
 * implementado 100% com portas lógicas, sem NENHUMA declaração 'assign'.
 */
module logica_do_sequenciador_estrutural (
    input [1:0] estado_atual,
    input enter_pulso,
    input executar_pulso,
    output [1:0] proximo_estado,
    output enable_reg_A,
    output enable_reg_B,
    output enable_reg_Resultado
);

    // --- Fios para os sinais invertidos e termos intermediários ---
    wire s1_n, s0_n;
    wire e_n, x_n;
    wire ns1_termo_a, ns1_termo_b;
    wire ns0_termo_a, ns0_termo_b;

    // --- Inversores para os sinais de estado e entrada ---
    // Usando os bits do barramento e as portas de entrada DIRETAMENTE
    not inv_s1(s1_n, estado_atual[1]);
    not inv_s0(s0_n, estado_atual[0]);
    not inv_e(e_n, enter_pulso);
    not inv_x(x_n, executar_pulso);
    
    // --- Implementação da Lógica de Próximo Estado ---
    // NS1 = (estado_atual[1] & s0_n & x_n) | (s1_n & estado_atual[0] & enter_pulso)
    and and_ns1_a(ns1_termo_a, estado_atual[1], s0_n, x_n);
    and and_ns1_b(ns1_termo_b, s1_n, estado_atual[0], enter_pulso);
    or  or_ns1(proximo_estado[1], ns1_termo_a, ns1_termo_b);

    // NS0 = (s1_n & estado_atual[0] & e_n) | (s1_n & s0_n & enter_pulso)
    and and_ns0_a(ns0_termo_a, s1_n, estado_atual[0], e_n);
    and and_ns0_b(ns0_termo_b, s1_n, s0_n, enter_pulso);
    or  or_ns0(proximo_estado[0], ns0_termo_a, ns0_termo_b);
    
    // --- Implementação da Lógica de Saída (Enables) ---
    // enable_reg_A = s1_n & s0_n & enter_pulso
    and and_enA(enable_reg_A, s1_n, s0_n, enter_pulso);

    // enable_reg_B = s1_n & estado_atual[0] & enter_pulso
    and and_enB(enable_reg_B, s1_n, estado_atual[0], enter_pulso);
    
    // enable_reg_Resultado = estado_atual[1] & s0_n & executar_pulso
    and and_enR(enable_reg_Resultado, estado_atual[1], s0_n, executar_pulso);

endmodule
