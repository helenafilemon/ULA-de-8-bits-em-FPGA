// --- Multiplicador Sequencial ---
// Executa a multiplicacao em 9 ciclos de clock.
module multiplicador(
    input clk,
    input rst,
    input start,
    input [7:0] A,
    input [7:0] B,
    output done,
    output [7:0] S_result, 
    output ov            
);

    wire [3:0] contador;
    wire contando; 
    wire load; 
    wire shift_enable; 
    wire somar; 
    wire cont_zero; 
    wire habilita_reg; 
    wire [15:0] regQ; 
    wire [15:0] regD;
    wire [15:0] somaA, somaS;
    wire [15:0] depoisShift;
    wire [15:0] vaiShift;
    wire [15:0] inicial;
    wire cout;

    // Logica de controle da maquina de estados interna
    wire running; 
    wire d_running; 
    wire n_done;
    
    not(n_done, done);
    or(d_running, start, running);    
    and(d_running_final, d_running, n_done); 
    
    flipflopD ff_running (.D(d_running_final), .clk(clk), .rst(rst), .Q(running));
    
    contador9 counter_9cycles (.clk(clk), .rst(rst), .enable(shift_enable), .Q(contador)); 
    comparadorZero comp_zero (.cont(contador), .EQ(cont_zero));
    comparadorMenor9 comp_less9 (.cont3(contador[3]), .cont0(contador[0]), .LT(contando)); 
    comparadorE9 comp_done (.cont(contador), .EQ(done)); 

    and (load, start, cont_zero); 
    and (shift_enable, running, contando); 
    and (somar, shift_enable, regQ[0]);
    or (habilita_reg, load, shift_enable);

    // Caminho de dados do multiplicador
    somadorde16bits adder16bit (.A(somaA), .B(regQ), .S(somaS), .Cout(cout));
    concat8x16 CONCAT_somaA (.in_high(A), .in_low(8'b00000000), .out(somaA));
    mux16b_2para1 ADD_SEL(.i0(regQ), .i1(somaS), .sel(somar), .out(vaiShift));
    wire vaiCout;
    and(vaiCout, somar, cout);
    shifter16b SHIFTER(.in(vaiShift), .cin(vaiCout), .out(depoisShift));
    concat8x16 CONCAT_INITIAL_VAL (.in_high(8'b00000000), .in_low(B), .out(inicial));
    mux16b_2para1 LOAD_SEL(.i0(depoisShift), .i1(inicial), .sel(load), .out(regD));
    registrador16b reg_principal (.D(regD), .clk(clk), .rst(rst), .habilita(habilita_reg), .Q(regQ));

    // Saida do resultado
    or s0(S_result[0], regQ[0], 1'b0);
    or s1(S_result[1], regQ[1], 1'b0);
    or s2(S_result[2], regQ[2], 1'b0);
    or s3(S_result[3], regQ[3], 1'b0);
    or s4(S_result[4], regQ[4], 1'b0);
    or s5(S_result[5], regQ[5], 1'b0);
    or s6(S_result[6], regQ[6], 1'b0);
    or s7(S_result[7], regQ[7], 1'b0);

    wire ov_bits;
    or or_ov_bits(ov_bits, regQ[8], regQ[9], regQ[10], regQ[11], regQ[12], regQ[13], regQ[14], regQ[15]);
    or or_ov(ov, ov_bits, 1'b0); 

endmodule




module contador9 (
    input clk,
    input rst,
    input enable,
    output [3:0] Q
);
    wire d0, d1, d2, d3;
    wire t0, t1, t2, t3; 
    wire aux1, aux2;
    wire gnd = 1'b0;

    or (t0, enable, gnd);
    and (t1, Q[0], enable);
    and (aux1, Q[1], Q[0]);
    and (t2, aux1, enable);
    and (aux2, Q[2], aux1);
    and (t3, aux2, enable);
    
    xor (d0, Q[0], t0);
    xor (d1, Q[1], t1);
    xor (d2, Q[2], t2);
    xor (d3, Q[3], t3);
    
    flipflopD FF0 (.D(d0), .clk(clk), .rst(rst), .Q(Q[0]));
    flipflopD FF1 (.D(d1), .clk(clk), .rst(rst), .Q(Q[1]));
    flipflopD FF2 (.D(d2), .clk(clk), .rst(rst), .Q(Q[2]));
    flipflopD FF3 (.D(d3), .clk(clk), .rst(rst), .Q(Q[3]));
     
endmodule

// Comparador 4b == 0
module comparadorZero (
    input [3:0] cont,
    output EQ
);
    wire or_out;
    or  (or_out, cont[0], cont[1], cont[2], cont[3]); 
    not  (EQ, or_out);
endmodule

// Comparador < 9
module comparadorMenor9 (
    input cont3, cont0,
    output LT
);
    nand (LT, cont3, cont0);
endmodule

// Comparador = 9
module comparadorE9 (
    input [3:0] cont,
    output EQ
);
    wire n0, n1, n2;
    not (n0, cont[0]);
    not (n1, cont[1]);
    not (n2, cont[2]);
    and (EQ, cont[3], n2, n1, cont[0]);
endmodule


module concat8x16 (
    input [7:0] in_high,
    input [7:0] in_low,
    output [15:0] out
);
    or c15(out[15], in_high[7], 1'b0);
    or c14(out[14], in_high[6], 1'b0);
    or c13(out[13], in_high[5], 1'b0);
    or c12(out[12], in_high[4], 1'b0);
    or c11(out[11], in_high[3], 1'b0);
    or c10(out[10], in_high[2], 1'b0);
    or c9 (out[9],  in_high[1], 1'b0);
    or c8 (out[8],  in_high[0], 1'b0);

    or c7(out[7], in_low[7], 1'b0);
    or c6(out[6], in_low[6], 1'b0);
    or c5(out[5], in_low[5], 1'b0);
    or c4(out[4], in_low[4], 1'b0);
    or c3(out[3], in_low[3], 1'b0);
    or c2(out[2], in_low[2], 1'b0);
    or c1(out[1], in_low[1], 1'b0);
    or c0(out[0], in_low[0], 1'b0);
endmodule

module shifter16b (
    input [15:0] in,
    input cin,
    output [15:0] out
);
    or s15(out[15], cin, 1'b0);
    or s14(out[14], in[15], 1'b0);
    or s13(out[13], in[14], 1'b0);
    or s12(out[12], in[13], 1'b0);
    or s11(out[11], in[12], 1'b0);
    or s10(out[10], in[11], 1'b0);
    or s9 (out[9],  in[10], 1'b0);
    or s8 (out[8],  in[9],  1'b0);
    or s7 (out[7],  in[8],  1'b0);
    or s6 (out[6],  in[7],  1'b0);
    or s5 (out[5],  in[6],  1'b0);
    or s4 (out[4],  in[5],  1'b0);
    or s3 (out[3],  in[4],  1'b0);
    or s2 (out[2],  in[3],  1'b0);
    or s1 (out[1],  in[2],  1'b0);
    or s0 (out[0],  in[1],  1'b0);
endmodule


