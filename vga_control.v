module vga_control(hc,vc,mclk,rst,showon,keyin,r,g,b,score);
input [9:0]hc,vc;
input mclk,rst,showon,keyin;
output reg[7:0]r,g,b;
output reg[6:0]score;//设置记录分数。

reg [31:0]clkdiv=0;//总时钟。决定其他几个时钟的频率。
wire dclk;//定义小鸟运动时钟。
wire sjclk;
wire sclk;
wire lrclk;

//先来控制一下clkdiv
always@(posedge mclk or negedge rst)begin
  if(!rst)begin
     clkdiv<=0;
  end
  else begin
     clkdiv<=clkdiv+1'b1;
  end
end

reg [9:0]top_bird=10'd131;//定义小鸟上界。即33+2+480*0.2=131
reg [9:0]down_bird=10'd161;//定义小鸟下界。即30x30的图片，131+30=161
reg [9:0]left_bird=10'd200;//定义小鸟左界。
reg [9:0]right_bird=10'd231;//定义小鸟右界。
reg [9:0]top_block=10'd50;//定义障碍上界。
reg [9:0]left_block=10'd500;//定义障碍左界。
reg [9:0]right_block=10'd550;//定义障碍右界。


assign dclk=clkdiv[20];//小鸟运动时钟。

always@(posedge dclk)begin
  if(!rst)begin
  //定义小鸟初始位置。
  top_bird=10'd131;
  down_bird=10'd161;
  end
  else begin
    if(keyin==1 && top_bird>35)begin //35代表鸟出了图外。
	    top_bird<=top_bird-10'd50;//向上跳50个单位。
		 down_bird<=down_bird-10'd50;//向上跳50个单位。
	 end
	 else if(down_bird<10'd515)begin//515是2+33+480，不出屏幕的位置。负责控制下落.
	 top_bird<=top_bird+10'd10;//下落10个单位
	 down_bird<=down_bird+10'd10;//下落10个单位。
	 end
  end
end

//接下来控制位置
assign sjclk=clkdiv[15];//用于生成随机数的时钟，使得柱子位置不同。
reg[9:0]pillar_position_1=35;//初始化柱子位置。2+33
//控制柱子的高。
always@(posedge sjclk)begin
  if(!rst)begin
  pillar_position_1<=35;//上柱子的位置，初始位置33+2。
  end
  else begin
    pillar_position_1<=pillar_position_1+1'b1;
	 if(pillar_position_1==360)begin
	    pillar_position_1<=35;
	 end
  end
end

//障碍移动速度会变快。加大难度。控制障碍移动速度。
assign sclk=clkdiv[29];
reg[3:0]speed=3;
always@(posedge sclk)begin
  if(!rst)begin
      speed<=3;
  end
  else if(speed<7)begin
      speed<=speed+1'b1;
  end
end

//控制障碍移动
assign move_clk=clkdiv[20];
always@(posedge move_clk or negedge rst)begin
  if(!rst)begin
    left_block<=10'd500; //在640*480中在横坐标356。
	 right_block<=10'd550;//在640*480中在横坐标406.
	 top_block<=50;//top_block的位置在纵坐标15的位置上。
  end
  else begin
    left_block<=left_block-speed;
	 right_block<=right_block-speed;//实现移动。
	 if(left_block < 10'd145)begin
	    //如果left_block移到屏幕外。柱子回到正常位置。
		 left_block<=10'd500; //在640*480中在横坐标356。
	    right_block<=10'd550;//在640*480中在横坐标406.
	    top_block<=pillar_position_1;//top_block的位置复位，随机刷新。
	 end
  end
end

reg gaming=1;//判断游戏是否结束的bool变量。
reg win_score=1;//防止重复加分。win_score是1代表可以加分。
reg [6:0]get_score=0;//定义初始得分。

//[判定得分与game_over;
/*
always@(posedge dclk or negedge rst)begin
   if(!rst)begin
	//复位的情况。
	  gaming<=1;
	  win_score<=1;
	  score<=0;
	end
	//当鸟碰到管壁的时候。四种方法判定。见PPT。
	else if(((top_block>=down_bird)&&(right_bird>=left_block))||((top_bird>=top_block+150)&&(right_bird>=left_block))||
	((top_block>=down_bird)&&(left_bird<=right_block))||((top_bird>=top_block+150)&&(right_block>=right_bird)))begin
		    gaming<=0;//代表失败。
	end
	//接下来写成功的情况。
	else if(gaming==1&&right_bird>right_block)begin
	    if(win_score==1)begin
		    score<=score+7'd1;
			 win_score<=0;
		 end
	end//代表已经通过。
	else if(right_bird<left_block)begin
	     win_score<=1;
	end//小鸟在管子左边的时候，加分开启。
end*/
always @ (posedge dclk or negedge rst)
begin
   if(!rst)
       begin
         gaming<=1;
			win_score<=1;
			score<=0;
       end
    else if(left_block < left_bird && right_block > right_bird)//鸟与障碍相遇
       begin
          if(top_bird < top_block || down_bird > top_block + 150)//碰撞
            begin
             gaming <= 0;
            end
          else
          if(win_score == 1)
             begin
               win_score <= 0;               
               score <= score + 1'b1;//从通道通过，加1分
             end 
        end 
     else
        win_score <= 1;
end

//接下来给bird和over的rom赋值。
//bird的rom
reg[9:0]addrbird=0;
wire[23:0]databird;
bird bird(.clock(mclk),.address(addrbird),.q(databird));

//over的rom
reg[9:0]addrover=0;
wire[23:0]dataover;
gameover gameover(.clock(mclk),.address(addrover),.q(dataover));
//输出gameover显示。
always@(posedge mclk)begin
  if(showon==1)begin
  //游戏失败的情况下。gameover是300*200
    if(gaming==0)begin
	    if(hc<444&&hc>144&&vc>35&&vc<235)begin
		    addrover<=(vc-35-1)*300+(hc-144-1);
			 r<=dataover[23:16];
			 g<=dataover[15:8];
			 b<=dataover[7:0];
		 end
		 else begin
		    r<=0;
			 g<=0;
			 b<=0;
		 end
	  end//gaming==0的情况。
	 else if(vc<down_bird&&vc>top_bird&&hc<right_bird&&hc>left_bird)begin
	    addrbird<=(vc-top_bird-1)*30+(hc-left_bird)-1;
		 r<=databird[23:16];
		 g<=databird[15:8];
		 b<=databird[7:0];
	 end
    else if(hc<right_block&&hc>left_block&&(vc > top_block + 150 || vc < top_block))begin
      //相关位置画绿色水管。
      r<=8'b00000000;
	   g<=8'b11111111;//绿色。
	   b<=8'b00000000;
    end
    else begin//设置背景色。
      r<=8'b00000000;
	   g<=8'b10000000;
	   b<=8'b10000000;
	 end
  end
  else begin//showon为0的情况下。
     r<=8'b00000000;
	  g<=8'b00000000;
	  b<=8'b00000000;
  end
end
endmodule
