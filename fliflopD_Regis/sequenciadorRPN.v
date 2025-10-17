/*
 * Módulo: logica_do_sequenciador_estrutural
 * Função: Bloco COMBINACIONAL totalmente estrutural para o fluxo de 4 estados
 * com reutilização de resultado. Este é o "cérebro" da unidade de controle.
 */
module logica_do_sequenciador_estrutural (
    input [1:0] estado_atual,
    input action_pulso,
    output [1:0] proximo_estado,
    output enable_reg_A,
    output enable_reg_B,
    output enable_reg_Resultado,
    output sel_reg_A_fonte
);

    // --- Fios para sinais invertidos e termos lógicos intermediários ---
    wire s1_n, s0_n, a_n;
    wire enA_t1, enA_t2;
    wire enB_t1, enB_t2;
    wire ns1_t1, ns1_t2, ns1_t3;
    wire ns0_t1, ns0_t2, ns0_t3;

    // --- Inversores para os sinais de estado e entrada ---
    not inv_s1(s1_n, estado_atual[1]);
    not inv_s0(s0_n, estado_atual[0]);
    not inv_a(a_n, action_pulso);
    
    // --- Lógica de Saída (Enables e Seleção do MUX) ---
    
    // enable_reg_A = (s1_n & s0_n & action_pulso) | (s1 & s0_n)
    and and_enA_t1(enA_t1, s1_n, s0_n, action_pulso);
    and and_enA_t2(enA_t2, estado_atual[1], s0_n);
    or  or_enA(enable_reg_A, enA_t1, enA_t2);
    
    // enable_reg_B = (s0 & action_pulso)
    and and_enB(enable_reg_B, estado_atual[0], action_pulso);
    
    // enable_reg_Resultado = (s1 & s0_n)
    and and_enR(enable_reg_Resultado, estado_atual[1], s0_n);
    
    // sel_reg_A_fonte = (s1 & s0_n)
    and and_selA(sel_reg_A_fonte, estado_atual[1], s0_n);

    // --- Lógica de Próximo Estado ---

    // NS1 = (~s1 & s0 & a) | (s1 & ~s0) | (s1 & s0 & ~a)
    and and_ns1_t1(ns1_t1, s1_n, estado_atual[0], action_pulso);
    and and_ns1_t2(ns1_t2, estado_atual[1], s0_n);
    and and_ns1_t3(ns1_t3, estado_atual[1], estado_atual[0], a_n);
    or  or_ns1(proximo_estado[1], ns1_t1, ns1_t2, ns1_t3);

    // NS0 = (~s1 & ~s0 & a) | (~s1 & s0 & ~a) | s1
    and and_ns0_t1(ns0_t1, s1_n, s0_n, action_pulso);
    and and_ns0_t2(ns0_t2, s1_n, estado_atual[0], a_n);
    or  or_ns0(proximo_estado[0], ns0_t1, ns0_t2, estado_atual[1]);

endmodule
