module somadorde8bits (
    S, 
    Cout, 
    OV,
    A, 
    B
);
    input [7:0] A, B;
    output [7:0] S;
    output Cout;
    output OV; 
    wire [7:0] Cin_Cout; // Fio para o carry entre os bits
    
    // Bit 0 (LSB)
    meiosomador bit1(
        .A(A[0]),
        .B(B[0]),
        .S(S[0]),
        .Cout(Cin_Cout[1]) // Carry OUT vai para o bit 1
    );

    // Bit 1
    SomadorPBL2 bit2(
        .A(A[1]),
        .B(B[1]),
        .Cin(Cin_Cout[1]), // Carry IN do bit 0
        .S(S[1]),
        .Cout(Cin_Cout[2]) // Carry OUT vai para o bit 2
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
        .Cout(Cin_Cout[7]) // Carry OUT vai para o bit 7 (MSB)
    );

    // Bit 7 (MSB)
    SomadorPBL2 bit8(
        .A(A[7]),
        .B(B[7]),
        .Cin(Cin_Cout[7]), // Carry IN do bit 6
        .S(S[7]),
        .Cout(Cout)        // Carry OUT final do somador
    );
    
    or assign_ov(OV, Cout, 1'b0); 


endmodule


module meiosomador(A, B, S, Cout);
   input A, B;
   output S, Cout;

   xor (S, A, B);
   and (Cout, A, B);

    
endmodule

module SomadorPBL2( S, Cout, A, B, Cin);
   input A, B, Cin;
   output S, Cout;
   wire T1, T2, T3;

   xor Xor0(T1, A, B);
   and And0(T2, A, B);
   and And1(T3, T1, Cin);
   or Or0(Cout, T2, T3);
   xor Xor1 (S, T1, Cin);
endmodule


module somadorde16bits(
    input [15:0] A,
    input [15:0] B,
    
    output [15:0] S,
    output Cout
);

    // Fio para a cadeia de carry-outs intermediários
    wire [15:0] c; // c[0] é o carry-in do bit 0, c[1] é o carry-out do bit 0 (e carry-in do bit 1), etc. c[15] é o Cout final.

    // Bit 0 (LSB)
    SomadorPBL2 bit0 ( // Instanciando SomadorPBL2
        .A(A[0]), 
        .B(B[0]), 
        .Cin(1'b0), // Carry In inicial é 0
        .S(S[0]), 
        .Cout(c[1]) // Carry Out vai para o bit 1
    );

    // Bit 1
    SomadorPBL2 bit1 ( // Instanciando SomadorPBL2
        .A(A[1]), 
        .B(B[1]), 
        .Cin(c[1]), // Carry In do bit 0
        .S(S[1]), 
        .Cout(c[2]) // Carry Out vai para o bit 2
    );

    // Bit 2
    SomadorPBL2 bit2 ( // Instanciando SomadorPBL2
        .A(A[2]), 
        .B(B[2]), 
        .Cin(c[2]), 
        .S(S[2]), 
        .Cout(c[3])
    );

    // Bit 3
    SomadorPBL2 bit3 ( // Instanciando SomadorPBL2
        .A(A[3]), 
        .B(B[3]), 
        .Cin(c[3]), 
        .S(S[3]), 
        .Cout(c[4])
    );

    // Bit 4
    SomadorPBL2 bit4 ( // Instanciando SomadorPBL2
        .A(A[4]), 
        .B(B[4]), 
        .Cin(c[4]), 
        .S(S[4]), 
        .Cout(c[5])
    );

    // Bit 5
    SomadorPBL2 bit5 ( // Instanciando SomadorPBL2
        .A(A[5]), 
        .B(B[5]), 
        .Cin(c[5]), 
        .S(S[5]), 
        .Cout(c[6])
    );

    // Bit 6
    SomadorPBL2 bit6 ( // Instanciando SomadorPBL2
        .A(A[6]), 
        .B(B[6]), 
        .Cin(c[6]), 
        .S(S[6]), 
        .Cout(c[7])
    );

    // Bit 7
    SomadorPBL2 bit7 ( // Instanciando SomadorPBL2
        .A(A[7]), 
        .B(B[7]), 
        .Cin(c[7]), 
        .S(S[7]), 
        .Cout(c[8])
    );

    // Bit 8
    SomadorPBL2 bit8 ( // Instanciando SomadorPBL2
        .A(A[8]), 
        .B(B[8]), 
        .Cin(c[8]), 
        .S(S[8]), 
        .Cout(c[9])
    );

    // Bit 9
    SomadorPBL2 bit9 ( // Instanciando SomadorPBL2
        .A(A[9]), 
        .B(B[9]), 
        .Cin(c[9]), 
        .S(S[9]), 
        .Cout(c[10])
    );

    // Bit 10
    SomadorPBL2 bit10 ( // Instanciando SomadorPBL2
        .A(A[10]), 
        .B(B[10]), 
        .Cin(c[10]), 
        .S(S[10]), 
        .Cout(c[11])
    );

    // Bit 11
    SomadorPBL2 bit11 ( // Instanciando SomadorPBL2
        .A(A[11]), 
        .B(B[11]), 
        .Cin(c[11]), 
        .S(S[11]), 
        .Cout(c[12])
    );

    // Bit 12
    SomadorPBL2 bit12 ( // Instanciando SomadorPBL2
        .A(A[12]), 
        .B(B[12]), 
        .Cin(c[12]), 
        .S(S[12]), 
        .Cout(c[13])
    );

    // Bit 13
    SomadorPBL2 bit13 ( // Instanciando SomadorPBL2
        .A(A[13]), 
        .B(B[13]), 
        .Cin(c[13]), 
        .S(S[13]), 
        .Cout(c[14])
    );

    // Bit 14
    SomadorPBL2 bit14 ( // Instanciando SomadorPBL2
        .A(A[14]), 
        .B(B[14]), 
        .Cin(c[14]), 
        .S(S[14]), 
        .Cout(c[15]) // Carry Out vai para o bit 15
    );

    // Bit 15 (MSB)
    SomadorPBL2 bit15 ( // Instanciando SomadorPBL2
        .A(A[15]), 
        .B(B[15]), 
        .Cin(c[15]), // Carry In do bit 14
        .S(S[15]), 
        .Cout(Cout)  // Carry Out final do somador de 16 bits
    );

endmodule



module subtrator_PBL2(Diferenca, Bout, A, B, Bin );
    input A, B, Bin;
    output Diferenca, Bout;

    wire w1, w2, w3, w4, w5;
    xor (w1, A, B);
    xor (Diferenca, w1, Bin);

    not (w2, A);
    not (w5,w1);
    and (w3, w2, B);
    and (w4, w5, Bin);
    or (Bout, w3, w4);

endmodule
module subtrator_8bits(S, Bout, A, B);
    input [7:0] A, B;
    output [7:0] S;
    output Bout; // Bout = 1 indica que A < B (resultado seria negativo)

    wire [6:0] b; // Fios para o borrow intermediário

    // Bit 0 (LSB)
    subtrator_PBL2 sub0 (
        .A(A[0]), // A é o minuendo
        .B(B[0]), // B é o subtraendo
        .Bin(1'b0), // Borrow In inicial é 0
        .Diferenca(S[0]),
        .Bout(b[0]) // Borrow Out para o próximo bit
    );

    // Bit 1
    subtrator_PBL2 sub1 (
        .A(A[1]),
        .B(B[1]),
        .Bin(b[0]), // Borrow In do bit anterior
        .Diferenca(S[1]),
        .Bout(b[1])
    );

    // Bit 2
    subtrator_PBL2 sub2 (
        .A(A[2]),
        .B(B[2]),
        .Bin(b[1]),
        .Diferenca(S[2]),
        .Bout(b[2])
    );

    // Bit 3
    subtrator_PBL2 sub3 (
        .A(A[3]),
        .B(B[3]),
        .Bin(b[2]),
        .Diferenca(S[3]),
        .Bout(b[3])
    );
     
    // Bit 4
     subtrator_PBL2 sub4 (
        .A(A[4]),
        .B(B[4]),
        .Bin(b[3]),
        .Diferenca(S[4]),
        .Bout(b[4])
    );
     
    // Bit 5
     subtrator_PBL2 sub5 (
        .A(A[5]),
        .B(B[5]),
        .Bin(b[4]),
        .Diferenca(S[5]),
        .Bout(b[5])
    );
     
    // Bit 6
     subtrator_PBL2 sub6 (
        .A(A[6]),
        .B(B[6]),
        .Bin(b[5]),
        .Diferenca(S[6]),
        .Bout(b[6])
    );
     
    // Bit 7 (MSB)
     subtrator_PBL2 sub7 (
        .A(A[7]),
        .B(B[7]),
        .Bin(b[6]),
        .Diferenca(S[7]),
        .Bout(Bout) // Borrow Out final do subtrator
    );

endmodule
