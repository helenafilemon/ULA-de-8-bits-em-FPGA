module pilhaRPN(
    input [7:0] D,
    input clk,
    input rst,
    input habilitaA,
    input habilitaB,
    output [7:0] saidaA,
    output [7:0] saidaB
);

    wire enable_reg_B;
    or or_enable_B(enable_reg_B, habilitaA, habilitaB);

    registrador8b reg_A(.D(saidaB),.clk(clk),.rst(rst),.habilita(habilitaB),.Q(saidaA));
    registrador8b reg_B(.D(D),.clk(clk),.rst(rst),.habilita(enable_reg_B),.Q(saidaB));
     
endmodule