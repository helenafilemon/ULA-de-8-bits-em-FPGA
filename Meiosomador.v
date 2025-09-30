module Meiosomador( S, Cout, A, B);
   input A, B;
   output S, Cout;

   xor Xor(S, A, B);
   and And(Cout, A, B);
   
endmodule
