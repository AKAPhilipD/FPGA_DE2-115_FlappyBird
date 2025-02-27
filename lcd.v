module lcd(clk,rst,oe,rs,rw,data,on);
input clk;
input rst;
output oe;
output on;
output reg rs;
output reg rw;
output reg[7:0]data;

reg[7:0]counter; //define 60 count
assign on=1'b1;

//part I:initial the lcd
parameter TIME_20MS=90_000;//20ms to be stable
reg[19:0]cnt_20ms;
always@(posedge clk or negedge rst)begin
   if(!rst)begin
      cnt_20ms<=1'b0;
   end
   else if(cnt_20ms<TIME_20MS)begin
       cnt_20ms<=cnt_20ms+1'b1;
   end
end
wire delay_done=(cnt_20ms==TIME_20MS)?1'b1:1'b0;//the delay of lcd;

//part II:div 50MS to 500HZ
parameter TIME_500HZ=100_000;
reg[19:0]cnt_500hz;
always@(posedge clk or negedge rst)begin
  if(!rst)begin
     cnt_500hz<=1'b0;
  end
  //if the delay is done,to stop.
  else if(delay_done)begin
     if(cnt_500hz==TIME_500HZ-1'b1)begin
        cnt_500hz<=1'b0;
     end
     else begin
        cnt_500hz<=cnt_500hz+1'b1;
     end
  end
  else begin
    cnt_500hz<=1'b0;
  end
end
assign oe=(cnt_500hz>(TIME_500HZ-1'b1)/2)?1'b0:1'b1; //to define the enable
wire write_flag=(cnt_500hz==TIME_500HZ-1'b1)?1'b1:1'b0;//to define the write flag. to tell the LCD to write.


//part III:FSM
//define the state of FSM.
parameter IDLE=8'h00;
parameter SET_FUNCTION=8'h01;
parameter DISP_OFF=8'h03;
parameter DISP_CLEAR=8'h02;
parameter ENTRY_MODE=8'h06;
parameter DISP_ON=8'h07;
parameter ROW1_ADDR=8'h05;
parameter ROW1_0=8'h04;
parameter ROW1_1=8'h0C;
parameter ROW1_2=8'h0D;
parameter ROW1_3=8'h0F;
parameter ROW1_4=8'h0E;
parameter ROW1_5=8'h0A;
parameter ROW1_6=8'h0B;
parameter ROW1_7=8'h09;
parameter ROW1_8=8'h08;
parameter ROW1_9=8'h18;
parameter ROW1_A=8'h19;
parameter ROW1_B=8'h1B;
parameter ROW1_C=8'h1A;
parameter ROW1_D=8'h1E;
parameter ROW1_E=8'h1F;
parameter ROW1_F=8'h1D;
parameter ROW2_ADDR=8'h1C;
parameter ROW2_0=8'h14;
parameter ROW2_1=8'h15;
parameter ROW2_2=8'h17;
parameter ROW2_3=8'h16;
parameter ROW2_4=8'h12;
parameter ROW2_5=8'h13;
parameter ROW2_6=8'h11;
parameter ROW2_7=8'h10;
parameter ROW2_8=8'h30;
parameter ROW2_9=8'h31;
parameter ROW2_A=8'h33;
parameter ROW2_B=8'h32;
parameter ROW2_C=8'h36;
parameter ROW2_D=8'h37;
parameter ROW2_E=8'h35;
parameter ROW2_F=8'h34;

reg [5:0]current_state;
reg [5:0]next_state;

//transition
always@(posedge clk or negedge rst)begin
  if(!rst)begin
     current_state<=IDLE;
  end
  else if(write_flag)begin
       current_state<=next_state;
  end
end

//the transition
always @(*)begin
  case(current_state)
  IDLE:next_state<=SET_FUNCTION;
  SET_FUNCTION:next_state<=DISP_OFF;
  DISP_OFF:next_state<=DISP_CLEAR;
  DISP_CLEAR:next_state<=ENTRY_MODE;
  ENTRY_MODE:next_state<=DISP_ON;
  DISP_ON:next_state<=ROW1_ADDR;
  
  //now the row.
  		ROW1_ADDR:next_state=ROW1_0;
		ROW1_0:next_state=ROW1_1;
		ROW1_1:next_state=ROW1_2;
		ROW1_2:next_state=ROW1_3;
		ROW1_3:next_state=ROW1_4;
		ROW1_4:next_state=ROW1_5;
		ROW1_5:next_state=ROW1_6;
		ROW1_6:next_state=ROW1_7;
		ROW1_7:next_state=ROW1_8;
		ROW1_8:next_state=ROW1_9;
		ROW1_9:next_state=ROW1_A;
		ROW1_A:next_state=ROW1_B;
		ROW1_B:next_state=ROW1_C;
		ROW1_C:next_state=ROW1_D;
		ROW1_D:next_state=ROW1_E;
		ROW1_E:next_state=ROW1_F;
		ROW1_F:next_state=ROW2_ADDR;
		ROW2_ADDR:next_state=ROW2_0;
		ROW2_0:next_state=ROW2_1;
		ROW2_1:next_state=ROW2_2;
		ROW2_2:next_state=ROW2_3;
		ROW2_3:next_state=ROW2_4;
		ROW2_4:next_state=ROW2_5;
		ROW2_5:next_state=ROW2_6;
		ROW2_6:next_state=ROW2_7;
		ROW2_7:next_state=ROW2_8;
		ROW2_8:next_state=ROW2_9;
		ROW2_9:next_state=ROW2_A;
		ROW2_A:next_state=ROW2_B;
		ROW2_B:next_state=ROW2_C;
		ROW2_C:next_state=ROW2_D;
		ROW2_D:next_state=ROW2_E;
		ROW2_E:next_state=ROW2_F;
		ROW2_F:next_state=ROW1_ADDR;
	endcase
end


//part IV:now define the rs;when 0 is code when 1 is data.
always@(posedge clk or negedge rst)begin
   if(!rst)begin
      rs<=0;//input code.
   end
   else if(write_flag)begin
   //if next_state is mode like this,rs=0,else rs=1;
     if((next_state==SET_FUNCTION)||(next_state==DISP_OFF)||(next_state==DISP_CLEAR)
     ||(next_state==ENTRY_MODE)||(next_state==DISP_ON)||(next_state==ROW1_ADDR)||(next_state==ROW2_ADDR))begin
        rs<=0;
     end
     else begin
        rs<=1;
     end
   end
end

//Part V:now define the output
always@(posedge clk or negedge rst)begin
   if(!rst)begin
     data<=0;
   end
   else if(write_flag)begin
		case(next_state)
		    //define the code.
			IDLE:data<=8'hxx;
			SET_FUNCTION:data<=8'h38;//8'b0011_1000,������ʽ����:DL=1(DB4,8λ���ݽӿ�),N=1(DB3,������ʾ),L=0(DB2,5x8������ʾ).
			DISP_OFF:data<=8'h08;//8'b0000_1000,��ʾ��������:D=0(DB2,��ʾ��),C=0(DB1,��겻��ʾ),D=0(DB0,��겻��˸)
			DISP_CLEAR:data<=8'h01;//8'b0000_0001,����
			ENTRY_MODE:data<=8'h06;//8'b0000_0110,����ģʽ����:I/D=1(DB1,д�������ݹ������),S=0(DB0,��ʾ���ƶ�)
			DISP_ON:data<=8'h0c;//8'b0000_1100,��ʾ��������:D=1(DB2,��ʾ��),C=0(DB1,��겻��ʾ),D=0(DB0,��겻��˸)
			ROW1_ADDR:data<=8'h80;//8'b1000_0000,����DDRAM��ַ:00H->1-1,��һ�е�һλ
			//�������row_1��ÿ8-bit���,�������Ӧ����ʾλ
			ROW1_0:data<=row_1[127:120];
			ROW1_1:data<=row_1[119:112];
			ROW1_2:data<=row_1[111:104];
			ROW1_3:data<=row_1[103: 96];
			ROW1_4:data<=row_1[ 95: 88];
			ROW1_5:data<=row_1[ 87: 80];
			ROW1_6:data<=row_1[ 79: 72];
			ROW1_7:data<=row_1[ 71: 64];
			ROW1_8:data<=row_1[ 63: 56];
			ROW1_9:data<=row_1[ 55: 48];
			ROW1_A:data<=row_1[ 47: 40];
			ROW1_B:data<=row_1[ 39: 32];
			ROW1_C:data<=row_1[ 31: 24];
			ROW1_D:data<=row_1[ 23: 16];
			ROW1_E:data<=row_1[ 15:  8];
			ROW1_F:data<=row_1[  7:  0];
			ROW2_ADDR:data<=8'hc0;//8'b1100_0000,����DDRAM��ַ:40H->2-1,�ڶ��е�һλ
			ROW2_0:data<=row_2[127:120];
			ROW2_1:data<=row_2[119:112];
			ROW2_2:data<=row_2[111:104];
			ROW2_3:data<=row_2[103: 96];
			ROW2_4:data<=row_2[ 95: 88];
			ROW2_5:data<=row_2[ 87: 80];
			ROW2_6:data<=row_2[ 79: 72];
			ROW2_7:data<=row_2[ 71: 64];
			ROW2_8:data<=row_2[ 63: 56];
			ROW2_9:data<=row_2[ 55: 48];
			ROW2_A:data<=row_2[ 47: 40];
			ROW2_B:data<=row_2[ 39: 32];
			ROW2_C:data<=row_2[ 31: 24];
			ROW2_D:data<=row_2[ 23: 16];
			ROW2_E:data<=row_2[ 15:  8];
			ROW2_F:data<=row_2[  7:  0];
		endcase
   end
end
//wire[127:0]row_1=counter;
wire[127:0]row_2="www.cnu.edu.cn  ";

//part VI:design the count60

//part VI.I design the flag;
parameter COUNT_TIME=1_005_000;
reg[19:0]cnt_5000;
always@(posedge clk or negedge rst)begin
  if(!rst)begin
     cnt_5000<=1'b0;
  end
  //if the delay is done,to stop.
  else if(delay_done)begin
     if(cnt_5000==COUNT_TIME-1'b1)begin
        cnt_5000<=1'b0;
     end
     else begin
        cnt_5000<=cnt_5000+1'b1;
     end
  end
  else begin
    cnt_5000<=1'b0;
  end
end
wire count_flag=(cnt_5000==COUNT_TIME-1'b1)?1'b1:1'b0;//to define the write flag. to tell the LCD to write.


always@(posedge clk or negedge rst)begin
   if(!rst)begin
     counter<=0;
   end
   else if(count_flag&&write_flag)begin
      if(counter>=59)begin
          counter<=0;
      end
      else begin
          counter<=counter+1;
      end
   end
end

// Convert counter to row_1 as a string of 2-digit ASCII characters
    wire [127:0] row_1 = {convert_to_ascii(counter / 10), convert_to_ascii(counter % 10),
                          8'h20,8'h20,
                          8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20, 8'h20,
                          8'h20, 8'h20, 8'h20, 8'h20};

    // Convert a digit to ASCII
    function [7:0] convert_to_ascii;
        input [3:0] digit;
        begin
            convert_to_ascii = (digit < 10) ? (8'h30 + digit) : 8'h20; // ASCII for 0-9, space for invalid digits
        end
    endfunction
endmodule
