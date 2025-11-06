// --- PILHA RPN (2 Niveis) ---
// Proposito: Armazena os operandos A (fundo) e B (topo).
module pilhaRPN(
    input [7:0] D,     // Novo dado a ser empurrado
    input clk,
    input rst,
    input habilitaA,   // Sinal de 'push' vindo do estado 00
    input habilitaB,   // Sinal de 'push' vindo do estado 01
    output [7:0] saidaA, // Operando A (fundo)
    output [7:0] saidaB  // Operando B (topo)
);

    wire enable_reg_B;
    // 'enable_reg_B' e ativado se 'habilitaA' OU 'habilitaB' estiverem ativos.
    or or_enable_B(enable_reg_B, habilitaA, habilitaB);

    // reg_A (fundo) recebe o valor antigo de B (saidaB)
    registrador8b reg_A(.D(saidaB),.clk(clk),.rst(rst),.habilita(habilitaB),.Q(saidaA));
    // reg_B (topo) recebe o novo dado (D)
    registrador8b reg_B(.D(D),.clk(clk),.rst(rst),.habilita(enable_reg_B),.Q(saidaB));
     
endmodule


