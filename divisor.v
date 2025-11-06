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
    wire [7:0] r0, r1, r2, r3, r4, r5, r6; // Fios de resto parcial entre estagios
    wire [7:0] Resto_int; // Resto final (saida do ultimo estagio)
    wire habilita, Resto_existe, nER;

    // --- Cascata de 8 Estagios de Divisao ('estdiv') ---
    // Simula a divisao longa: desloca, puxa 1 bit de A, e tenta subtrair B
    estdiv(.A({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, A[7]}), .B(B), .Qbit(fbit[7]), .Rs(r0));
    estdiv(.A({r0[6], r0[5], r0[4], r0[3], r0[2], r0[1], r0[0], A[6]}), .B(B), .Qbit(fbit[6]), .Rs(r1));
    estdiv(.A({r1[6], r1[5], r1[4], r1[3], r1[2], r1[1], r1[0], A[5]}), .B(B), .Qbit(fbit[5]), .Rs(r2));
    estdiv(.A({r2[6], r2[5], r2[4], r2[3], r2[2], r2[1], r2[0], A[4]}), .B(B), .Qbit(fbit[4]), .Rs(r3));
    estdiv(.A({r3[6], r3[5], r3[4], r3[3], r3[2], r3[1], r3[0], A[3]}), .B(B), .Qbit(fbit[3]), .Rs(r4));
    estdiv(.A({r4[6], r4[5], r4[4], r4[3], r4[2], r4[1], r4[0], A[2]}), .B(B), .Qbit(fbit[2]), .Rs(r5));
    estdiv(.A({r5[6], r5[5], r5[4], r5[3], r5[2], r5[1], r5[0], A[1]}), .B(B), .Qbit(fbit[1]), .Rs(r6));
    estdiv(.A({r6[6], r6[5], r6[4], r6[3], r6[2], r6[1], r6[0], A[0]}), .B(B), .Qbit(fbit[0]), .Rs(Resto_int));
         
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
    or or_R_exists (Resto_existe, 
        Resto_int[0], Resto_int[1], Resto_int[2], Resto_int[3],
        Resto_int[4], Resto_int[5], Resto_int[6], Resto_int[7]);
    not veriferro (nER, ERRO);
    and (R_exists,Resto_existe, nER);
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
    subtrator_8bits(.A(A), .B(B), .S(S), .Bout(Qbit));
    
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
