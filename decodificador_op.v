// --- DECODIFICADOR DE OPCODE ---
// Converte o Opcode[2:0] em 8 sinais de selecao (um para cada operacao)
module decodificador_op(
    input [2:0] Op,
    output sel_soma,  // 000
    output sel_sub,   // 001
    output sel_multi, // 010
    output sel_div,   // 011
    output sel_and,   // 100
    output sel_or,    // 101
    output sel_xor,   // 110
    output sel_not    // 111
);

    wire nOp0, nOp1, nOp2;
    
    not not_op0(nOp0, Op[0]);
    not not_op1(nOp1, Op[1]);
    not not_op2(nOp2, Op[2]);

    // Logica de decodificacao (1-hot)
    and and_soma(sel_soma, nOp2, nOp1, nOp0); // 000
    and and_sub(sel_sub,  nOp2, nOp1, Op[0]); // 001
    and and_multi(sel_multi,  nOp2, Op[1], nOp0); // 010
    and and_div(sel_div,  nOp2, Op[1], Op[0]); // 011
    and and_and(sel_and,  Op[2], nOp1, nOp0); // 100
    and and_or(sel_or,   Op[2], nOp1, Op[0]); // 101
    and and_xor(sel_xor,  Op[2], Op[1], nOp0); // 110
    and and_not(sel_not,  Op[2], Op[1], Op[0]); // 111

endmodule


