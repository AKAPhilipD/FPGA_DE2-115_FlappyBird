module extract(data_in,cq_h,cq_t,cq_num);
input [6:0]data_in;
output reg[3:0]cq_h;
output reg[3:0]cq_t;
output reg[3:0]cq_num;

always@(data_in)begin
   cq_h<=data_in/100%10;
	cq_t<=data_in/10%10;
	cq_num<=data_in%10;
end

endmodule
