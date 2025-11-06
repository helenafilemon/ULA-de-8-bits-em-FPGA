// --- ULA Combinacional ---
// Agrupa todas as operacoes aritmeticas e logicas instantaneas.
module ULA_comb(
    input [7:0] A,
    input [7:0] B,
    input [2:0] Op,
    input [7:0] s_multi,  // Entrada do resultado do multiplicador
    input ov_mult,        // Entrada da flag de overflow do multiplicador
    
    output [7:0] S,       // Resultado final selecionado
    output Cout,
    output OV,
    output ERRO,
    output Zero,
    output R_exists_out   // Flag de resto da divisao
);

    // Fios para os resultados das operacoes
    wire [7:0] s_div, s_and, s_or, s_xor, s_not; 
    wire [7:0] sf; 
    wire r_div_exists; 
    wire erro_div;
    wire sel_soma, sel_sub, sel_multi, sel_div, sel_and, sel_or, sel_xor, sel_not;
    wire [7:0] s_soma_out, s_sub_out;
    wire cout_soma_out, ov_soma_out, bout_sub_out;

    // Instancias das unidades de operacao
    somadorde8bits som_inst (.A(A), .B(B), .S(s_soma_out), .Cout(cout_soma_out), .OV(ov_soma_out));
    subtrator_8bits sub_inst (.A(A), .B(B), .S(s_sub_out), .Bout(bout_sub_out));
    divisor div_inst ( 
        .A(A), 
        .B(B), 
        .S(s_div), 
        .R_exists(r_div_exists), 
        .ERRO(erro_div)
    );
    opLogicoAND (.A(A), .B(B), .S(s_and));
    opLogicoOR (.A(A), .B(B), .S(s_or));
    opLogicoXOR (.A(A), .B(B), .S(s_xor));
    opLogicoNOT (.A(A), .S(s_not));

    // Decodificador de Opcode
    decodificador_op (.Op(Op), .sel_soma(sel_soma), .sel_sub(sel_sub), .sel_multi(sel_multi), .sel_div(sel_div), 
        .sel_and(sel_and), .sel_or(sel_or), .sel_xor(sel_xor), .sel_not(sel_not));

    // Multiplexador para selecionar o resultado final
    mux8bOP mux_principal (
        .in_soma(s_soma_out), .in_sub(s_sub_out), .in_multi(s_multi), .in_div(s_div),
        .in_and(s_and), .in_or(s_or), .in_xor(s_xor), .in_not(s_not),
        .sel_soma(sel_soma), .sel_sub(sel_sub), .sel_multi(sel_multi), .sel_div(sel_div),
        .sel_and(sel_and), .sel_or(sel_or), .sel_xor(sel_xor), .sel_not(sel_not), 
        .S(sf));
             
    // Logica de geracao das flags
    wire notOp2, notOp1, notOp0, erro_sub_final, erro_div2;
    wire habilita_saida, zerof;
    
    not(notOp2, Op[2]);
    not(notOp1, Op[1]);
    not(notOp0, Op[0]);
    
    and(erro_sub_final, notOp2, notOp1, Op[0], bout_sub_out); 
    and(erro_div2, notOp2, Op[1], Op[0], erro_div);         
    or(ERRO, erro_sub_final, erro_div2);
    
    not(habilita_saida, ERRO); 

    and s0(S[0], sf[0], habilita_saida);
    and s1(S[1], sf[1], habilita_saida);
    and s2(S[2], sf[2], habilita_saida);
    and s3(S[3], sf[3], habilita_saida);
    and s4(S[4], sf[4], habilita_saida);
    and s5(S[5], sf[5], habilita_saida);
    and s6(S[6], sf[6], habilita_saida);
    and s7(S[7], sf[7], habilita_saida);

    nor(zerof, S[0], S[1], S[2], S[3], S[4], S[5], S[6], S[7]);
    and(Zero, zerof, habilita_saida);
    
    and(Cout, notOp2, notOp1, notOp0, habilita_saida, cout_soma_out); 

    wire ov_from_soma, ov_from_multi;
    wire ov_final_logic;
    and(ov_from_soma, sel_soma, ov_soma_out); 
    and(ov_from_multi, sel_multi, ov_mult); 
    or(ov_final_logic, ov_from_soma, ov_from_multi);
    and(OV, ov_final_logic, habilita_saida);

    or or_r_exists_out(R_exists_out, r_div_exists, 1'b0); 
        
endmodule
