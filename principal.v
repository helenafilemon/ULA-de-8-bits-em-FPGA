// --- MODULO PRINCIPAL (ULA SEQUENCIAL) ---
// Proposito: Conecta todos os componentes da ULA RPN.
// Contem a Maquina de Estados Finitos (FSM) que controla o fluxo.
module principal(
      input clock,
      input [9:0] entrada, // Entrada[7:0]=Dados, Entrada[9:8]=Sinal de Display
      input [1:0] botao,   // Botao[0]=Enter, Botao[1]=Reuso
      output [6:0] dis0,   // Display Unidades
      output [6:0] dis1,   // Display Dezenas
      output [6:0] dis2,   // Display Centenas
      output cout,
      output ov,
      output erro,
      output zero,
      output est_final,    // LED do Estado Final (11)
      output resto_led     // LED Resto da Divisao
);
      // --- Fios Internos Principais ---
      wire rst, nBotao0, nBotao1, enterLimpo, reusoLimpo, selMuxA, resetFSM_interno;
      wire [1:0] estado;          // Fio que armazena o estado atual da FSM (00, 01, 10, 11)
      wire [7:0] dadosIn, A_ula, B_ula; // Fluxo de dados: Entrada -> Pilha -> ULA
      wire [2:0] Op_ula;          // Registrador do Opcode
      wire [7:0] resComb;         // Saida da ULA combinacional
      wire [7:0] resReg;          // Registrador do resultado final (para Reuso)
      wire habilitaA, habilitaB, habilitaOp, habilitaExec; // Sinais de controle da FSM
      wire Cout_interno, OV_interno, ERRO_interno, Zero_interno, R_exists_interno; // Flags internas

      // --- Fios da Logica Sequencial (Multiplicacao) ---
      wire op_eh_sequencial;     // Flag que indica se Op_ula e uma op. lenta
      wire pode_avancar;         // Logica de "stall" da FSM (trava em 10)
      wire op_sequencial_done;   // Sinal 'done' vindo do multiplicador
      wire [7:0] resultado_sequencial_data; // Resultado de 8 bits do multiplicador
      wire ov_sequencial_flag;   // Flag 'ov' do multiplicador
      wire [7:0] resMult_data;   // Registrador do resultado da multiplicacao
      wire resMult_ov;           // Registrador da flag 'ov' da multiplicacao

      // --- Instancias de Debouncer ---
      not inv_key0(nBotao0, botao[0]);
      not inv_key1(nBotao1, botao[1]);
      debouncer debouncer_enter(.btn_in(nBotao0),.clk(clock),.rst(1'b0),.btn_out(enterLimpo));
      debouncer debouncer_reuse(.btn_in(nBotao1),.clk(clock),.rst(1'b0),.btn_out(reusoLimpo));
      
      // --- Logica de Controle da FSM (Reset e Avanco) ---
      wire avancar_fsm;
      wire reuse_no_estado0;
      wire estado0, estado10; 
      wire n_estado1, n_estado0, n_estado0_para_rst;
      wire rst_do_reuso;
      
      // Decodifica os bits de estado
      not not_s1(n_estado1, estado[1]);
      not not_s0(n_estado0, estado[0]); 
      and and_s0(estado0, n_estado1, n_estado0); // Sinal 'eh_estado_00'
      
      // Logica de Reset
      not not_para_rst(n_estado0_para_rst, estado0);
      and and_rst_reuso(rst_do_reuso, reusoLimpo, n_estado0_para_rst);
      or or_rst_final(rst, resetFSM_interno, rst_do_reuso); 
      
      // Logica de Avanco (Enable)
      and and_reuso_s0(reuse_no_estado0, reusoLimpo, estado0);
      or or_avancar(avancar_fsm, enterLimpo, reuse_no_estado0);
      
      // Instancia do Contador (FSM)
           contador2b (.clk(clock),.rst(rst),.condicao_avanco(pode_avancar),.enable(avancar_fsm),.Q(estado));
      
      // Instancia do Controle (Logica de Saida da FSM)
      controleCONT (.atual(estado),.enter(enterLimpo),.reuso(reusoLimpo),.habilitaA(habilitaA),.habilitaB(habilitaB),.habilitaOp(habilitaOp),.habilitaExec(habilitaExec),.selMuxA(selMuxA),.resetFSM(resetFSM_interno));
      
      // Sinaliza o Estado Final (11)
      and habex(est_final, estado[0], estado[1]); 
      
      // --- Instancias do Caminho de Dados ---
      
      // MUX de Entrada: Seleciona 'entrada[7:0]' (i0) ou 'resReg' (i1) para a pilha
      mux2para1_8b mux_entrada(.i0(entrada[7:0]),.i1(resReg),.sel(selMuxA),.out(dadosIn));
      
      // Pilha RPN: Armazena Operando A (saidaA) e Operando B (saidaB)
      pilhaRPN pilha(.D(dadosIn),.clk(clock),.rst(resetFSM_interno),.habilitaA(habilitaA),.habilitaB(habilitaB),.saidaA(A_ula),.saidaB(B_ula));
      
      // Registrador de Opcode: Armazena o Op[2:0]
      registrador3b reg_op(.D(entrada[2:0]),.clk(clock),.rst(resetFSM_interno),.habilita(habilitaOp),.Q(Op_ula));
      
      // --- Logica Sequencial (Multiplicador) ---
      wire nOp2, nOp1, nOp0_w; 
      not(nOp2, Op_ula[2]);
      not(nOp1, Op_ula[1]);
      not(nOp0_w, Op_ula[0]);
      wire eh_multi;
      and(eh_multi, nOp2, Op_ula[1], nOp0_w); // 010
      or(op_eh_sequencial, eh_multi, 1'b0);

      // Logica 'start_pulse' para o multiplicador
      and(estado10, estado[1], n_estado0); // Detecta estado 2'b10
      wire pulso_de_transicao;
      and(pulso_de_transicao, estado10, avancar_fsm);
      wire start_pulse;
      and(start_pulse, pulso_de_transicao, op_eh_sequencial); 

      // Instancia do Multiplicador
      multiplicador(.clk(clock), .rst(rst), .A(A_ula), .B(B_ula), .start(start_pulse), .done(op_sequencial_done), 
            .S_result(resultado_sequencial_data), .ov(ov_sequencial_flag));
      
      // Registradores para o resultado da multiplicacao
      registrador8b reg_res_multi_data (.D(resultado_sequencial_data), .clk(clock), .rst(resetFSM_interno), .habilita(op_sequencial_done), .Q(resMult_data));
      registrador1b reg_res_multi_ov   (.D(ov_sequencial_flag),       .clk(clock), .rst(resetFSM_interno), .habilita(op_sequencial_done), .Q(resMult_ov));
      
      // Logica 'pode_avancar' (Sinal de "Stall")
      wire n_op_eh_sequencial;
      not(n_op_eh_sequencial, op_eh_sequencial);
      wire n_estado10;
      not(n_estado10, estado10); 
      wire condicao_stall;
      or(condicao_stall, n_op_eh_sequencial, op_sequencial_done); 
      or(pode_avancar, n_estado10, condicao_stall); 
      // --- Fim Logica Sequencial ---
      
      // Instancia da ULA Combinacional
      ULA_comb ula_combinacional(
            .A(A_ula), .B(B_ula), .Op(Op_ula),
            .s_multi(resMult_data), .ov_mult(resMult_ov), // Conecta resultado do multiplicador
            .S(resComb), .Cout(Cout_interno), .OV(OV_interno),
            .ERRO(ERRO_interno), .Zero(Zero_interno),
            .R_exists_out(R_exists_interno) 
      );
      
      // Registrador de Resultado Final
     
      registrador8b reg_resultado(.D(resComb),.clk(clock),.rst(resetFSM_interno),.habilita(habilitaExec),.Q(resReg));
      
      // --- Logica de Saida (Display) ---
      wire [7:0] valExibir;
      wire [1:0] selDisp; 
      wire mostraResultado;
      wire [7:0] topoPilha8b; 
      
      or sel_d0(selDisp[0], entrada[8], 1'b0);
      or sel_d1(selDisp[1], entrada[9], 1'b0);
      and (mostraResultado, estado[1], estado[0]); // Ativo no Estado 11
      
      // Buffer estrutural para o topo da pilha (B_ula)
      or p0(topoPilha8b[0], B_ula[0], 1'b0); 
      or p1(topoPilha8b[1], B_ula[1], 1'b0);
      or p2(topoPilha8b[2], B_ula[2], 1'b0); 
      or p3(topoPilha8b[3], B_ula[3], 1'b0);
      or p4(topoPilha8b[4], B_ula[4], 1'b0); 
      or p5(topoPilha8b[5], B_ula[5], 1'b0);
      or p6(topoPilha8b[6], B_ula[6], 1'b0); 
      or p7(topoPilha8b[7], B_ula[7], 1'b0);
      
      // MUX Final: Seleciona entre topo da pilha (i0) ou resultado (i1)
      mux2para1_8b mux_final(.i0(topoPilha8b),.i1(resReg),.sel(mostraResultado),.out(valExibir));
      displayDHO display_final(.A(valExibir), .sel(selDisp), .U(dis0), .D(dis1), .C(dis2));
      
      // --- Logica das Flags de Saida ---
      wire nent8, nent9, selErro, erroULA;
      not(nent8, entrada[8]);
      not(nent9, entrada[9]);
      and(selErro, nent8, nent9); 
      and flag_erro(erroULA, ERRO_interno, habilitaExec); 
      or(erro, selErro, erroULA); 
      and flag_cout(cout, Cout_interno, habilitaExec); 
      and flag_ov(ov, OV_interno, habilitaExec);       
      and flag_zero(zero, Zero_interno, habilitaExec); 

      // --- Logica do LED de Resto ---
  
      wire enable_resto_led, verdadeiro;
      and and_enable_resto(enable_resto_led, R_exists_interno, habilitaExec); 
          and ativar_resto (verdadeiro, Op_ula[0], Op_ula[1],nOp2);
      and or_resto_led(resto_led, enable_resto_led, verdadeiro); 

endmodule


