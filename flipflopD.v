module flipflopD (
    input D,
    input clk,
    input rst,
    output reg Q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            Q <= 1'b0;
        else
            Q <= D;
    end
endmodule

module debouncer (
    input btn_in,
    input clk,
    input rst,
    output btn_out
);
    wire sincro1, sincro2;
     
    // Etapa 1: Sincronizador (Inalterado)
    flipflopD ff_sincro1 (.D(btn_in), .clk(clk), .rst(rst), .Q(sincro1));
    flipflopD ff_sincro2 (.D(sincro1),  .clk(clk), .rst(rst), .Q(sincro2));

    // Etapa 2: Registrador de Deslocamento (Reduzido para 10 bits)
    wire [9:0] reg_desloc; 
    flipflopD ff_shift0 (.D(sincro2), .clk(clk), .rst(rst), .Q(reg_desloc[0]));
    flipflopD ff_shift1 (.D(reg_desloc[0]), .clk(clk), .rst(rst), .Q(reg_desloc[1]));
    flipflopD ff_shift2 (.D(reg_desloc[1]), .clk(clk), .rst(rst), .Q(reg_desloc[2]));
    flipflopD ff_shift3 (.D(reg_desloc[2]), .clk(clk), .rst(rst), .Q(reg_desloc[3]));
    flipflopD ff_shift4 (.D(reg_desloc[3]), .clk(clk), .rst(rst), .Q(reg_desloc[4]));
    flipflopD ff_shift5 (.D(reg_desloc[4]), .clk(clk), .rst(rst), .Q(reg_desloc[5]));
    flipflopD ff_shift6 (.D(reg_desloc[5]), .clk(clk), .rst(rst), .Q(reg_desloc[6]));
    flipflopD ff_shift7 (.D(reg_desloc[6]), .clk(clk), .rst(rst), .Q(reg_desloc[7]));
    flipflopD ff_shift8 (.D(reg_desloc[7]), .clk(clk), .rst(rst), .Q(reg_desloc[8]));
    flipflopD ff_shift9 (.D(reg_desloc[8]), .clk(clk), .rst(rst), .Q(reg_desloc[9]));
 
   
    // Etapa 3: Árvore 'AND' (Reduzida para 10 bits)
    wire w0, w1, w2, w3, w4; // Nível 1
    wire w5, w6;             // Nível 2
    wire w7;                 // Nível 3
    wire w8;                 // Nível 4 (Final)

    and a0(w0, reg_desloc[0], reg_desloc[1]); 
     and a1(w1, reg_desloc[2], reg_desloc[3]);
    and a2(w2, reg_desloc[4], reg_desloc[5]); 
     and a3(w3, reg_desloc[6], reg_desloc[7]);
    and a4(w4, reg_desloc[8], reg_desloc[9]); 
    
    and b0(w5, w0, w1); 
     and b1(w6, w2, w3); 
    
    and c0(w7, w5, w6);
    
    and d0(w8, w7, w4); // Combina os resultados
   
    wire sinal_estavel;
    or final_buffer(sinal_estavel, w8, 1'b0); // w8 é a nova saída da árvore

    // Etapa 4: Detector de Borda (Inalterado)
    wire estavel_ant, n_estavel_ant;
    flipflopD ff_prev (.D(sinal_estavel), .clk(clk), .rst(rst), .Q(estavel_ant));
    not not_prev (n_estavel_ant, estavel_ant);
    and pulso (btn_out, sinal_estavel, n_estavel_ant);
     
endmodule

module registrador3b (
     input [2:0] D, 
     input clk, 
     input rst, 
     input habilita, 
     output [2:0] Q);
     
    wire n_habilita; 
     wire [2:0] d_g, q_g, d_final; 
     not n1(n_habilita, habilita);
     
    and a0(d_g[0],D[0],habilita); 
     and a1(q_g[0],Q[0],n_habilita); 
     or o0(d_final[0],d_g[0],q_g[0]); 
     flipflopD ff0(.D(d_final[0]),.clk(clk),.rst(rst),.Q(Q[0]));
     
    and a2(d_g[1],D[1],habilita); 
     and a3(q_g[1],Q[1],n_habilita); 
     or o1(d_final[1],d_g[1],q_g[1]); 
     flipflopD ff1(.D(d_final[1]),.clk(clk),.rst(rst),.Q(Q[1]));
     
    and a4(d_g[2],D[2],habilita); 
     and a5(q_g[2],Q[2],n_habilita); 
     or o2(d_final[2],d_g[2],q_g[2]); 
     flipflopD ff2(.D(d_final[2]),.clk(clk),.rst(rst),.Q(Q[2]));
     
endmodule


module registrador8b (
     input [7:0] D, 
     input clk, 
     input rst, 
     input habilita, 
     output [7:0] Q);
     
    wire n_habilita; 
     wire [7:0] d_g, q_g, d_final; 
     
     not n1(n_habilita, habilita);
     
    and a0(d_g[0],D[0],habilita); 
     and a1(q_g[0],Q[0],n_habilita); 
     or o0(d_final[0],d_g[0],q_g[0]); 
     flipflopD ff0(.D(d_final[0]),.clk(clk),.rst(rst),.Q(Q[0]));
     
    and a2(d_g[1],D[1],habilita); 
     and a3(q_g[1],Q[1],n_habilita); 
     or o1(d_final[1],d_g[1],q_g[1]); 
     flipflopD ff1(.D(d_final[1]),.clk(clk),.rst(rst),.Q(Q[1]));
     
    and a4(d_g[2],D[2],habilita); 
     and a5(q_g[2],Q[2],n_habilita); 
     or o2(d_final[2],d_g[2],q_g[2]); 
     flipflopD ff2(.D(d_final[2]),.clk(clk),.rst(rst),.Q(Q[2]));
     
    and a6(d_g[3],D[3],habilita); 
     and a7(q_g[3],Q[3],n_habilita); 
     or o3(d_final[3],d_g[3],q_g[3]); 
     flipflopD ff3(.D(d_final[3]),.clk(clk),.rst(rst),.Q(Q[3]));
     
    and a8(d_g[4],D[4],habilita); 
     and a9(q_g[4],Q[4],n_habilita); 
     or o4(d_final[4],d_g[4],q_g[4]); 
     flipflopD ff4(.D(d_final[4]),.clk(clk),.rst(rst),.Q(Q[4]));
     
    and a10(d_g[5],D[5],habilita); 
     and a11(q_g[5],Q[5],n_habilita); 
     or o5(d_final[5],d_g[5],q_g[5]); 
     flipflopD ff5(.D(d_final[5]),.clk(clk),.rst(rst),.Q(Q[5]));
     
    and a12(d_g[6],D[6],habilita); 
     and a13(q_g[6],Q[6],n_habilita); 
     or o6(d_final[6],d_g[6],q_g[6]); 
     flipflopD ff6(.D(d_final[6]),.clk(clk),.rst(rst),.Q(Q[6]));
     
    and a14(d_g[7],D[7],habilita); 
     and a15(q_g[7],Q[7],n_habilita); 
     or o7(d_final[7],d_g[7],q_g[7]); 
     flipflopD ff7(.D(d_final[7]),.clk(clk),.rst(rst),.Q(Q[7]));
     
endmodule


module registrador16b (
       input [15:0] D, 
     input clk, 
      input rst, 
     input habilita, 
     output [15:0] Q);

    wire n_habilita; 
     wire [15:0] d_g, q_g, d_final; 
     not n1(n_habilita, habilita);
     
    and a0(d_g[0],D[0],habilita); 
     and a1(q_g[0],Q[0],n_habilita); 
     or o0(d_final[0],d_g[0],q_g[0]); 
     flipflopD ff0(.D(d_final[0]),.clk(clk),.rst(rst),.Q(Q[0]));
     
    and a2(d_g[1],D[1],habilita); 
     and a3(q_g[1],Q[1],n_habilita); 
     or o1(d_final[1],d_g[1],q_g[1]); 
     flipflopD ff1(.D(d_final[1]),.clk(clk),.rst(rst),.Q(Q[1]));
     
    and a4(d_g[2],D[2],habilita); 
     and a5(q_g[2],Q[2],n_habilita); 
     or o2(d_final[2],d_g[2],q_g[2]); 
     flipflopD ff2(.D(d_final[2]),.clk(clk),.rst(rst),.Q(Q[2]));
     
    and a6(d_g[3],D[3],habilita); 
     and a7(q_g[3],Q[3],n_habilita); 
     or o3(d_final[3],d_g[3],q_g[3]); 
     flipflopD ff3(.D(d_final[3]),.clk(clk),.rst(rst),.Q(Q[3]));
     
    and a8(d_g[4],D[4],habilita); 
     and a9(q_g[4],Q[4],n_habilita); 
     or o4(d_final[4],d_g[4],q_g[4]); 
     flipflopD ff4(.D(d_final[4]),.clk(clk),.rst(rst),.Q(Q[4]));
     
    and a10(d_g[5],D[5],habilita); 
     and a11(q_g[5],Q[5],n_habilita); 
     or o5(d_final[5],d_g[5],q_g[5]); 
     flipflopD ff5(.D(d_final[5]),.clk(clk),.rst(rst),.Q(Q[5]));
     
    and a12(d_g[6],D[6],habilita); 
     and a13(q_g[6],Q[6],n_habilita); 
     or o6(d_final[6],d_g[6],q_g[6]); 
     flipflopD ff6(.D(d_final[6]),.clk(clk),.rst(rst),.Q(Q[6]));
     
    and a14(d_g[7],D[7],habilita); 
     and a15(q_g[7],Q[7],n_habilita); 
     or o7(d_final[7],d_g[7],q_g[7]); 
     flipflopD ff7(.D(d_final[7]),.clk(clk),.rst(rst),.Q(Q[7]));
     
    and a16(d_g[8],D[8],habilita); 
     and a17(q_g[8],Q[8],n_habilita); 
     or o8(d_final[8],d_g[8],q_g[8]); 
     flipflopD ff8(.D(d_final[8]),.clk(clk),.rst(rst),.Q(Q[8]));
     
    and a18(d_g[9],D[9],habilita); 
     and a19(q_g[9],Q[9],n_habilita); 
     or o9(d_final[9],d_g[9],q_g[9]); 
     flipflopD ff9(.D(d_final[9]),.clk(clk),.rst(rst),.Q(Q[9]));
     
    and a20(d_g[10],D[10],habilita); 
     and a21(q_g[10],Q[10],n_habilita); 
     or o10(d_final[10],d_g[10],q_g[10]); 
     flipflopD ff10(.D(d_final[10]),.clk(clk),.rst(rst),.Q(Q[10]));
     
    and a22(d_g[11],D[11],habilita); 
     and a23(q_g[11],Q[11],n_habilita); 
     or o11(d_final[11],d_g[11],q_g[11]); 
     flipflopD ff11(.D(d_final[11]),.clk(clk),.rst(rst),.Q(Q[11]));
     
    and a24(d_g[12],D[12],habilita); 
     and a25(q_g[12],Q[12],n_habilita); 
     or o12(d_final[12],d_g[12],q_g[12]); 
     flipflopD ff12(.D(d_final[12]),.clk(clk),.rst(rst),.Q(Q[12]));
     
    and a26(d_g[13],D[13],habilita); 
     and a27(q_g[13],Q[13],n_habilita); 
     or o13(d_final[13],d_g[13],q_g[13]); 
     flipflopD ff13(.D(d_final[13]),.clk(clk),.rst(rst),.Q(Q[13]));
     
    and a28(d_g[14],D[14],habilita); 
     and a29(q_g[14],Q[14],n_habilita); 
     or o14(d_final[14],d_g[14],q_g[14]); 
     flipflopD ff14(.D(d_final[14]),.clk(clk),.rst(rst),.Q(Q[14]));
     
    and a30(d_g[15],D[15],habilita); 
     and a31(q_g[15],Q[15],n_habilita); 
     or o15(d_final[15],d_g[15],q_g[15]); 
     flipflopD ff15(.D(d_final[15]),.clk(clk),.rst(rst),.Q(Q[15]));
     
endmodule


module registrador1b (
     input D,         // Entrada de dados (1 bit)
     input clk,       // Clock
     input rst,       // Reset assíncrono
     input habilita,  // Sinal de habilitação
     output Q        // Saída de dados (1 bit)
);
    wire n_habilita; // Inverso do sinal de habilitação
    wire d_g;        // Entrada D "passando" pela habilitação
    wire q_g;        // Saída Q mantendo o valor anterior
    wire d_final;    // Valor final a ser carregado no flip-flop

    // Inverte o sinal de habilitação
    not n1(n_habilita, habilita);
     
    // Se habilita=1, d_g = D; senão d_g = 0
    and a0(d_g, D, habilita); 
    // Se habilita=0, q_g = Q; senão q_g = 0
    and a1(q_g, Q, n_habilita); 
    // d_final é D se habilita=1, ou Q se habilita=0
    or  o0(d_final, d_g, q_g); 
    
    // Flip-flop tipo D que armazena o valor d_final
    flipflopD ff0(.D(d_final), .clk(clk), .rst(rst), .Q(Q));
     
endmodule
