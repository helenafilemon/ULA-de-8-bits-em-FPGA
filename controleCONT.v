module controleCONT(
    input [1:0] atual,
    input enter,
    input reuso,
    output habilitaA,
    output habilitaB,
    output habilitaOp,
    output habilitaExec,
    output selMuxA,
    output resetFSM
);
    wire s0,s1,s2,s3,ns0,ns1;

    not n_s0(ns0, atual[0]);
    not n_s1(ns1, atual[1]);

    // --- CORREÇÃO DO BUG DE DETECÇÃO DE ESTADO ---
    and and_s0(s0, ns1, ns0);        // estado 00
    and and_s1(s1, ns1, atual[0]);  // estado 01 (Corrigido: 'atual' -> 'atual[0]')
    and and_s2(s2, atual[1], ns0);  // estado 10
    and and_s3(s3, atual[1], atual[0]);  // estado 11 (Corrigido: 'atual' -> 'atual[0]')
    // --- FIM DA CORREÇÃO ---

    and(selMuxA, s0, reuso);

    wire enter_normal_A;
    and(enter_normal_A, s0, enter);
    or(habilitaA, enter_normal_A, selMuxA);

    and(habilitaB, s1, enter); // <-- Agora 's1' será calculado corretamente
    and(habilitaOp, s2, enter);

    and(habilitaExec, s3); // <-- Agora 's3' será calculado corretamente

    and(resetFSM, s3, enter);
     
endmodule

module contador2b (
    input clk,
    input rst,
    input enable,
    output [1:0] Q,
     input condicao_avanco
);
    wire d0_logic, d1_logic;
    wire [1:0] D_final;
    wire n_enable;
    
    wire notA, notB;
    not(notA, Q[1]);
    not(notB, Q[0]);
    wire [1:0] f0, f1;
    
    and(f0[0], notA, Q[0]);
    and(f0[1], Q[1], notB);
    or(d1_logic, f0[0], f0[1]);
    
    wire estado_eh_10;
    and(estado_eh_10, Q[1], notB);
     
    wire avancar_de_10;
    and(avancar_de_10, estado_eh_10, condicao_avanco);

    wire transicao_normal_d0;
    and(transicao_normal_d0, notA, notB);

    // D[0] vai para 1 quando:
    // 1. A transição é normal (de 00->01 ou 01->10)
    // 2. Ou estamos no estado 10 e a condição de avanço foi satisfeita
    or(d0_logic, transicao_normal_d0, avancar_de_10);

    not n1 (n_enable, enable);
    wire d0_g, q0_g;
    and a0 (d0_g, d0_logic, enable);
    and a1 (q0_g, Q[0], n_enable);
    or o0 (D_final[0], d0_g, q0_g);

    wire d1_g, q1_g;
    and a2 (d1_g, d1_logic, enable);
    and a3 (q1_g, Q[1], n_enable);
    or o1 (D_final[1], d1_g, q1_g);

    flipflopD ff0 (.D(D_final[0]), .clk(clk), .rst(rst), .Q(Q[0]));
    flipflopD ff1 (.D(D_final[1]), .clk(clk), .rst(rst), .Q(Q[1]));
     
endmodule