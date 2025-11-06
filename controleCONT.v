// --- Modulo de Controle (FSM Mealy) ---
// Decodifica o estado atual e as entradas dos botoes para gerar sinais de controle.
module controleCONT(
    input [1:0] atual, // Estado atual
    input enter,       // Botao Enter
    input reuso,       // Botao Reuso
    output habilitaA,    // Habilita carga do Operando A
    output habilitaB,    // Habilita carga do Operando B
    output habilitaOp,   // Habilita carga do Opcode
    output habilitaExec, // Habilita carga do Resultado
    output selMuxA,      // Seleciona Reuso no MUX de entrada
    output resetFSM      // Reseta a maquina
);
    wire s0,s1,s2,s3,ns0,ns1;

    // Decodificacao dos estados
    not n_s0(ns0, atual[0]);
    not n_s1(ns1, atual[1]);
    and and_s0(s0, ns1, ns0);       // Estado 00
    and and_s1(s1, ns1, atual[0]);  // Estado 01 (CORRIGIDO no seu codigo original)
    and and_s2(s2, atual[1], ns0);  // Estado 10
    and and_s3(s3, atual[1], atual[0]); // Estado 11 (CORRIGIDO no seu codigo original)

    // Logica de saida dos sinais de controle
    and(selMuxA, s0, reuso);

    wire enter_normal_A;
    and(enter_normal_A, s0, enter);
    or(habilitaA, enter_normal_A, selMuxA);

    and(habilitaB, s1, enter);
    and(habilitaOp, s2, enter);
    and(habilitaExec, s3);
    and(resetFSM, s3, enter);
     
endmodule


// --- CONTADOR DA FSM (Logica de Proximo Estado) ---
// Proposito: Contador sincrono de 2 bits que armazena o estado (00, 01, 10, 11).
// Possui logica para "travar" (stall) no estado 10.
// --- Contador de Estado (FSM) ---
// Armazena o estado atual da maquina (2 bits).
module contador2b (
    input clk,
    input rst,
    input enable,          // Sinal para tentar avancar de estado
    output [1:0] Q,        // Estado atual
    input condicao_avanco  // Condicao extra para permitir o avanco (stall)
);
    wire d0_logic, d1_logic;
    wire [1:0] D_final;
    wire n_enable;
    
    wire notA, notB;
    not(notA, Q[1]);
    not(notB, Q[0]);
    wire [1:0] f0, f1;
    
    // Logica combinacional para o proximo estado
    and(f0[0], notA, Q[0]);
    and(f0[1], Q[1], notB);
    or(d1_logic, f0[0], f0[1]);
    
    wire estado_eh_10;
    and(estado_eh_10, Q[1], notB);
     
    wire avancar_de_10;
    and(avancar_de_10, estado_eh_10, condicao_avanco);

    wire transicao_normal_d0;
    and(transicao_normal_d0, notA, notB);

    or(d0_logic, transicao_normal_d0, avancar_de_10);

    // Logica de enable: mantem o estado se enable for 0
    not n1 (n_enable, enable);
    wire d0_g, q0_g;
    and a0 (d0_g, d0_logic, enable);
    and a1 (q0_g, Q[0], n_enable);
    or o0 (D_final[0], d0_g, q0_g);

    wire d1_g, q1_g;
    and a2 (d1_g, d1_logic, enable);
    and a3 (q1_g, Q[1], n_enable);
    or o1 (D_final[1], d1_g, q1_g);

    // Flip-flops de estado
    flipflopD ff0 (.D(D_final[0]), .clk(clk), .rst(rst), .Q(Q[0]));
    flipflopD ff1 (.D(D_final[1]), .clk(clk), .rst(rst), .Q(Q[1]));
     
endmodule




