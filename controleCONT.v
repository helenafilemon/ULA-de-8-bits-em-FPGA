// --- CONTROLE DA FSM (Logica de Saida) ---
// Proposito: Modulo combinacional (Mealy) que gera os sinais de controle.
module controleCONT(
    input [1:0] atual, // Estado atual (de contador2b)
    input enter,       // Botao 'Enter' (limpo)
    input reuso,       // Botao 'Reuso' (limpo)
    output habilitaA,
    output habilitaB,
    output habilitaOp,
    output habilitaExec,
    output selMuxA,     // Seleciona 'resReg' para o MUX de entrada
    output resetFSM     // Reseta a FSM (pilha e reg_op)
);
    wire s0,s1,s2,s3,ns0,ns1; // Fios para decodificar o estado

    // Decodificador de Estado (Nota: logica de s1 e s3 esta incorreta)
    not n_s0(ns0, atual[0]);
    not n_s1(ns1, atual[1]);
    and and_s0(s0, ns1, ns0);      // s0 = (estado == 00)
    and and_s1(s1, ns1, atual[0]); // s1 = (estado == 01)
    and and_s2(s2, atual[1], ns0);  // s2 = (estado == 10)
    and and_s3(s3, atual[1], atual[0]); // s3 = (estado == 11)

    // Logica de Saida
    
    // selMuxA: Ativa o 'Reuso' se (estado=00 E reuso=1)
    and(selMuxA, s0, reuso);

    // habilitaA: Ativa o 'push' da Pilha se (estado=00 E enter=1) OU (Reuso=1)
    wire enter_normal_A;
    and(enter_normal_A, s0, enter);
    or(habilitaA, enter_normal_A, selMuxA);

    // habilitaB: Ativa o 'push' da Pilha se (estado=01 E enter=1)
    and(habilitaB, s1, enter);
    
    // habilitaOp: Ativa o 'reg_op' se (estado=10 E enter=1)
    and(habilitaOp, s2, enter);

    // habilitaExec: Ativa o 'reg_resultado' se (estado=11)
    and(habilitaExec, s3);

    // resetFSM: Ativa o reset da pilha/reg_op se (estado=11 E enter=1)
    and(resetFSM, s3, enter);
     
endmodule


// --- CONTADOR DA FSM (Logica de Proximo Estado) ---
// Proposito: Contador sincrono de 2 bits que armazena o estado (00, 01, 10, 11).
// Possui logica para "travar" (stall) no estado 10.
module contador2b (
    input clk,
    input rst,
    input enable,          // 'Enter' ou 'Reuso'
    output [1:0] Q,        // Estado atual
    input condicao_avanco  // 'pode_avancar' (sinal de "stall")
);
    wire d0_logic, d1_logic; // Logica combinacional do proximo estado
    wire [1:0] D_final;      // Proximo estado final (D)
    wire n_enable;
    
    wire notA, notB;
    not(notA, Q[1]);
    not(notB, Q[0]);
    wire [1:0] f0, f1;
    
    // Logica de transicao D[1]
    and(f0[0], notA, Q[0]); // Estado 01
    and(f0[1], Q[1], notB); // Estado 10
    or(d1_logic, f0[0], f0[1]); // D[1] = 1 se (estado=01) OU (estado=10)
    
    // Logica de transicao D[0]
    wire estado_eh_10;
    and(estado_eh_10, Q[1], notB); // Detecta estado 10
     
    // Permite avancar do estado 10 para 11
    wire avancar_de_10;
    and(avancar_de_10, estado_eh_10, condicao_avanco);

    // Permite avancar do estado 00 para 01
    wire transicao_normal_d0;
    and(transicao_normal_d0, notA, notB); // Detecta estado 00

    // D[0] = 1 se (avancando de 00) OU (avancando de 10)
    or(d0_logic, transicao_normal_d0, avancar_de_10);

    // Logica de Habilitacao (Enable): Se enable=0, D=Q (mantem estado)
    not n1 (n_enable, enable);
    wire d0_g, q0_g;
    and a0 (d0_g, d0_logic, enable);
    and a1 (q0_g, Q[0], n_enable);
    or o0 (D_final[0], d0_g, q0g);

    wire d1_g, q1_g;
    and a2 (d1_g, d1_logic, enable);
    and a3 (q1_g, Q[1], n_enable);
    or o1 (D_final[1], d1_g, q1_g);

    // Flip-flops que armazenam o estado
    flipflopD ff0 (.D(D_final[0]), .clk(clk), .rst(rst), .Q(Q[0]));
    flipflopD ff1 (.D(D_final[1]), .clk(clk), .rst(rst), .Q(Q[1]));
     
endmodule






