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
    wire [7:0] Cin_Cout;
    
      Meiosomador bit1(
        .A(A[0]),
        .B(B[0]),
        .S(S[0]),
        .Cout(Cin_Cout[1])
    );
    SomadorPBL2 bit2(
        .A(A[1]),
        .B(B[1]),
        .Cin(Cin_Cout[1]),
        .S(S[1]),
        .Cout(Cin_Cout[2])
    );
    SomadorPBL2 bit3(
        .A(A[2]),
        .B(B[2]),
        .Cin(Cin_Cout[2]),
        .S(S[2]),
        .Cout(Cin_Cout[3])
    );
    SomadorPBL2 bit4(
        .A(A[3]),
        .B(B[3]),
        .Cin(Cin_Cout[3]),
        .S(S[3]),
        .Cout(Cin_Cout[4])
    );
    SomadorPBL2 bit5(
        .A(A[4]),
        .B(B[4]),
        .Cin(Cin_Cout[4]),
        .S(S[4]),
        .Cout(Cin_Cout[5])
    );
    SomadorPBL2 bit6(
        .A(A[5]),
        .B(B[5]),
        .Cin(Cin_Cout[5]),
        .S(S[5]),
        .Cout(Cin_Cout[6])
    );
    SomadorPBL2 bit7(
        .A(A[6]),
        .B(B[6]),
        .Cin(Cin_Cout[6]),
        .S(S[6]),
        .Cout(Cin_Cout[7])
    );
    SomadorPBL2 bit8(
        .A(A[7]),
        .B(B[7]),
        .Cin(Cin_Cout[7]),
        .S(S[7]),
        .Cout(Cout)
    );
    
    // Calcula Overflow (Cout do penúltimo bit XOR Cout do último bit)
    xor(OV, Cin_Cout[7], Cout); // <--- LÓGICA DE OV ADICIONADA

endmodule
