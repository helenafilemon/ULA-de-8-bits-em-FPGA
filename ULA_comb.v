// --- ULA COMBINACIONAL ---
// Proposito: Agrega todas as 8 operacoes em um unico modulo.
module ULA_comb(
    input [7:0] A,
    input [7:0] B,
    input [2:0] Op,
    input [7:0] s_multi,  // Entrada para o resultado do multiplicador
    input ov_mult,        // Entrada para a flag de overflow do multiplicador
    
    output [7:0] S,       // Saida final do resultado
    output Cout,
    output OV,
    output ERRO,
    output Zero,
    output R_exists_out  // Saida da flag de Resto (da divisao)
);

    wire [7:0] s_div, s_and, s_or, s_xor, s_not; 
    wire [7:0] sf; // Saida do MUX principal
    wire r_div_exists; 
    wire erro_div;
    wire sel_soma, sel_sub, sel_multi, sel_div, sel_and, sel_or, sel_xor, sel_not;
    wire [7:0] s_soma_out, s_sub_out;
    wire cout_soma_out, ov_soma_out, bout_sub_out;

    // 1. Instancia todas as 8 unidades de calculo
    somadorde8bits som_inst (.A(A), .B(B), .S(s_soma_out), .Cout(cout_soma_out), .OV(ov_soma_out));
    subtrator_8bits sub_inst (.A(A), .B(B), .S(s_sub_out), .Bout(bout_sub_out));
    divisor div_inst ( .A(A), .B(B), .S(s_div), .R_exists(r_div_exists), .ERRO(erro_div));
    opLogicoAND (.A(A), .B(B), .S(s_and));
    opLogicoOR (.A(A), .B(B), .S(s_or));
    opLogicoXOR (.A(A), .B(B), .S(s_xor));
    opLogicoNOT (.A(A), .S(s_not));

    // 2. Decodifica o Opcode para gerar os sinais 'sel'
    decodificador_op (.Op(Op), .sel_soma(sel_soma), .sel_sub(sel_sub), .sel_multi(sel_multi), .sel_div(sel_div), 
        .sel_and(sel_and), .sel_or(sel_or), .sel_xor(sel_xor), .sel_not(sel_not));

    // 3. MUX principal: seleciona o resultado correto com base nos sinais 'sel'
    mux8bOP mux_principal (
        .in_soma(s_soma_out), .in_sub(s_sub_out), .in_multi(s_multi), .in_div(s_div),
        .in_and(s_and), .in_or(s_or), .in_xor(s_xor), .in_not(s_not),
        .sel_soma(sel_soma), .sel_sub(sel_sub), .sel_multi(sel_multi), .sel_div(sel_div),
        .sel_and(sel_and), .sel_or(sel_or), .sel_xor(sel_xor), .sel_not(sel_not), 
        .S(sf));
         
    // 4. Logica de Flags (baseada no Opcode e nos resultados)
    wire notOp2, notOp1, notOp0, erro_sub_final, erro_div2;
    wire habilita_saida, zerof;
    
    not(notOp2, Op[2]);
    not(notOp1, Op[1]);
    not(notOp0, Op[0]);
    
    // ERRO = (Erro de Subtracao) OU (Erro de Divisao)
    and(erro_sub_final, notOp2, notOp1, Op[0], bout_sub_out); // Erro Sub (001)
    and(erro_div2, notOp2, Op[1], Op[0], erro_div);       // Erro Div (011)
    or(ERRO, erro_sub_final, erro_div2);
    
    // Zera a saida S se houver erro
    not(habilita_saida, ERRO); 
    and s0(S[0], sf[0], habilita_saida);
    and s1(S[1], sf[1], habilita_saida);
    and s2(S[2], sf[2], habilita_saida);
    and s3(S[3], sf[3], habilita_saida);
    and s4(S[4], sf[4], habilita_saida);
    and s5(S[5], sf[5], habilita_saida);
    and s6(S[6], sf[6], habilita_saida);
    and s7(S[7], sf[7], habilita_saida);

    // Flag Zero: S == 0?
    nor(zerof, S[0], S[1], S[2], S[3], S[4], S[5], S[6], S[7]);
    and(Zero, zerof, habilita_saida);
    
    // Flag Cout: Apenas para Soma (000)
    and(Cout, notOp2, notOp1, notOp0, habilita_saida, cout_soma_out); 

    // Flag Overflow: Apenas para Soma (000) ou Multiplicacao (010)
    wire ov_from_soma, ov_from_multi;
    wire ov_final_logic;
    and(ov_from_soma, sel_soma, ov_soma_out); 
    and(ov_from_multi, sel_multi, ov_mult); 
    or(ov_final_logic, ov_from_soma, ov_from_multi);
    and(OV, ov_final_logic, habilita_saida);

    // Passa a flag de Resto da Divisao para a saida
    or or_r_exists_out(R_exists_out, r_div_exists, 1'b0);
        
endmodule


