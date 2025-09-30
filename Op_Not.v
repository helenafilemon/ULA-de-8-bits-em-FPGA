	module opLogicoNOT(S, A);
	input [7:0] A;
	output [7:0] S;
	
	not Not0(S[0], A[0]);
	not Not1(S[1], A[1]);
	not Not2(S[2], A[2]);
	not Not3(S[3], A[3]);
  not Not4(S[4], A[4]);
	not Not5(S[5], A[5]);
	not Not6(S[6], A[6]);
	not Not7(S[7], A[7]);
	
endmodule   
