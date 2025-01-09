module seg(d_in,seg);
input[3:0]d_in;
output reg [6:0]seg;//built tuble 1 is on; dp is small point.

always @(d_in)begin
  case(d_in)
    4'b0000:seg=7'b1000000;
    4'b0001:seg=7'b1111001;
    4'b0010:seg=7'b0100100;
    4'b0011:seg=7'b0110000;
    4'b0100:seg=7'b0011001;
    4'b0101:seg=7'b0010010;
    4'b0110:seg=7'b0000010;
    4'b0111:seg=7'b0000000;
    4'b1000:seg=7'b0011000;
    default:seg=7'b1111111;//none lighting
   endcase
  end
endmodule
