// --- MODULO PRINCIPAL (ULA SEQUENCIAL) ---
// Proposito: Conecta todos os componentes da ULA RPN.
// Contem a Maquina de Estados Finitos (FSM) que controla o fluxo.
module principal(
    input clock,
    input [9:0] entrada, // Chaves de dados e selecao
    input [1:0] botao,   // Botoes Enter e Reuso
    output [6:0] dis0,   // Displays de 7 segmentos
    output [6:0] dis1, 
    output [6:0] dis2,
    output cout,         // Flags de status
    output ov,
    output erro,
    output zero,
    output est_final,    // LED de estado 'Pronto'
    output resto_led     // LED de resto da divisao
);
    // Fios internos para conexao entre os modulos
    wire rst, nBotao0, nBotao1, enterLimpo, reusoLimpo, selMuxA, resetFSM_interno;
    wire [1:0] estado;
    wire [7:0] dadosIn, A_ula, B_ula;
    wire [2:0] Op_ula; 
    wire [7:0] resComb; 
    wire [7:0] resReg;  
    wire habilitaA, habilitaB, habilitaOp, habilitaExec;
    wire Cout_interno, OV_interno, ERRO_interno, Zero_interno;
    wire R_exists_interno; 
    wire op_eh_sequencial;
    wire pode_avancar; 
    
    // Fios especificos para a comunicacao com o multiplicador
    wire op_sequencial_done;
    wire [7:0] resultado_sequencial_data;
    wire ov_sequencial_flag;       
    wire [7:0] resMult_data;
    wire resMult_ov;

    // Inversores para os botoes (ativos em nivel baixo)
    not inv_key0(nBotao0, botao[0]);
    not inv_key1(nBotao1, botao[1]);
    
    // Filtros (debouncers) para limpar o ruido dos botoes
    debouncer debouncer_enter(.btn_in(nBotao0),.clk(clock),.rst(1'b0),.btn_out(enterLimpo));
    debouncer debouncer_reuse(.btn_in(nBotao1),.clk(clock),.rst(1'b0),.btn_out(reusoLimpo));
    
    // Logica combinacional para controle de reset e avanco de estado
    wire avancar_fsm;
    wire reuse_no_estado0;
    wire estado0, estado10; 
    wire n_estado1, n_estado0, n_estado0_para_rst;
    wire rst_do_reuso;
    
    not not_s1(n_estado1, estado[1]);
    not not_s0(n_estado0, estado[0]); 
    and and_s0(estado0, n_estado1, n_estado0);
    not not_para_rst(n_estado0_para_rst, estado0);
    and and_rst_reuso(rst_do_reuso, reusoLimpo, n_estado0_para_rst);
    or or_rst_final(rst, resetFSM_interno, rst_do_reuso);
    and and_reuso_s0(reuse_no_estado0, reusoLimpo, estado0);
    or or_avancar(avancar_fsm, enterLimpo, reuse_no_estado0);
    
    // Maquina de Estados (Contador) que controla o fluxo de operacao
    contador2b (.clk(clock),.rst(rst),.condicao_avanco(pode_avancar),.enable(avancar_fsm),.Q(estado));
    
    // Modulo de Controle que gera os sinais de habilitacao baseados no estado
    controleCONT (.atual(estado),.enter(enterLimpo),.reuso(reusoLimpo),.habilitaA(habilitaA),.habilitaB(habilitaB),.habilitaOp(habilitaOp),.habilitaExec(habilitaExec),.selMuxA(selMuxA),.resetFSM(resetFSM_interno));
    
    // Sinaliza quando a maquina atinge o estado final (11)
    and habex(est_final, estado[0], estado[1]); 
    
    // Multiplexador para selecionar entre entrada das chaves ou reuso do resultado anterior
    mux2para1_8b mux_entrada(.i0(entrada[7:0]),.i1(resReg),.sel(selMuxA),.out(dadosIn));
    
    // Pilha RPN para armazenar os dois operandos
    pilhaRPN pilha(.D(dadosIn),.clk(clock),.rst(resetFSM_interno),.habilitaA(habilitaA),.habilitaB(habilitaB),.saidaA(A_ula),.saidaB(B_ula));
    
    // Registrador para armazenar o codigo da operacao
    registrador3b reg_op(.D(entrada[2:0]),.clk(clock),.rst(resetFSM_interno),.habilita(habilitaOp),.Q(Op_ula));
    
    // Logica para detectar e controlar a operacao de multiplicacao (sequencial)
    wire nOp2, nOp1, nOp0_w; 
    not(nOp2, Op_ula[2]);
    not(nOp1, Op_ula[1]);
    not(nOp0_w, Op_ula[0]);
    wire eh_multi;
    and(eh_multi, nOp2, Op_ula[1], nOp0_w);
    or(op_eh_sequencial, eh_multi, 1'b0);

    and(estado10, estado[1], n_estado0);
    wire pulso_de_transicao;
    and(pulso_de_transicao, estado10, avancar_fsm);
    wire start_pulse;
    and(start_pulse, pulso_de_transicao, op_eh_sequencial); 
    
    // Unidade multiplicadora independente
    multiplicador(.clk(clock), .rst(rst), .A(A_ula), .B(B_ula), .start(start_pulse), .done(op_sequencial_done), 
        .S_result(resultado_sequencial_data), .ov(ov_sequencial_flag));
    
    // Registradores para guardar o resultado da multiplicacao
    registrador8b reg_res_multi_data (.D(resultado_sequencial_data), .clk(clock), .rst(resetFSM_interno), .habilita(op_sequencial_done), .Q(resMult_data));
    registrador1b reg_res_multi_ov   (.D(ov_sequencial_flag),       .clk(clock), .rst(resetFSM_interno), .habilita(op_sequencial_done), .Q(resMult_ov));
    
    // Logica de "stall" para travar a FSM durante a multiplicacao
    wire n_op_eh_sequencial;
    not(n_op_eh_sequencial, op_eh_sequencial);
    wire n_estado10;
    not(n_estado10, estado10); 
    wire condicao_stall;
    or(condicao_stall, n_op_eh_sequencial, op_sequencial_done); 
    or(pode_avancar, n_estado10, condicao_stall); 
    
    // ULA combinacional que executa as outras operacoes
    ULA_comb ula_combinacional(
        .A(A_ula), .B(B_ula), .Op(Op_ula),
        .s_multi(resMult_data), .ov_mult(resMult_ov),
        .S(resComb), .Cout(Cout_interno), .OV(OV_interno),
        .ERRO(ERRO_interno), .Zero(Zero_interno),
        .R_exists_out(R_exists_interno) 
    );
    
    // Registrador que armazena o resultado final
    registrador8b reg_resultado(.D(resComb),.clk(clock),.rst(resetFSM_interno),.habilita(habilitaExec),.Q(resReg));
    
    // Logica de selecao do que sera exibido no display
    wire [7:0] valExibir;
    wire [1:0] selDisp; 
    wire mostraResultado;
    wire [7:0] topoPilha8b; 
    
    or sel_d0(selDisp[0], entrada[8], 1'b0);
    or sel_d1(selDisp[1], entrada[9], 1'b0);
    and (mostraResultado, estado[1], estado[0]); 
    
    or p0(topoPilha8b[0], B_ula[0], 1'b0); 
    or p1(topoPilha8b[1], B_ula[1], 1'b0);
    or p2(topoPilha8b[2], B_ula[2], 1'b0); 
    or p3(topoPilha8b[3], B_ula[3], 1'b0);
    or p4(topoPilha8b[4], B_ula[4], 1'b0); 
    or p5(topoPilha8b[5], B_ula[5], 1'b0);
    or p6(topoPilha8b[6], B_ula[6], 1'b0); 
    or p7(topoPilha8b[7], B_ula[7], 1'b0);
    
    mux2para1_8b mux_final(.i0(topoPilha8b),.i1(resReg),.sel(mostraResultado),.out(valExibir));
    
    // Driver para os displays de 7 segmentos
    displayDHO display_final(.A(valExibir), .sel(selDisp), .U(dis0), .D(dis1), .C(dis2));
    
    // Logica das flags de saida (LEDs)
    wire nent8, nent9, selErro, erroULA;
    not(nent8, entrada[8]);
    not(nent9, entrada[9]);
    and(selErro, nent8, nent9); 
    and flag_erro(erroULA, ERRO_interno, habilitaExec); 
    or(erro, selErro, erroULA);
    and flag_cout(cout, Cout_interno, habilitaExec); 
    and flag_ov(ov, OV_interno, habilitaExec);       
    and flag_zero(zero, Zero_interno, habilitaExec); 

    // Logica para o LED de resto da divisao
    wire enable_resto_led, verdadeiro;
    and and_enable_resto(enable_resto_led, R_exists_interno, habilitaExec); 
    and ativar_resto (verdadeiro, Op_ula[0], Op_ula[1],nOp2);
    and or_resto_led(resto_led, enable_resto_led, verdadeiro); 

endmodule
