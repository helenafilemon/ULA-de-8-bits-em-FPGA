module mux2para1_1b(
    input i0, i1, sel, 
    output out);
    
    wire nsel, f1, f2; 
    not n1(nsel,sel); 
    and a1(f1,i0,nsel); 
    and a2(f2,i1,sel); 
    or o1(out,f1,f2);
    
endmodule

module mux2para1_8b(
    input [7:0] i0, i1, 
    input sel, 
    output [7:0] out);
    
    mux2para1_1b m0(.i0(i0[0]),.i1(i1[0]),.sel(sel),.out(out[0])); 
    mux2para1_1b m1(.i0(i0[1]),.i1(i1[1]),.sel(sel),.out(out[1]));
    mux2para1_1b m2(.i0(i0[2]),.i1(i1[2]),.sel(sel),.out(out[2])); 
    mux2para1_1b m3(.i0(i0[3]),.i1(i1[3]),.sel(sel),.out(out[3]));
    mux2para1_1b m4(.i0(i0[4]),.i1(i1[4]),.sel(sel),.out(out[4])); 
    mux2para1_1b m5(.i0(i0[5]),.i1(i1[5]),.sel(sel),.out(out[5]));
    mux2para1_1b m6(.i0(i0[6]),.i1(i1[6]),.sel(sel),.out(out[6])); 
    mux2para1_1b m7(.i0(i0[7]),.i1(i1[7]),.sel(sel),.out(out[7]));
     
endmodule

module mux16b_2para1 (
    input [15:0] i0, i1, 
    input sel, 
    output [15:0] out);

    mux2para1_1b m0(.i0(i0[0]),.i1(i1[0]),.sel(sel),.out(out[0])); 
    mux2para1_1b m1(.i0(i0[1]),.i1(i1[1]),.sel(sel),.out(out[1]));
    mux2para1_1b m2(.i0(i0[2]),.i1(i1[2]),.sel(sel),.out(out[2])); 
    mux2para1_1b m3(.i0(i0[3]),.i1(i1[3]),.sel(sel),.out(out[3]));
    mux2para1_1b m4(.i0(i0[4]),.i1(i1[4]),.sel(sel),.out(out[4])); 
    mux2para1_1b m5(.i0(i0[5]),.i1(i1[5]),.sel(sel),.out(out[5]));
    mux2para1_1b m6(.i0(i0[6]),.i1(i1[6]),.sel(sel),.out(out[6])); 
    mux2para1_1b m7(.i0(i0[7]),.i1(i1[7]),.sel(sel),.out(out[7]));
    mux2para1_1b m8(.i0(i0[8]),.i1(i1[8]),.sel(sel),.out(out[8])); 
    mux2para1_1b m9(.i0(i0[9]),.i1(i1[9]),.sel(sel),.out(out[9]));
    mux2para1_1b m10(.i0(i0[10]),.i1(i1[10]),.sel(sel),.out(out[10])); 
    mux2para1_1b m11(.i0(i0[11]),.i1(i1[11]),.sel(sel),.out(out[11]));
    mux2para1_1b m12(.i0(i0[12]),.i1(i1[12]),.sel(sel),.out(out[12])); 
    mux2para1_1b m13(.i0(i0[13]),.i1(i1[13]),.sel(sel),.out(out[13]));
    mux2para1_1b m14(.i0(i0[14]),.i1(i1[14]),.sel(sel),.out(out[14])); 
    mux2para1_1b m15(.i0(i0[15]),.i1(i1[15]),.sel(sel),.out(out[15]));
     
endmodule

// --- MUX 8-para-1 (8 bits) ---
// Proposito: Usado na ULA_comb para selecionar o resultado da operacao correta.
module mux8bOP(
    input [7:0] in_soma, in_sub, in_multi, in_div, in_and, in_or, in_xor, in_not,
    input sel_soma, sel_sub, sel_multi, sel_div, sel_and, sel_or, sel_xor, sel_not,
    output [7:0] S
);

    wire [7:0] s_soma, s_sub, s_multi, s_div, s_and, s_or, s_xor, s_not;

    // Logica AND/OR para cada bit de saida
    
    // Bit 0: S[0] = (sel_soma AND in_soma[0]) OR (sel_sub AND in_sub[0]) OR ...
    and(s_soma[0], sel_soma, in_soma[0]);
    and(s_sub[0], sel_sub, in_sub[0]);
    and(s_multi[0], sel_multi, in_multi[0]);
    and(s_div[0], sel_div, in_div[0]);
    and(s_and[0], sel_and, in_and[0]);
    and(s_or[0], sel_or, in_or[0]);
    and(s_xor[0], sel_xor, in_xor[0]);
    and(s_not[0], sel_not, in_not[0]);
    or(S[0], s_soma[0], s_sub[0], s_multi[0], s_div[0], s_and[0], s_or[0], s_xor[0], s_not[0]);

    // Bit 1
    and(s_soma[1], sel_soma, in_soma[1]);
    and(s_sub[1], sel_sub, in_sub[1]);
    and(s_multi[1], sel_multi, in_multi[1]);
    and(s_div[1], sel_div, in_div[1]);
    and(s_and[1], sel_and, in_and[1]);
    and(s_or[1], sel_or, in_or[1]);
    and(s_xor[1], sel_xor, in_xor[1]);
    and(s_not[1], sel_not, in_not[1]);
    or(S[1], s_soma[1], s_sub[1], s_multi[1], s_div[1], s_and[1], s_or[1], s_xor[1], s_not[1]);

    // Bit 2
    and(s_soma[2], sel_soma, in_soma[2]);
    and(s_sub[2], sel_sub, in_sub[2]);
    and(s_multi[2], sel_multi, in_multi[2]);
    and(s_div[2], sel_div, in_div[2]);
    and(s_and[2], sel_and, in_and[2]);
    and(s_or[2], sel_or, in_or[2]);
    and(s_xor[2], sel_xor, in_xor[2]);
    and(s_not[2], sel_not, in_not[2]);
    or(S[2], s_soma[2], s_sub[2], s_multi[2], s_div[2], s_and[2], s_or[2], s_xor[2], s_not[2]);

    // Bit 3
    and(s_soma[3], sel_soma, in_soma[3]);
    and(s_sub[3], sel_sub, in_sub[3]);
    and(s_multi[3], sel_multi, in_multi[3]);
    and(s_div[3], sel_div, in_div[3]);
    and(s_and[3], sel_and, in_and[3]);
    and(s_or[3], sel_or, in_or[3]);
    and(s_xor[3], sel_xor, in_xor[3]);
    and(s_not[3], sel_not, in_not[3]);
    or(S[3], s_soma[3], s_sub[3], s_multi[3], s_div[3], s_and[3], s_or[3], s_xor[3], s_not[3]);

    // Bit 4
    and(s_soma[4], sel_soma, in_soma[4]);
    and(s_sub[4], sel_sub, in_sub[4]);
    and(s_multi[4], sel_multi, in_multi[4]);
    and(s_div[4], sel_div, in_div[4]);
    and(s_and[4], sel_and, in_and[4]);
    and(s_or[4], sel_or, in_or[4]);
    and(s_xor[4], sel_xor, in_xor[4]);
    and(s_not[4], sel_not, in_not[4]);
    or(S[4], s_soma[4], s_sub[4], s_multi[4], s_div[4], s_and[4], s_or[4], s_xor[4], s_not[4]);

    // Bit 5
    and(s_soma[5], sel_soma, in_soma[5]);
    and(s_sub[5], sel_sub, in_sub[5]);
    and(s_multi[5], sel_multi, in_multi[5]);
    and(s_div[5], sel_div, in_div[5]);
    and(s_and[5], sel_and, in_and[5]);
    and(s_or[5], sel_or, in_or[5]);
    and(s_xor[5], sel_xor, in_xor[5]);
    and(s_not[5], sel_not, in_not[5]);
    or(S[5], s_soma[5], s_sub[5], s_multi[5], s_div[5], s_and[5], s_or[5], s_xor[5], s_not[5]);

    // Bit 6
    and(s_soma[6], sel_soma, in_soma[6]);
    and(s_sub[6], sel_sub, in_sub[6]);
    and(s_multi[6], sel_multi, in_multi[6]);
    and(s_div[6], sel_div, in_div[6]);
    and(s_and[6], sel_and, in_and[6]);
    and(s_or[6], sel_or, in_or[6]);
    and(s_xor[6], sel_xor, in_xor[6]);
    and(s_not[6], sel_not, in_not[6]);
    or(S[6], s_soma[6], s_sub[6], s_multi[6], s_div[6], s_and[6], s_or[6], s_xor[6], s_not[6]);

    // Bit 7
    and(s_soma[7], sel_soma, in_soma[7]);
    and(s_sub[7], sel_sub, in_sub[7]);
    and(s_multi[7], sel_multi, in_multi[7]);
    and(s_div[7], sel_div, in_div[7]);
    and(s_and[7], sel_and, in_and[7]);
    and(s_or[7], sel_or, in_or[7]);
    and(s_xor[7], sel_xor, in_xor[7]);
    and(s_not[7], sel_not, in_not[7]);
    or(S[7], s_soma[7], s_sub[7], s_multi[7], s_div[7], s_and[7], s_or[7], s_xor[7], s_not[7]);

endmodule






