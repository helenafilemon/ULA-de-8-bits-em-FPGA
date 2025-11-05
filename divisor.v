module divisor(
    input [7:0] A,
    input [7:0] B,
    output [7:0] S,     // Quociente
    output R_exists, // Flag: 1 se Resto != 0
    output ERRO        // Erro: Divisão por zero
);
    
    // Lógica interna da divisão (estágios estdiv)
    wire [7:0] fbit, nfbit;
    wire [7:0] e0, e1, e2, e3, e4, e5, e6;
    wire [7:0] R_interno; // Fio interno para o resto de 8 bits
    wire habilita, R_existe;
    
    estdiv(.A({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, A[7]}), .B(B), .Qbit(fbit[7]), .Rs(e0));
    estdiv(.A({e0[6], e0[5], e0[4], e0[3], e0[2], e0[1], e0[0], A[6]}), .B(B), .Qbit(fbit[6]), .Rs(e1));
    estdiv(.A({e1[6], e1[5], e1[4], e1[3], e1[2], e1[1], e1[0], A[5]}), .B(B), .Qbit(fbit[5]), .Rs(e2));
    estdiv(.A({e2[6], e2[5], e2[4], e2[3], e2[2], e2[1], e2[0], A[4]}), .B(B), .Qbit(fbit[4]), .Rs(e3));
    estdiv(.A({e3[6], e3[5], e3[4], e3[3], e3[2], e3[1], e3[0], A[3]}), .B(B), .Qbit(fbit[3]), .Rs(e4));
    estdiv(.A({e4[6], e4[5], e4[4], e4[3], e4[2], e4[1], e4[0], A[2]}), .B(B), .Qbit(fbit[2]), .Rs(e5));
    estdiv(.A({e5[6], e5[5], e5[4], e5[3], e5[2], e5[1], e5[0], A[1]}), .B(B), .Qbit(fbit[1]), .Rs(e6));
    estdiv(.A({e6[6], e6[5], e6[4], e6[3], e6[2], e6[1], e6[0], A[0]}), .B(B), .Qbit(fbit[0]), .Rs(R_interno)); // Resto interno
            
    // Lógica do Quociente S
    nor(ERRO, B[0], B[1], B[2], B[3], B[4], B[5], B[6], B[7]); // Divisão por zero
    not(nfbit[0], fbit[0]);
    not(nfbit[1], fbit[1]);
    not(nfbit[2], fbit[2]);
    not(nfbit[3], fbit[3]);
    not(nfbit[4], fbit[4]);
    not(nfbit[5], fbit[5]);
    not(nfbit[6], fbit[6]);
    not(nfbit[7], fbit[7]);
    not(habilita, ERRO); // Quociente só é válido se não houver erro
    and(S[0], habilita, nfbit[0]);
    and(S[1], habilita, nfbit[1]);
    and(S[2], habilita, nfbit[2]);
    and(S[3], habilita, nfbit[3]);
    and(S[4], habilita, nfbit[4]);
    and(S[5], habilita, nfbit[5]);
    and(S[6], habilita, nfbit[6]);
    and(S[7], habilita, nfbit[7]);

    // --- LÓGICA FINAL: Flag R_exists (usando OR) ---
    // Se qualquer bit do resto interno for 1, R_exists será 1.
    or or_R_exists (R_existe, 
        R_interno[0], R_interno[1], R_interno[2], R_interno[3],
        R_interno[4], R_interno[5], R_interno[6], R_interno[7]);
     not veriferro (nER, ERRO);
    and (R_exists,R_existe, nER);
endmodule


module sub1b(
    input A,
    input B,
    input Bin,
    output S,
    output Bout);
    
    wire [2:0]f;
    wire [1:0] n;
    
    xor(f[0], A,B);
    not(n[0], A);
    and(f[1], n[0], B);
    
    xor(S, Bin, f[0]);
    not(n[1], f[0]);
    and(f[2], Bin, n[1]);
    
    or(Bout, f[1], f[2]);

endmodule

module sub8b(
    input [7:0] A,
    input [7:0] B,
    output [7:0] S,
    output Bout);
    
    wire [6:0] b;
    
    sub1b(.A(A[0]), .B(B[0]), .Bin(1'b0), .S(S[0]), .Bout(b[0]));
    sub1b(.A(A[1]), .B(B[1]), .Bin(b[0]), .S(S[1]), .Bout(b[1]));
    sub1b(.A(A[2]), .B(B[2]), .Bin(b[1]), .S(S[2]), .Bout(b[2]));
    sub1b(.A(A[3]), .B(B[3]), .Bin(b[2]), .S(S[3]), .Bout(b[3]));
    sub1b(.A(A[4]), .B(B[4]), .Bin(b[3]), .S(S[4]), .Bout(b[4]));
    sub1b(.A(A[5]), .B(B[5]), .Bin(b[4]), .S(S[5]), .Bout(b[5]));
    sub1b(.A(A[6]), .B(B[6]), .Bin(b[5]), .S(S[6]), .Bout(b[6]));
    sub1b(.A(A[7]), .B(B[7]), .Bin(b[6]), .S(S[7]), .Bout(Bout));

endmodule

module estdiv(
    input [7:0] A,
    input [7:0] B,
    output [7:0] Rs,
    output Qbit);
    
    wire [6:0] b;
    wire [7:0] S;
    
    sub8b(.A(A), .B(B), .S(S), .Bout(Qbit));
    
    mux2para1_1b (.i0(S[0]), .i1(A[0]), .sel(Qbit), .out(Rs[0]));
    mux2para1_1b (.i0(S[1]), .i1(A[1]), .sel(Qbit), .out(Rs[1]));
    mux2para1_1b (.i0(S[2]), .i1(A[2]), .sel(Qbit), .out(Rs[2]));
    mux2para1_1b (.i0(S[3]), .i1(A[3]), .sel(Qbit), .out(Rs[3]));
    mux2para1_1b (.i0(S[4]), .i1(A[4]), .sel(Qbit), .out(Rs[4]));
    mux2para1_1b (.i0(S[5]), .i1(A[5]), .sel(Qbit), .out(Rs[5]));
    mux2para1_1b (.i0(S[6]), .i1(A[6]), .sel(Qbit), .out(Rs[6]));
    mux2para1_1b (.i0(S[7]), .i1(A[7]), .sel(Qbit), .out(Rs[7]));

endmodule







