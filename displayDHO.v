// --- DRIVER DE DISPLAY (DHO) ---
// Proposito: Controla os 3 displays de 7 segmentos (Unidade, Dezena, Centena).
// Seleciona o modo de exibicao (Decimal, Octal, Hexadecimal).
module displayDHO (
    input [7:0] A, // Valor binario de 8 bits
    input [1:0] sel, // Seletor de modo (01=Dec, 10=Hex, 11=Oc)
    output [6:0] U, // Segmentos da Unidade
    output [6:0] D, // Segmentos da Dezena
    output [6:0] C  // Segmentos da Centena
);
    
    wire [3:0] FU, FD, FC; // Fios para os BCDs (Unidade, Dezena, Centena)
    wire [2:0] sA, sB, sC, sD; // Fios de saida dos MUXes
    
    // Converte o binario 'A' para BCD (FU, FD, FC)
    decodificador (.A(A), .U(FU), .D(FD), .C(FC));
    
    // --- Unidades (Display 0) ---
    // MUXes selecionam os 4 bits corretos para o display
    // Dec(FU[3:0]), Oc(A[2:0]), Hex(A[3:0])
    mux3para1 (.Dec(FU[3]), .Oc(1'b0), .Hex(A[3]), .sel(sel), .S(sA[0]));
    mux3para1 (.Dec(FU[2]), .Oc(A[2]), .Hex(A[2]), .sel(sel), .S(sB[0]));
    mux3para1 (.Dec(FU[1]), .Oc(A[1]), .Hex(A[1]), .sel(sel), .S(sC[0]));
    mux3para1 (.Dec(FU[0]), .Oc(A[0]), .Hex(A[0]), .sel(sel), .S(sD[0]));
    // Instancia o decodificador BCD-para-7-segmentos
    display (.A({sA[0],sB[0],sC[0], sD[0]}), .a(U[0]), .b(U[1]), .c(U[2]), .d(U[3]), .e(U[4]), .f(U[5]), .g(U[6]));
    
    // --- Dezenas (Display 1) ---
    // Dec(FD[3:0]), Oc(A[5:3]), Hex(A[7:4])
    mux3para1 (.Dec(FD[3]), .Oc(1'b0), .Hex(A[7]), .sel(sel), .S(sA[1]));
    mux3para1 (.Dec(FD[2]), .Oc(A[5]), .Hex(A[6]), .sel(sel), .S(sB[1]));
    mux3para1 (.Dec(FD[1]), .Oc(A[4]), .Hex(A[5]), .sel(sel), .S(sC[1]));
    mux3para1 (.Dec(FD[0]), .Oc(A[3]), .Hex(A[4]), .sel(sel), .S(sD[1]));
    display (.A({sA[1],sB[1],sC[1], sD[1]}), .a(D[0]), .b(D[1]), .c(D[2]), .d(D[3]), .e(D[4]), .f(D[5]), .g(D[6]));
    
    // --- Centenas (Display 2) ---
    // Dec(FC[3:0]), Oc(A[7:6]), Hex(0)
    // (Nota: A logica Octal aqui esta incorreta, 'Oc' deveria usar {0,0,A[7],A[6]})
    mux3para1 (.Dec(FC[3]), .Oc(1'b0), .Hex(1'b0), .sel(sel), .S(sA[2]));
    mux3para1 (.Dec(FC[2]), .Oc(A[7]), .Hex(1'b0), .sel(sel), .S(sB[2]));
    mux3para1 (.Dec(FC[1]), .Oc(A[6]), .Hex(1'b0), .sel(sel), .S(sC[2]));
    mux3para1 (.Dec(FC[0]), .Oc(1'b0), .Hex(1'b0), .sel(sel), .S(sD[2]));
    display (.A({sA[2],sB[2],sC[2], sD[2]}), .a(C[0]), .b(C[1]), .c(C[2]), .d(C[3]), .e(C[4]), .f(C[5]), .g(C[6]));
    
endmodule


// --- DECODIFICADOR 7-SEGMENTOS ---
// Proposito: Converte um BCD de 4 bits (A) nos 7 sinais (a-g) para acender um display.
module display (
    input [3:0] A,
    output a, b, c, d, e, f, g
);
    
    wire [3:0] Fa, Fb, Fd, Ff;
    wire [2:0] Fc, Fe, Fg;
    wire notA3, notA2, notA1, notA0;
    
    not (notA3, A[3]);
    not (notA2, A[2]);
    not (notA1, A[1]);
    not (notA0, A[0]);
    
    // Logica Minimizada (Soma de Produtos) para cada segmento
    
    // Logica do segmento 'a'
    and (Fa[0], notA3, notA2, notA1, A[0]);
    and (Fa[1], notA3, A[2], notA1, notA0);
    and (Fa[2], A[3], notA2, A[1], A[0]);
    and (Fa[3], A[3], A[2], notA1, A[0]);
    or (a, Fa[0], Fa[1], Fa[2], Fa[3]);
    
    // Logica do segmento 'b'
    and (Fb[0], notA3, A[2], notA1, A[0]);
    and (Fb[1], A[2], A[1], notA0);
    and (Fb[2], A[3], A[1], A[0]);
    and (Fb[3], A[3], A[2], notA0);
    or (b, Fb[0], Fb[1], Fb[2], Fb[3]);
    
    // Logica do segmento 'c'
    and (Fc[0], notA3, notA2, A[1], notA0);
    and (Fc[1], A[3], A[2], notA0);
    and (Fc[2], A[3], A[2], A[1]);
    or (c, Fc[0], Fc[1], Fc[2]);
    
    // Logica do segmento 'd'
    and (Fd[0], notA3, notA2, notA1, A[0]);
    and (Fd[1], notA3, A[2], notA1, notA0);
    and (Fd[2], A[3], notA2, A[1], notA0);
    and (Fd[3], A[2], A[1], A[0]);
    or (d, Fd[0], Fd[1], Fd[2], Fd[3]);
    
    // Logica do segmento 'e'
    and (Fe[0], notA3, A[0]);
    and (Fe[1], notA2, notA1, A[0]);
    and (Fe[2], notA3, A[2], notA1);
    or (e, Fe[0], Fe[1], Fe[2]);
    
    // Logica do segmento 'f'
    and (Ff[0], notA3, notA2, A[0]);
    and (Ff[1], notA3, notA2, A[1]);
    and (Ff[2], notA3, A[1], A[0]);
    and (Ff[3], A[3], A[2], notA1, A[0]);
    or (f, Ff[0], Ff[1], Ff[2], Ff[3]);
    
    // Logica do segmento 'g'
    and (Fg[0], A[3], A[2], notA1, notA0);
    and (Fg[1], notA3, A[2], A[1], A[0]);
    and (Fg[2], notA3, notA2, notA1);
    or (g, Fg[0], Fg[1], Fg[2]);

endmodule


module mux3para1 (
    input Dec, Oc, Hex, 
    input [1:0]sel,
    output S);
    
    wire notS1, notS0, F1, F2, F3;
    
    not (notS1, sel[1]);
    not (notS0, sel[0]);
    
    and (F1, notS1, sel[0], Dec);
    and (F2, sel[1], notS0, Hex);
    and (F3, sel[1], sel[0], Oc);
    
    or (S, F1, F2, F3);
    
endmodule 

module decodificador (
    input [7:0] A,
    output [3:0] U,
    output [3:0] D,
    output [3:0] C
);
    
    wire [3:0] F1, F2, F3, F4, F5, F6;
    wire descarte;
    
    // Algoritmo Double Dabble para conversão binário para BCD (8 bits)
    // Cada somsel adiciona 3 se o valor >= 5, depois faz shift left
    
    // Shift 1: Processa bits mais significativos (7,6,5)
    somsel (.A({1'b0, A[7], A[6], A[5]}), .S(F1));
    
    // Shift 2: F1 shifted + A[4]
    somsel (.A({F1[2], F1[1], F1[0], A[4]}), .S(F2));
    
    // Shift 3: F2 shifted + A[3]
    somsel (.A({F2[2], F2[1], F2[0], A[3]}), .S(F3));
    
    // Shift 4: F3 shifted + A[2]
    somsel (.A({F3[2], F3[1], F3[0], A[2]}), .S(F4));
    
    // Shift 5: F4 shifted + A[1] -> Produz D[0] e U[3:1]
    somsel (.A({F4[2], F4[1], F4[0], A[1]}), .S({D[0], U[3], U[2], U[1]}));
    
    // Unidades bit 0 vem diretamente de A[0] (último shift é apenas concatenação)
    or (U[0], A[0], 1'b0);
    
    // Processa centenas: coleta os bits que "transbordaram" das dezenas
    // F1[3], F2[3], F3[3] são os carries das operações anteriores
    somsel (.A({1'b0, F1[3], F2[3], F3[3]}), .S(F5));
    
    // Shift final para completar D[3:1] e começar C[0]
    somsel (.A({F5[2], F5[1], F5[0], F4[3]}), .S({C[0], D[3], D[2], D[1]}));
    
    // Centenas bits superiores (C[3:1])
    // Para 8 bits (0-255), centenas vai de 0 a 2, então precisamos apenas de F5[3]
    somsel (.A({1'b0, 1'b0, F5[3], 1'b0}), .S({C[3], C[2], C[1], descarte}));

endmodule

// --- CELULA "ADD-3" (do Double Dabble) ---
// Proposito: Bloco de construcao do 'decodificador'.
// Logica: Se A >= 5, entao S = A + 3. Senao, S = A.
module somsel(
    input [3:0] A, // Digito BCD (ou binario) de 4 bits
    output [3:0] S // Saida corrigida
);
    
    wire f1, f2, f3, s_mux, descarte;
    wire [3:0] c;
    
    // Logica para detectar se A >= 5
    and(f1, A[2], A[1]);
    and(f2, A[2], A[0]);
    or(f3, f1, f2, A[3]);
    
    // MUX para selecionar o '0011' (valor 3)
    mux2para1_1b(.i0(1'b0), .i1(1'b1), .sel(f3), .out(s_mux));
    
    // Somador de 4 bits para calcular S = A + 3 (ou A + 0)
    meiosomador (.A(A[0]), .B(s_mux),  .S(S[0]), .Cout(c[0]));
    SomadorPBL2 (.A(A[1]), .B(s_mux), .Cin(c[0]),  .S(S[1]), .Cout(c[1]));
    meiosomador (.A(A[2]), .B(c[1]),  .S(S[2]), .Cout(c[2]));
    meiosomador (.A(A[3]), .B(c[2]),  .S(S[3]), .Cout(descarte));

endmodule

