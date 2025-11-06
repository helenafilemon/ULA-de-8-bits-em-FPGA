// --- Pilha RPN ---
// Armazena os dois operandos para a ULA.
module pilhaRPN(
    input [7:0] D,       // Dado de entrada
    input clk,
    input rst,
    input habilitaA,     // Sinal de carga para o primeiro nivel
    input habilitaB,     // Sinal de carga para o segundo nivel (push)
    output [7:0] saidaA, // Operando A (fundo da pilha)
    output [7:0] saidaB  // Operando B (topo da pilha)
);

    wire enable_reg_B;
    or or_enable_B(enable_reg_B, habilitaA, habilitaB);

    // Registradores que formam a pilha
    registrador8b reg_A(.D(saidaB),.clk(clk),.rst(rst),.habilita(habilitaB),.Q(saidaA));
    registrador8b reg_B(.D(D),.clk(clk),.rst(rst),.habilita(enable_reg_B),.Q(saidaB));
     
endmodule
