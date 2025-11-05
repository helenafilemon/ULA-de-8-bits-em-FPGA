module decodificador_op(
    input [2:0] Op,
    output sel_soma,
    output sel_sub,
    output sel_multi,
    output sel_div,
    output sel_and,
    output sel_or,
    output sel_xor,
    output sel_not
  // output op_valida // <--- REMOVIDO DA LISTA DE PORTAS
);

    wire nOp0, nOp1, nOp2;
    
    not(nOp0, Op[0]);
    not(nOp1, Op[1]);
    not(nOp2, Op[2]);

    // --- Lógica de Decodificação (Inalterada) ---
    and(sel_soma, nOp2, nOp1, nOp0); // 000
    and(sel_sub,  nOp2, nOp1, Op[0]); // 001
    and(sel_multi,  nOp2, Op[1], nOp0); // 010
    and(sel_div,  nOp2, Op[1], Op[0]); // 011
    and(sel_and,  Op[2], nOp1, nOp0); // 100
    and(sel_or,   Op[2], nOp1, Op[0]); // 101
    and(sel_xor,  Op[2], Op[1], nOp0); // 110
    and(sel_not,  Op[2], Op[1], Op[0]); // 111

    // --- LÓGICA 'op_valida' REMOVIDA ---
    // or(op_valida, sel_soma, sel_sub, sel_multi, sel_div, sel_and, sel_or, sel_xor, sel_not);

endmodule
