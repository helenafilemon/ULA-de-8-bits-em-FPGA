// --- DIVISOR COMBINACIONAL (Restauracao) ---
// Proposito: Implementa a divisao A / B usando o algoritmo de restauracao.
module divisor(
    input [7:0] A, // Dividendo
    input [7:0] B, // Divisor
    output [7:0] S,    // Quociente
    output R_exists, // Flag: 1 se Resto != 0
    output ERRO       // Erro: Divisao por zero
);
    
    // --- Fios Internos ---
    wire [7:0] fbit, nfbit; // fbit = 'Qbit' invertido de cada estagio
    wire [7:0] e0, e1, e2, e3, e4, e5, e6; // Fios de resto parcial entre estagios
    wire [7:0] R_interno; // Resto final (saida do ultimo estagio)
    wire habilita, R_existe, nER;

    // --- Cascata de 8 Estagios de Divisao ('estdiv') ---
    // Simula a divisao longa: desloca, puxa 1 bit de A, e tenta subtrair B
    estdiv(.A({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, A[7]}), .B(B), .Qbit(fbit[7]), .Rs(e0));
    estdiv(.A({e0[6], e0[5], e0[4], e0[3], e0[2], e0[1], e0[0], A[6]}), .B(B), .Qbit(fbit[6]), .Rs(e1));
    estdiv(.A({e1[6], e1[5], e1[4], e1[3], e1[2], e1[1], e1[0], A[5]}), .B(B), .Qbit(fbit[5]), .Rs(e2));
    estdiv(.A({e2[6], e2[5], e2[4], e2[3], e2[2], e2[1], e2[0], A[4]}), .B(B), .Qbit(fbit[4]), .Rs(e3));
    estdiv(.A({e3[6], e3[5], e3[4], e3[3], e3[2], e3[1], e3[0], A[3]}), .B(B), .Qbit(fbit[3]), .Rs(e4));
    estdiv(.A({e4[6], e4[5], e4[4], e4[3], e4[2], e4[1], e4[0], A[2]}), .B(B), .Qbit(fbit[2]), .Rs(e5));
    estdiv(.A({e5[6], e5[5], e5[4], e5[3], e5[2], e5[1], e5[0], A[1]}), .B(B), .Qbit(fbit[1]), .Rs(e6));
    estdiv(.A({e6[6], e6[5], e6[4], e6[3], e6[2], e6[1], e6[0], A[0]}), .B(B), .Qbit(fbit[0]), .Rs(R_interno));
         
    // --- Logica de Saida (Quociente e Flags) ---
    
    // ERRO = 1 se B == 0
    nor(ERRO, B[0], B[1], B[2], B[3], B[4], B[5], B[6], B[7]); 
    
    // O Quociente (S) e o 'fbit' (Borrow Out) invertido de cada estagio
    not(nfbit[0], fbit[0]);
    not(nfbit[1], fbit[1]);
    not(nfbit[2], fbit[2]);
    not(nfbit[3], fbit[3]);
    not(nfbit[4], fbit[4]);
    not(nfbit[5], fbit[5]);
    not(nfbit[6], fbit[6]);
    not(nfbit[7], fbit[7]);
    
    // A saida S so e valida se ERRO=0
    not(habilita, ERRO); 
    and(S[0], habilita, nfbit[0]);
    and(S[1], habilita, nfbit[1]);
    and(S[2], habilita, nfbit[2]);
    and(S[3], habilita, nfbit[3]);
    and(S[4], habilita, nfbit[4]);
    and(S[5], habilita, nfbit[5]);
    and(S[6], habilita, nfbit[6]);
    and(S[7], habilita, nfbit[7]);

    // R_exists = 1 se (Resto != 0) E (Nao houver Erro)
    or or_R_exists (R_existe, 
        R_interno[0], R_interno[1], R_interno[2], R_interno[3],
        R_interno[4], R_interno[5], R_interno[6], R_interno[7]);
    not veriferro (nER, ERRO);
    and (R_exists,R_existe, nER);
endmodule



module sub8b(
    input [7:0] A,
    input [7:0] B,
    output [7:0] S,
    output Bout);
    
    wire [6:0] b;
    
    subtrator_PBL2(.A(A[0]), .B(B[0]), .Bin(1'b0), .Diferenca(S[0]), .Bout(b[0]));
    subtrator_PBL2(.A(A[1]), .B(B[1]), .Bin(b[0]), .Diferenca(S[1]), .Bout(b[1]));
    subtrator_PBL2(.A(A[2]), .B(B[2]), .Bin(b[1]), .Diferenca(S[2]), .Bout(b[2]));
    subtrator_PBL2(.A(A[3]), .B(B[3]), .Bin(b[2]), .Diferenca(S[3]), .Bout(b[3]));
    subtrator_PBL2(.A(A[4]), .B(B[4]), .Bin(b[3]), .Diferenca(S[4]), .Bout(b[4]));
    subtrator_PBL2(.A(A[5]), .B(B[5]), .Bin(b[4]), .Diferenca(S[5]), .Bout(b[5]));
    subtrator_PBL2(.A(A[6]), .B(B[6]), .Bin(b[5]), .Diferenca(S[6]), .Bout(b[6]));
    subtrator_PBL2(.A(A[7]), .B(B[7]), .Bin(b[6]), .Diferenca(S[7]), .Bout(Bout));

endmodule

// --- ESTAGIO DE DIVISAO (1 Estagio) ---
// Proposito: Tenta subtrair B de A. Se A < B (Qbit=1), restaura A. Senao (Qbit=0), mantem S.
module estdiv(
    input [7:0] A, // Resto parcial do estagio anterior
    input [7:0] B, // Divisor
    output [7:0] Rs, // Resto parcial para o proximo estagio
    output Qbit    // Bit do quociente (invertido: 1=falha, 0=sucesso)
);
    
    wire [7:0] S; // Resultado da subtracao
    
    // 1. Tenta subtrair: S = A - B. Qbit e o Borrow Out.
    sub8b(.A(A), .B(B), .S(S), .Bout(Qbit));
    
    // 2. MUX de Restauracao: Se Qbit=1 (falha), Rs=A. Se Qbit=0 (sucesso), Rs=S.
    mux2para1_1b (.i0(S[0]), .i1(A[0]), .sel(Qbit), .out(Rs[0]));
    mux2para1_1b (.i0(S[1]), .i1(A[1]), .sel(Qbit), .out(Rs[1]));
    mux2para1_1b (.i0(S[2]), .i1(A[2]), .sel(Qbit), .out(Rs[2]));
    mux2para1_1b (.i0(S[3]), .i1(A[3]), .sel(Qbit), .out(Rs[3]));
    mux2para1_1b (.i0(S[4]), .i1(A[4]), .sel(Qbit), .out(Rs[4]));
    mux2para1_1b (.i0(S[5]), .i1(A[5]), .sel(Qbit), .out(Rs[5]));
    mux2para1_1b (.i0(S[6]), .i1(A[6]), .sel(Qbit), .out(Rs[6]));
    mux2para1_1b (.i0(S[7]), .i1(A[7]), .sel(Qbit), .out(Rs[7]));

endmodule








