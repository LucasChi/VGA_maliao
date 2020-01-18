`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/10 08:36:40
// Design Name: 
// Module Name: project_all
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module project_all(clk,disp_rgb,hsync,vsync,btn_up,btn_down,btn_left,btn_right,rst,btn_start);
input        clk,rst;
input        btn_up,btn_down,btn_left,btn_right,btn_start;
output[11:0] disp_rgb;
output       hsync,
             vsync;

reg[9:0]    hcount;
reg[9:0]    vcount;
reg[11:0]    data;
reg[11:0]    data0;
reg[11:0]    data1;
reg[11:0]    data2;
reg[11:0]    data3;
reg[1:0]    flag=0;
wire        hcount_ov;
wire        vcount_ov;
wire        dat_act;
wire        hsync;
wire        vsync;
reg         vga_clk=0;
reg         cnt_clk=0;
reg[11:0]   hd_dat;
reg[11:0]   a=0;
reg[11:0]   b=0,c=0,d=0,e=0,f=0,g=0,h=0,
            e1=0,e2=0,e3=0,e4=0,e5=0,e6=0;
reg[11:0]   x1=0,xr1=0,x2=0,xr2=0,xr3=0,xr4=0,xr5=0,xr6=0;
reg[31:0]   rand1=32'b11001011010011010110101101100101;
reg[31:0]   rand2=32'b10100110010101010010110101010110;
reg[7:0]    count=0;
reg out_sig=1'b0;
reg [7:0]   cnt;
//VGA行，场扫描时序参数表
parameter 
hsync_end  = 10'd95,
hdat_begin = 10'd143,
hdat_end   = 10'd783,
hpixel_end = 10'd799,
vsync_end  = 10'd1,
vdat_begin = 10'd34,
vdat_end   = 10'd514,
vline_end  = 10'd524, 
fk_top     = 10'd173,
fk_bottom  = 10'd198,
fk_leftside= 10'd759,
fk_rightside=10'd784,
fk_speed   = 10'd4;





always@(posedge clk)
begin
     if(cnt_clk == 1)
       begin
          vga_clk <= ~vga_clk;
          cnt_clk <= 0;
       end
      else
          cnt_clk <= cnt_clk + 1;
end             



/**********VGA驱动**********/
//行扫描
always@(posedge vga_clk)
begin
     if(hcount_ov)
        hcount <= 10'd0;
     else
        hcount <= hcount + 10'd1;
end
assign hcount_ov = (hcount == hpixel_end);

//场扫描
always@(posedge vga_clk)
begin
     if(hcount_ov)
     begin
        if(vcount_ov)
           vcount <= 10'd0;
        else
           vcount <= vcount + 10'd1;
     end
end
assign vcount_ov = (vcount == vline_end);

 
//数据、同步信号输入
assign dat_act = ((hcount >= hdat_begin) && (hcount < hdat_end)) && ((vcount > vdat_begin) && (vcount<vdat_end));
assign hsync   = (hcount > hsync_end);                    
assign vsync   = (vcount > vsync_end);
assign disp_rgb = (dat_act)?data:3'h00;    



//伪随机数
always@(posedge vga_clk)
begin
     if(e1==0)
     begin
         x1 <= rand1 % (4'd7);
         if(rand1==0)
           rand1 <= 32'b11001011010011010110101101100101;
          else
          rand1 <= rand1 << 1; 
      end
      else
         x1<=x1;
   xr1 <= x1 * 5'd20;   //120
end

always@(posedge vga_clk)
begin
     if(e2==0)
     begin
         x2 <= rand2 % (4'd7);
         if(rand2==0)
           rand2 <= 32'b10100110010101010010110101010110;
          else
          rand2 <= rand2 << 1; 
      end
      else
         x2<=x2;
   xr2 <= x2 * 5'd20;     //120
 

end

always@(posedge vga_clk)
begin
    if(e3==0)
   xr3 <= xr1+xr2;         //240
   else
   xr3<=xr3;  
end

always@(posedge vga_clk)
begin
if(e4==0)
   xr4 <= xr1 + xr2 /2'd2;          //180
   else
   xr4 <= xr4;
end

always@(posedge vga_clk)
begin
if(e5==0)
   xr5 <= xr2 + xr1 / 2'd2;            //180
   else
   xr5 <= xr5;
end

always@(posedge vga_clk)
begin
if(e6==0)
   xr6 <= xr2 ;                                //120
   else
   xr6 <= xr6;
end



//开始和内容切换
always @ (posedge vga_clk)
begin
   if(!rst)
   begin
     data =data0;
   end  
   else
   begin  
     case(flag)
       2'd0: data =data0;
       2'd1: data =data1;
       2'd2: data =data2;
       2'd3: data =data3;
     endcase
   end   
end     




//控制
always@(posedge vcount_ov)
begin
  if(btn_start)
     flag=1;
   else
     flag=flag;
     
     
     
if(flag == 1)
begin   
//方块上移     
   if(btn_up && (fk_top-a+c)>=40)           
     a = a+fk_speed;    
   else
     a=a;
   
//方块下移       
   if(btn_down && (fk_bottom-a+c) <= 510)
     c = c+fk_speed;
   else
     c=c;
   
//左移       
   if(btn_left && (fk_leftside -b+d)>=144) 
     b=b+fk_speed;
   else
     b=b;
//右移       
   if(btn_right && (fk_rightside-b+d)<=784)
     d=d+fk_speed;
   else
     d=d;
     
     
//柱子移动 
//a柱
     if(e1<=644)
       e1=e1+1;
     else
       e1=0;
 //b柱   
     if(  (e1>=110) ||  (e2>0)   )
       e2=e2+1;
     else
       e2=0;
     if(e2 == 644)
       e2=0;
     else
       e2=e2; 
 //c柱      
     if(  e2 >= 100   ||  e3>0 )
       e3=e3+1;
     else
       e3=0;
     if(e3 == 644)
       e3=0;
     else
       e3=e3; 
//d柱       
     if(e3 >=110   || e4>0 )
       e4=e4+1;
     else
       e4=0;
     if(e4 == 644)
       e4=0;
     else
       e4=e4; 
//e    
     if(e4 >= 130   || e5>0)
       e5=e5+1;
     else
       e5=0;
     if(e5 == 644)
       e5=0;
     else
       e5=e5; 
//f
     if(e5 >= 100   || e6>0)
       e6=e6+1;
     else
       e6=0;
     if(e6 == 644)
       e6=0;
     else
       e6=e6;
   

   
//柱子右边界  
//a  
   if((fk_leftside-b+d) >= (136+e1) && (fk_leftside-b+d) <= (140+e1) && (fk_top-a+c) <= (300-xr1))    //上
    begin
    count =0;
       a=0;
       b=0;
       c=0;
       d=0;
       e1=0;
       e2=0;
       e3=0;
       e4=0;
       e5=0;
       e6=0;
       flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end 
//b    
   if( (fk_leftside-b+d) >= (136+e2) && (fk_leftside-b+d) <= (140+e2) && (fk_bottom-a+c) >= (200+xr2))  //下
    begin
    count =0;
       a=0;
       b=0;
       c=0;
       d=0;
       e1=0;
       e2=0;
       e3=0;
       e4=0;
       e5=0;
       e6=0;
       flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end    
//c
   if( (fk_leftside-b+d) >= (136+e3) && (fk_leftside-b+d) <= (140+e3) && (fk_top-a+c) <= (300-xr3))    //上
    begin
    count =0;
       a=0;
       b=0;
       c=0;
       d=0;
       e1=0;
       e2=0;
       e3=0;
       e4=0;
       e5=0;
       e6=0;
       flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end  
//d
   if( (fk_leftside-b+d) >= (136+e4) && (fk_leftside-b+d) <= (140+e4) && (fk_bottom-a+c) >= (240+xr4) )    //下
    begin
    count =0;
       a=0;
       b=0;
       c=0;
       d=0;
       e1=0;
       e2=0;
       e3=0;
       e4=0;
       e5=0;
       e6=0;
       flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end
//e
   if( (fk_leftside-b+d) >= (136+e5) && (fk_leftside-b+d) <= (140+e5) && (fk_bottom-a+c) >= (200+xr5) )    //下
    begin
    count =0;
       a=0;
       b=0;
       c=0;
       d=0;
       e1=0;
       e2=0;
       e3=0;
       e4=0;
       e5=0;
       e6=0;
       flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end
//f
    if( (fk_leftside-b+d) >= (136+e6) && (fk_leftside-b+d) <= (140+e6) && (fk_top-a+c) <= (300-xr6) )    //上
    begin
    count =0;
       a=0;
       b=0;
       c=0;
       d=0;
       e1=0;
       e2=0;
       e3=0;
       e4=0;
       e5=0;
       e6=0;
       flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end
   
//柱子下边界  
//a        
   if( (fk_top-a+c) >= (296-xr1)  && (fk_top-a+c) <= (300-xr1)  && (fk_leftside-b+d) < (140+e1) && (fk_rightside-b+d) > (119+e1))       //上
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;     
    end
//c
    if( (fk_top-a+c) >= (296-xr3) && (fk_top-a+c) <= (300-xr3)  && (fk_leftside-b+d) < (140+e3) && (fk_rightside-b+d) > (119+e3))       //上
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;     
    end
//f
    if((fk_top-a+c) >= (296-xr6)  && (fk_top-a+c) <= (300-xr6)  && (fk_leftside-b+d) < (140+e6) && (fk_rightside-b+d) > (119+e6))       //上
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;     
    end

//柱子上边界
//b
    if( (fk_bottom-a+c) >= (200+xr2)  && (fk_bottom-a+c) <= (204+xr2)  && (fk_leftside-b+d) < (140+e2) && (fk_rightside-b+d) > (119+e2))       //下
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;     
    end
//d
    if( (fk_bottom-a+c) >= (240+xr4)  && (fk_bottom-a+c) <= (244+xr4)  && (fk_leftside-b+d) < (140+e4) && (fk_rightside-b+d) > (119+e4))       //下
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;     
    end
//e
    if( (fk_bottom-a+c) >= (200+xr5)  && (fk_bottom-a+c) <= (204+xr5)  && (fk_leftside-b+d) < (140+e5) && (fk_rightside-b+d) > (119+e5))       //下
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag = 2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;     
    end
    
//柱子左边界
//a     
   if( (fk_rightside-b+d) >= (119+e1) && (fk_rightside-b+d) <= (123+e1) && (fk_top-a+c) <= (300-xr1)) //上
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag=2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end   
//b  
     if( (fk_rightside-b+d) >= (119+e2) && (fk_rightside-b+d) <= (123+e2) && (fk_bottom-a+c) >= (200+xr2)) //下
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag=2;
    end
   else
    begin
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end   
//c
     if( (fk_rightside-b+d) >= (119+e3) && (fk_rightside-b+d) <= (123+e3) && (fk_top-a+c) <= (300-xr3)) //上
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag=2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end                
//d
    if( (fk_rightside-b+d) >= (119+e4) && (fk_rightside-b+d) <= (123+e4) && (fk_bottom-a+c) >= (240+xr4)) //下
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag=2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end  
//e
    if( (fk_rightside-b+d) >= (119+e5) && (fk_rightside-b+d) <= (123+e5) && (fk_bottom-a+c) >= (200+xr5)) //下
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag=2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end  
//f
    if( (fk_rightside-b+d) >= (119+e6) && (fk_rightside-b+d) <= (123+e6) && (fk_top-a+c) <= (300-xr6)) //上
    begin
    count =0;
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
      flag=2;
    end
   else
    begin
    count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end 
    
    
    
 //计数
 //a
 if((fk_rightside-b+d) == (119 +e1))
    begin
      count=1;
    end

  


//b
else if((fk_rightside-b+d) == (119 +e2))
    begin
      count=2;
    end
 


//c
else if((fk_rightside-b+d) == (119 +e3))
    begin
      count=3;
    end


//d
else if((fk_rightside-b+d) == (119 +e4))
    begin
      count=4;
    end




//e
else if((fk_rightside-b+d) == (119 +e5))
    begin
      count=5;
    end



//f
else if((fk_rightside-b+d) <= (119 +e6))
    begin
      count=6;
    end



  if(count == 6)
   begin
      a=0;
      b=0;
      c=0;
      d=0;
      e1=0;
      e2=0;
      e3=0;
      e4=0;
      e5=0;
      e6=0;
    flag = 3;
    count =0;     
   end
  else
    begin
      count =count;
       a=a;
       b=b;
       c=c;
       d=d;
       e1=e1;
       e2=e2;
       e3=e3;
       e4=e4;
       e5=e5;
       e6=e6;
    end 
  end 
  
   
else
    flag = flag;    
end


always @ (count)
begin
  cnt =  count;
end  




//图像显示
always @ (posedge vga_clk)
begin
//柱子
//a
     if(hcount>(119+e1) && hcount < (140+e1 ) && vcount < (300-xr1) && vcount >35 )     //上
       data1 <= 12'h010;
 //b   
     else if(hcount>(119+e2) && hcount < (140+e2 ) && vcount > (200+xr2) && vcount <515) //下
       data1 <= 12'h010;
 //c   
     else if(hcount>(119+e3) && hcount < (140+e3 ) && vcount < (300-xr3) && vcount > 35) //上
       data1 <= 12'h010; 
 //d   
     else if(hcount>(119+e4) && hcount < (140+e4 ) && vcount > (240+xr4) && vcount <515) //下
       data1 <= 12'h010;
 //e
     else if(hcount>(119+e5) && hcount < (140+e5 ) && vcount > (200+xr5) && vcount <515) //下
       data1 <= 12'h010;
 //f  
     else if(hcount>(119+e6) && hcount < (140+e6 ) && vcount < (300-xr6) && vcount > 35) //上
       data1 <= 12'h010; 
       
 //马里奥          
    //1
      else if(hcount >= (768-b+d) && hcount <= (773-b+d) && vcount >= (173-a+c) && vcount <=(174-a+c))
            data1 <= 12'hf00;
  //2
      else if(hcount >= (764-b+d) && hcount <= (773-b+d) && vcount >( 174-a+c) && vcount <=(175-a+c))
            data1 <= 12'hf00;
//3
      else if(hcount >= (764-b+d) && hcount <= (773-b+d) && vcount > (175-a+c) && vcount <=(176-a+c))
            data1 <= 12'hf00;
 //4
      else if(hcount > (767-b+d) && hcount <=( 768-b+d) && vcount > (176-a+c) && vcount <=(177-a+c))
            data1 <= 12'h68b;
      else if(hcount > (768-b+d) && hcount <= (770-b+d) && vcount > (176-a+c) && vcount <=(177-a+c))
            data1 <= 12'hffc;
       else if(hcount > (770-b+d) && hcount <= (773-b+d) && vcount > (176-a+c) && vcount <=(177-a+c))
            data1 <= 12'h0cd;
 //5
       else if(hcount >( 767-b+d) && hcount <= (768-b+d) && vcount > (177-a+c) && vcount <=(178-a+c))
            data1 <= 12'h68b;
       else if(hcount > (764-b+d) && hcount <= (767-b+d) && vcount >( 177-a+c) && vcount <=(178-a+c))
            data1 <= 12'h68b;
       else if(hcount > (768-b+d) && hcount <= (775-b+d) && vcount > (177-a+c) && vcount <=(178-a+c))
            data1 <= 12'h0cd;
       else if(hcount > (775-b+d) && hcount <=( 777-b+d) && vcount > (177-a+c) && vcount <=(178-a+c))
            data1 <= 12'h0cd;
 //6
        else if(hcount > (762-b+d) && hcount <= (775-b+d) && vcount > (178-a+c) && vcount <=(179-a+c))
            data1 <= 12'hffc;
        else if(hcount >( 775-b+d) && hcount <= (777-b+d) && vcount >( 178-a+c) && vcount <=(179-a+c))
            data1 <= 12'h0cd;
 //7
        else if(hcount > (762-b+d) && hcount <= (766-b+d) && vcount >( 179-a+c) && vcount <=(180-a+c))
            data1 <= 12'hffc;
        else if(hcount > (766-b+d) && hcount <= (767-b+d) && vcount > (179-a+c) && vcount <=(180-a+c))
            data1 <= 12'h0cd;   
        else if(hcount > (767-b+d) && hcount <= (773-b+d) && vcount >( 179-a+c) && vcount <=(180-a+c))
            data1 <= 12'hffc;
        else if(hcount > (773-b+d) && hcount <= (777-b+d) && vcount > (179-a+c) && vcount <=(180-a+c))
            data1 <= 12'h0cd;
 //8
        else if(hcount > (764-b+d) && hcount <= (767-b+d) && vcount > (180-a+c) && vcount <=(181-a+c))
            data1 <= 12'h0cd;
        else if(hcount > (767-b+d) && hcount <= (773-b+d) && vcount > (180-a+c) && vcount <=(181-a+c))
            data1 <= 12'hffc;
 //9
        else if(hcount > (765-b+d) && hcount <= (774-b+d) && vcount > (181-a+c) && vcount <=(182-a+c))
            data1 <= 12'h0cd;
 //10
        else if(hcount > (767-b+d) && hcount <= (773-b+d) && vcount > (182-a+c) && vcount <=(183-a+c))
            data1 <= 12'h0cd;
 //11
        else if(hcount > (766-b+d) && hcount <= (774-b+d) && vcount > (183-a+c) && vcount <=(184-a+c))
            data1 <= 12'hf00;
 //12
        else if(hcount > (764-b+d) && hcount <= (776-b+d) && vcount > (184-a+c) && vcount <=(185-a+c))
            data1 <= 12'hf00;
//13
        else if(hcount > (763-b+d) && hcount <= (772-b+d) && vcount > (185-a+c) && vcount <=(186-a+c))
            data1 <= 12'hf00;            
        else if(hcount >( 772-b+d) && hcount <=( 774-b+d) && vcount >( 185-a+c) && vcount <=(186-a+c))
            data1 <= 12'h00f;
        else if(hcount > (774-b+d) && hcount <= (778-b+d) && vcount > (185-a+c) && vcount <=(186-a+c))
            data1 <= 12'hf00;    
 //14
        else if(hcount > (761-b+d) && hcount <= (766-b+d) && vcount >( 186-a+c) && vcount <=(187-a+c))
            data1 <= 12'hf00; 
        else if(hcount > (766-b+d) && hcount <= (768-b+d) && vcount > (186-a+c) && vcount <=(187-a+c))
            data1 <= 12'h00f;
        else if(hcount > (768-b+d) && hcount <= (772-b+d) && vcount >( 186-a+c) && vcount <=(187-a+c))
            data1 <= 12'hf00; 
        else if(hcount > (772-b+d) && hcount <= (774-b+d) && vcount > (186-a+c) && vcount <=(187-a+c))
            data1 <= 12'h00f;
        else if(hcount > (774-b+d) && hcount <= (781-b+d) && vcount > (186-a+c) && vcount <=(187-a+c))
            data1 <= 12'hf00;
//15
        else if(hcount > (760-b+d) && hcount <= (766-b+d) && vcount > (187-a+c) && vcount <=(188-a+c))
            data1 <= 12'hf00;
        else if(hcount > (766-b+d) && hcount <= (768-b+d) && vcount > (187-a+c) && vcount <=(188-a+c))
            data1 <= 12'h00f;
        else if(hcount > (768-b+d) && hcount <= (772-b+d) && vcount > (187-a+c) && vcount <=(188-a+c))
            data1 <= 12'hf00; 
        else if(hcount > (772-b+d) && hcount <= (774-b+d) && vcount > (187-a+c) && vcount <=(188-a+c))
            data1 <= 12'h00f;
        else if(hcount > (774-b+d) && hcount <= (783-b+d) && vcount > (187-a+c) && vcount <=(188-a+c))
            data1 <= 12'hf00;                
//16
        else if(hcount > (759-b+d) && hcount <= (764-b+d) && vcount > (188-a+c) && vcount <=(189-a+c))
            data1 <= 12'hf00;           
        else if(hcount > (764-b+d) && hcount <= (766-b+d) && vcount >( 188-a+c) && vcount <=(189-a+c))
            data1 <= 12'hffc;
        else if(hcount > (766-b+d) && hcount <= (774-b+d) && vcount >( 188-a+c) && vcount <=(189-a+c))
            data1 <= 12'h00f; 
        else if(hcount > (774-b+d) && hcount <= (776-b+d) && vcount > (188-a+c) && vcount <=(189-a+c))
            data1 <= 12'hffc; 
        else if(hcount > (776-b+d) && hcount <= (778-b+d) && vcount >( 188-a+c) && vcount <=(189-a+c))
            data1 <= 12'hf00; 
        else if(hcount > (778-b+d) && hcount < (784-b+d) && vcount > (188-a+c) && vcount <=(189-a+c))
            data1 <= 12'hffc;
//17
        else if(hcount > (759-b+d) && hcount <= (761-b+d) && vcount > (189-a+c) && vcount <=(190-a+c))
            data1 <= 12'hffc;
        else if(hcount > (761-b+d) && hcount <= (762-b+d) && vcount > (189-a+c) && vcount <=(190-a+c))
            data1 <= 12'hf00;
        else if(hcount > (762-b+d) && hcount <= (766-b+d) && vcount > (189-a+c) && vcount <=(190-a+c))
            data1 <= 12'hffc;
        else if(hcount > (766-b+d) && hcount <= (774-b+d) && vcount > (189-a+c) && vcount <=(190-a+c))
            data1 <= 12'h00f;
        else if(hcount > (774-b+d) && hcount < (784-b+d) && vcount > (189-a+c) && vcount <=(190-a+c))
            data1 <= 12'hffc;
//18
        else if(hcount > (759-b+d) && hcount <= (767-b+d) && vcount > (190-a+c) && vcount <=(191-a+c))
            data1 <= 12'hffc;
        else if(hcount > (767-b+d) && hcount <= (773-b+d) && vcount >( 190-a+c) && vcount <=(191-a+c))
            data1 <= 12'h00f;
        else if(hcount > (773-b+d) && hcount < (784-b+d) && vcount > (190-a+c) && vcount <=(191-a+c))
            data1 <= 12'hffc;
//19
        else if(hcount > (759-b+d) && hcount <= (767-b+d) && vcount > (191-a+c) && vcount <=(192-a+c))
            data1 <= 12'hffc;
        else if(hcount > (767-b+d) && hcount <= (773-b+d) && vcount > (191-a+c) && vcount <=(192-a+c))
            data1 <= 12'h00f;
        else if(hcount > (773-b+d) && hcount < (784-b+d) && vcount > (191-a+c) && vcount <=(192-a+c))
            data1 <= 12'hffc;
//20
        else if(hcount > (765-b+d) && hcount <= (775-b+d) && vcount > (192-a+c) && vcount <=(193-a+c))
            data1 <= 12'h00f;  
//21
        else if(hcount > (763-b+d) && hcount <= (777-b+d) && vcount > (193-a+c) && vcount <=(194-a+c))
            data1 <= 12'h00f; 
//22
        else if(hcount > (761-b+d) && hcount <= (779-b+d) && vcount > (194-a+c) && vcount <=(195-a+c))
            data1 <= 12'h00f;
//23
        else if(hcount > (762-b+d) && hcount <= (765-b+d) && vcount >( 195-a+c) && vcount <=(196-a+c))
            data1 <= 12'hb22;
        else if(hcount > (775-b+d) && hcount <= (778-b+d) && vcount > (195-a+c) && vcount <=(196-a+c))
            data1 <= 12'hb22; 
//24
        else if(hcount > (760-b+d) && hcount <=(765-b+d) && vcount > (196-a+c) && vcount <=(197-a+c))
            data1 <= 12'hb22;
        else if(hcount > (775-b+d) && hcount <= (781-b+d) && vcount > (196-a+c) && vcount <=(197-a+c))
            data1 <= 12'hb22;
 //25
        else if(hcount > (760-b+d) && hcount <= (765-b+d) && vcount > (197-a+c) && vcount <=(198-a+c))
            data1 <= 12'hb22;
        else if(hcount > (775-b+d) && hcount <= (781-b+d) && vcount > (197-a+c) && vcount <=(198-a+c))
            data1 <= 12'hb22; 
              
        else 
        data1 <= 12'h000;
  
end



// GO!
always@(posedge vga_clk)
begin
if((hcount>= 274 && hcount <= 294) && (vcount >= 200 && vcount <=350))
data0 <= 12'h111;

else if((hcount >= 274 && hcount <=394) && (vcount >= 200 && vcount <=220))
data0 <= 12'h111;

else if((hcount >= 274 && hcount <= 394) && (vcount >= 330 && vcount <=350))
data0 <= 12'h111;

else if((hcount >= 334 && hcount <= 394) && (vcount >= 275 && vcount <=295))
data0 <= 12'h111;

else if((hcount >= 374 && hcount <= 394) && (vcount >= 275 && vcount <= 350))
data0 <= 12'h111;

else if((hcount >= 454 && hcount <= 574) && (vcount >= 200 && vcount <= 220))
data0 <= 12'h111;

else if((hcount >= 454 && hcount <= 574) && (vcount >= 330 && vcount <= 350))
data0 <= 12'h111;

else if((hcount >= 454 && hcount <= 474) && (vcount >= 200 && vcount <= 350))
data0 <= 12'h111;

else if((hcount >= 554 && hcount <= 574) && (vcount >= 200 && vcount <= 350))
data0 <= 12'h111;

else if((hcount >= 634 && hcount <= 654) && (vcount >= 200 && vcount<= 310))
data0 <= 12'h111;

else if((hcount >= 634 && hcount<= 654) && (vcount >= 330 && vcount <= 350))
data0 <= 12'h111;

else data0 <= 12'h000;
end

//GG!
always@(posedge vga_clk)
begin
if((hcount>= 274 && hcount <= 294) && (vcount >= 200 && vcount <=350))
data2 <= 12'hf00;

else if((hcount >= 274 && hcount <=394) && (vcount >= 200 && vcount <=220))
data2 <= 12'hf00;

else if((hcount >= 274 && hcount <= 394) && (vcount >= 330 && vcount <=350))
data2 <= 12'hf00;

else if((hcount >= 334 && hcount <= 394) && (vcount >= 275 && vcount <=295))
data2 <= 12'hf00;

else if((hcount >= 374 && hcount <= 394) && (vcount >= 275 && vcount <= 350))
data2 <= 12'hf00;

else if((hcount>= 454 && hcount <= 474) && (vcount >= 200 && vcount <=350))
data2 <= 12'hf00;

else if((hcount >= 454 && hcount <= 574) && (vcount >= 200 && vcount <=220))
data2 <= 12'hf00;

else if((hcount >= 454 && hcount <= 574) && (vcount >= 330 && vcount <=350))
data2 <= 12'hf00;

else if((hcount >= 514 && hcount <= 574) && (vcount >= 275 && vcount <=295))
data2 <= 12'hf00;


else if((hcount >= 554 && hcount <= 574) && (vcount >= 275 && vcount <= 350))
data2 <= 12'hf00;

else if((hcount >= 634 && hcount <= 654) && (vcount >= 200 && vcount<= 310))
data2 <= 12'hf00;

else if((hcount >= 634 && hcount<= 654) && (vcount >= 330 && vcount <= 350))
data2 <= 12'hf00;

else data2 <= 12'h000;
end

//$10
always@(posedge vga_clk)
begin
if((hcount>= 454 && hcount <= 474) && (vcount >= 200 && vcount <=350))
data3 <= 12'h000;

else if((hcount >= 534 && hcount <= 554) && (vcount >= 200 && vcount <=350))
data3 <= 12'h000;

else if((hcount >= 604 && hcount <= 624) && (vcount >= 200 && vcount <=350))
data3 <= 12'h000;

else if((hcount >= 534 && hcount <= 624) && (vcount >= 200 && vcount <=220))
data3 <= 12'h000;

else if((hcount >= 534 && hcount <= 624) && (vcount >= 330 && vcount <=350))
data3 <= 12'h000;

else if((hcount >= 304 && hcount <= 324) && (vcount >= 220 && vcount <=240))
data3 <= 12'hf00;

else if((hcount >= 284 && hcount <= 304) && (vcount >= 200 && vcount <=220))
data3 <= 12'hf00;

else if((hcount >= 344 && hcount <= 364) && (vcount >= 220 && vcount <=240))
data3 <= 12'hf00;

else if((hcount >= 364 && hcount <= 384) && (vcount >= 200 && vcount <=220))
data3 <= 12'hf00;

else if((hcount >= 274 && hcount <= 394) && (vcount >= 240 && vcount <=260))
data3 <= 12'hf00;

else if((hcount >= 274 && hcount <= 394) && (vcount >= 300 && vcount <=320))
data3 <= 12'hf00;

else if((hcount >= 324 && hcount <= 344) && (vcount >= 240 && vcount <=350))
data3 <= 12'hf00;

else data3 <= 12'hfff;
end



endmodule
