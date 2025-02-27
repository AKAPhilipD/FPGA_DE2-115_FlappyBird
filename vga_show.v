module vga_show(vga_clk,rst,hs,vs,showon,hc,vc,vga_sync);
input vga_clk,rst;
output reg hs;//vga行扫描信号。
output reg vs;//vga场扫描信号。
output reg showon;//vga显示使能，如果为1则可以显示，如果不为1则什么也不显示。
output reg [9:0]hc,vc;//代表实际的行，列位置。
output wire vga_sync;

reg vsenable;

//这个代码负责划分显示区域。

//刷行。先扫描行信号，再扫描场信号。
always@(posedge vga_clk)begin
   if(!rst)begin
	   hc<=0;
	end
	else begin
	   if(hc==10'd799)begin//根据VGA扫描信号，一行一共有800个。即实际的行位置是从0~799。
		   hc<=0;
			vsenable<=1;//负责控制开始垂直扫描的使能。
		end
		else begin
		   hc<=hc+1'd1;//场逐渐加。
			vsenable<=0;//不能开始扫描场。
		end
	end
end
//根据vga扫描表当hc<90是不输出内容的。
always@(*)begin
   if(hc<10'd96)begin
	   hs<=0;
	end
	else begin
	   hs<=1;
	end
end

//接下来扫描场信号。和行信号代码逻辑一样。
always@(posedge vga_clk)begin
   if(!rst)begin
	    vc=0;
	end
	else if(vsenable)begin
	   if(vc==10'd524)begin//一共有525个。即0~524。
		   vc<=0;
		end
		else begin
		   vc<=vc+1'd1;
		end
	end
end

//当根据vga扫描表vc<2是不输出内容的。
always@(*)begin
  if(vc<2)begin
     vs<=0;
  end
  else begin
     vs<=1;
  end
end


//卡一下输出内容的范围，在该范围内showon=1。
always@(*)begin
  if(((hc<10'd784)&&(hc>=10'd144))&&((vc<10'd515)&&(vc>=10'd35)))begin
     showon<=1;
  end
  else begin
     showon<=0;
  end
end

assign vga_sync=1'b0;
endmodule
