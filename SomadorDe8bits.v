// --- SOMADOR DE 8 BITS (RIPPLE-CARRY) ---
// Proposito: Soma dois numeros de 8 bits (A e B).
// Metodo: Conecta 1 Meio-Somador (LSB) e 7 Somadores Completos (ripple-carry).
module somadorde8bits (
    S, 
    Cout, 
    OV,
    A, 
    B
);
    input [7:0] A, B;
    output [7:0] S;       // Saida da Soma
    output Cout;          // Saida Carry Out (para numeros sem sinal)
    output OV;            // Saida Overflow (para numeros com sinal)
    wire [7:0] Cin_Cout;  // Fios internos para o "vai 1" (carry)

    // Bit 0 (LSB)
    meiosomador bit1(
        .A(A[0]),
        .B(B[0]),
        .S(S[0]),
        .Cout(Cin_Cout[1]) // 'Vai 1' para o bit 1
    );

    // Bit 1
    SomadorPBL2 bit2(
        .A(A[1]),
        .B(B[1]),
        .Cin(Cin_Cout[1]), // Recebe 'vai 1' do bit 0
        .S(S[1]),
        .Cout(Cin_Cout[2]) // 'Vai 1' para o bit 2
    );

    // Bit 2
    SomadorPBL2 bit3(
        .A(A[2]),
        .B(B[2]),
        .Cin(Cin_Cout[2]),
        .S(S[2]),
        .Cout(Cin_Cout[3])
    );

    // Bit 3
    SomadorPBL2 bit4(
        .A(A[3]),
        .B(B[3]),
        .Cin(Cin_Cout[3]),
        .S(S[3]),
        .Cout(Cin_Cout[4])
    );

    // Bit 4
    SomadorPBL2 bit5(
        .A(A[4]),
        .B(B[4]),
        .Cin(Cin_Cout[4]),
        .S(S[4]),
        .Cout(Cin_Cout[5])
    );

    // Bit 5
    SomadorPBL2 bit6(
        .A(A[5]),
        .B(B[5]),
        .Cin(Cin_Cout[5]),
        .S(S[5]),
        .Cout(Cin_Cout[6])
    );

    // Bit 6
    SomadorPBL2 bit7(
        .A(A[6]),
        .B(B[6]),
        .Cin(Cin_Cout[6]),
        .S(S[6]),
        .Cout(Cin_Cout[7]) // 'Vai 1' para o bit 7
    );

    // Bit 7 (MSB)
    SomadorPBL2 bit8(
        .A(A[7]),
        .B(B[7]),
        .Cin(Cin_Cout[7]), // Recebe 'vai 1' do bit 6
        .S(S[7]),
        .Cout(Cout)       // Saida final do Carry Out
    );
    
    // Logica da Flag de Overflow (OV esta apenas copiando Cout)
    or assign_ov(OV, Cout, 1'b0); 
endmodule



// --- MEIO SOMADOR (1 BIT) ---
// Proposito: Soma dois bits (A e B). Nao tem entrada de Carry (Cin).
module meiosomador(A, B, S, Cout);
   input A, B;
   output S, Cout; // S = Soma, Cout = "Vai 1"

   xor (S, A, B);    // Logica da Soma
   and (Cout, A, B); // Logica do Carry
endmodule


// --- SOMADOR COMPLETO (1 BIT) ---
// Proposito: Soma tres bits (A, B, e Cin - "Vem 1").
module SomadorPBL2( S, Cout, A, B, Cin);
   input A, B, Cin;
   output S, Cout; // S = Soma, Cout = "Vai 1"
   wire T1, T2, T3; // Fios temporarios

   xor Xor0(T1, A, B);
   and And0(T2, A, B);
   and And1(T3, T1, Cin);
   or Or0(Cout, T2, T3); // Logica do Carry Out
   xor Xor1 (S, T1, Cin); // Logica da Soma
endmodule



// --- SOMADOR DE 16 BITS (RIPPLE-CARRY) ---
// Proposito: Soma dois numeros de 16 bits (A e B).
// Metodo: Conecta 16 Somadores Completos em cascata.
module somadorde16bits(
    input [15:0] A,
    input [15:0] B,
    output [15:0] S,
    output Cout
);
    wire [15:0] c; // Fios de "vai 1" internos

    // Instancia 16 somadores, propagando o 'c' (carry) de um para o outro
    SomadorPBL2 bit0 ( .A(A[0]), .B(B[0]), .Cin(1'b0), .S(S[0]), .Cout(c[1]));
    SomadorPBL2 bit1 ( .A(A[1]), .B(B[1]), .Cin(c[1]), .S(S[1]), .Cout(c[2]));
    SomadorPBL2 bit2 ( .A(A[2]), .B(B[2]), .Cin(c[2]), .S(S[2]), .Cout(c[3]));
    SomadorPBL2 bit3 ( .A(A[3]), .B(B[3]), .Cin(c[3]), .S(S[3]), .Cout(c[4]));
    SomadorPBL2 bit4 ( .A(A[4]), .B(B[4]), .Cin(c[4]), .S(S[4]), .Cout(c[5]));
    SomadorPBL2 bit5 ( .A(A[5]), .B(B[5]), .Cin(c[5]), .S(S[5]), .Cout(c[6]));
    SomadorPBL2 bit6 ( .A(A[6]), .B(B[6]), .Cin(c[6]), .S(S[6]), .Cout(c[7]));
    SomadorPBL2 bit7 ( .A(A[7]), .B(B[7]), .Cin(c[7]), .S(S[7]), .Cout(c[8]));
    SomadorPBL2 bit8 ( .A(A[8]), .B(B[8]), .Cin(c[8]), .S(S[8]), .Cout(c[9]));
    SomadorPBL2 bit9 ( .A(A[9]), .B(B[9]), .Cin(c[9]), .S(S[9]), .Cout(c[10]));
    SomadorPBL2 bit10( .A(A[10]),.B(B[10]),.Cin(c[10]),.S(S[10]),.Cout(c[11]));
    SomadorPBL2 bit11( .A(A[11]),.B(B[11]),.Cin(c[11]),.S(S[11]),.Cout(c[12]));
    SomadorPBL2 bit12( .A(A[12]),.B(B[12]),.Cin(c[12]),.S(S[12]),.Cout(c[13]));
    SomadorPBL2 bit13( .A(A[13]),.B(B[13]),.Cin(c[13]),.S(S[13]),.Cout(c[14]));
    SomadorPBL2 bit14( .A(A[14]),.B(B[14]),.Cin(c[14]),.S(S[14]),.Cout(c[15]));
    SomadorPBL2 bit15( .A(A[15]),.B(B[15]),.Cin(c[15]),.S(S[15]),.Cout(Cout));
endmodule



// --- SUBTRATOR COMPLETO (1 BIT) ---
// Proposito: Calcula A - B - Bin ("Vem Emprestimo").
module subtrator_PBL2(Diferenca, Bout, A, B, Bin );
    input A, B, Bin;
    output Diferenca, Bout; // Diferenca = S, Bout = "Vai Emprestimo"

    wire w1, w2, w3, w4, w5; // Fios temporarios
    xor (w1, A, B);
    xor (Diferenca, w1, Bin); // Logica da Diferenca

    not (w2, A);
    not (w5,w1);
    and (w3, w2, B);
    and (w4, w5, Bin);
    or (Bout, w3, w4); // Logica do Emprestimo (Borrow Out)
endmodule



// --- SUBTRATOR DE 8 BITS (RIPPLE-BORROW) ---
// Proposito: Calcula A - B (8 bits).
// Metodo: Conecta 8 Subtratores Completos em cascata.
module subtrator_8bits(S, Bout, A, B);
    input [7:0] A, B;
    output [7:0] S;    // Saida da Diferenca
    output Bout;       // Saida final "Borrow Out" (indica A < B)

    wire [6:0] b; // Fios internos para o "vai emprestimo"

    // Instancia 8 subtratores, propagando o 'b' (borrow) de um para o outro
    subtrator_PBL2 sub0 ( .A(A[0]), .B(B[0]), .Bin(1'b0), .Diferenca(S[0]), .Bout(b[0]));
    subtrator_PBL2 sub1 ( .A(A[1]), .B(B[1]), .Bin(b[0]), .Diferenca(S[1]), .Bout(b[1]));
    subtrator_PBL2 sub2 ( .A(A[2]), .B(B[2]), .Bin(b[1]), .Diferenca(S[2]), .Bout(b[2]));
    subtrator_PBL2 sub3 ( .A(A[3]), .B(B[3]), .Bin(b[2]), .Diferenca(S[3]), .Bout(b[3]));
    subtrator_PBL2 sub4 ( .A(A[4]), .B(B[4]), .Bin(b[3]), .Diferenca(S[4]), .Bout(b[4]));
    subtrator_PBL2 sub5 ( .A(A[5]), .B(B[5]), .Bin(b[4]), .Diferenca(S[5]), .Bout(b[5]));
    subtrator_PBL2 sub6 ( .A(A[6]), .B(B[6]), .Bin(b[5]), .Diferenca(S[6]), .Bout(b[6]));
    subtrator_PBL2 sub7 ( .A(A[7]), .B(B[7]), .Bin(b[6]), .Diferenca(S[7]), .Bout(Bout));
endmodule












