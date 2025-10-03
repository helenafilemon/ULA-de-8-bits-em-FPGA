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
