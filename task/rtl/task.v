module task(clk,res, uart_rxd,seg_sel,seg_led)
   input clk,res,uart_rxd;
	output [5:0]seg_sel;
	output [7:0]seg_led;
	
//parameter&wire&reg
  reg uart_done;
  reg [7:0]uart_data;


//main code
      //例化接收模块，在传输完成后得到传输数据
		uart_recv u_uart_recv(
			.sys_clk    (clk),                  //系统时钟
			.sys_rst_n  (res),                //系统复位，低电平有效
			.uart_rxd   (uart_red),                 //UART接收端口
			.uart_done  (uart_done),                //接收一帧数据完成标志信号
			.uart_data  (uart_data)              //串转并后接收的数据
			);
		
	    
		 //定义FIFO并将传输数据保存到FIFO中
		 FIFO_ip	FIFO_ip_inst (
			.clock ( clk ),
			.data ( uart_data ),
			.rdreq ( uart_done ),
			.wrreq (     ),        //写满
			.empty (     ),        //空
			.full (     ),         //
			.q (    )              //FIFO数据
			);
	 
	     //FIFO写入操作
	 
always@(posedge clk or negedge res)
    












































//*****************************************************
//                ***---UART接收模块---***
//*****************************************************
module uart_recv(
    input			    sys_clk,                  //系统时钟
    input             sys_rst_n,                //系统复位，低电平有效
    
    input             uart_rxd,                 //UART接收端口
    output  reg       uart_done,                //接收一帧数据完成标志信号
    output  reg [7:0] uart_data                 //串转并后接收的数据
    );
    
//parameter define
parameter  CLK_FREQ = 50000000;                 //系统时钟频率
parameter  UART_BPS = 9600;                     //串口波特率
localparam BPS_CNT  = CLK_FREQ/UART_BPS;        //为得到指定波特率，
                                                //需要对系统时钟计数BPS_CNT次，串口波特率周期
//reg define
reg        uart_rxd_d0;
reg        uart_rxd_d1;
reg [15:0] clk_cnt;                             //系统时钟计数器
reg [ 3:0] rx_cnt;                              //接收数据计数器
reg        rx_flag;                             //接收过程标志信号
reg [ 7:0] rxdata;                              //接收数据寄存器

//wire define
wire       start_flag;


//捕获接收端口下降沿(起始位)，得到一个时钟周期的脉冲信号
assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);                   //检测下降沿出现一个Flag：一周期高电平

//对UART接收端口的数据延迟两个时钟周期                                  对接收到的数据进行两次寄存，并作边沿检测
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= 1'b0;          
    end
    else begin
        uart_rxd_d0  <= uart_rxd;                   
        uart_rxd_d1  <= uart_rxd_d0;
    end   
end

//当脉冲信号start_flag到达时，进入接收过程           
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)                                  
        rx_flag <= 1'b0;
    else begin
        if(start_flag)                          //检测到起始位
            rx_flag <= 1'b1;                    //进入接收过程，标志位rx_flag拉高
        else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))
            rx_flag <= 1'b0;                    //计数到停止位中间时，停止接收过程
        else
            rx_flag <= rx_flag;
    end
end

//进入接收过程后，启动系统时钟计数器与接收数据计数器
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin                             
        clk_cnt <= 16'd0;                                  
        rx_cnt  <= 4'd0;
    end                               
      //！每经过一个波特率周期，即接收一位有效数据，数据rx_cnt加一 ；
      //！在一个时钟周期内，计算clk数，若clk_cnt小于波特率周期，则说明是仍然处于接收一位的过程中                      
    else if ( rx_flag ) begin                   //处于接收过程
            if (clk_cnt < BPS_CNT - 1) begin
                clk_cnt <= clk_cnt + 1'b1;
                rx_cnt  <= rx_cnt;
            end
            else begin
                clk_cnt <= 16'd0;               //对系统时钟计数达一个波特率周期后清零
                rx_cnt  <= rx_cnt + 1'b1;       //此时接收数据计数器加1
            end
        end
        else begin                              //接收过程结束，计数器清零
            clk_cnt <= 16'd0;
            rx_cnt  <= 4'd0;
        end
end

//根据接收数据计数器来寄存uart接收端口数据
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if ( !sys_rst_n)  
        rxdata <= 8'd0;                                     
    else if(rx_flag)                            //系统处于接收过程
        if (clk_cnt == BPS_CNT/2) begin         //判断系统时钟计数器计数到数据位中间
            case ( rx_cnt )
             4'd1 : rxdata[0] <= uart_rxd_d1;   //寄存数据位最低位
             4'd2 : rxdata[1] <= uart_rxd_d1;
             4'd3 : rxdata[2] <= uart_rxd_d1;
             4'd4 : rxdata[3] <= uart_rxd_d1;
             4'd5 : rxdata[4] <= uart_rxd_d1;
             4'd6 : rxdata[5] <= uart_rxd_d1;
             4'd7 : rxdata[6] <= uart_rxd_d1;
             4'd8 : rxdata[7] <= uart_rxd_d1;   //寄存数据位最高位
             default:;                                    
            endcase
        end
        else 
            rxdata <= rxdata;
    else
        rxdata <= 8'd0;
end

//数据接收完毕后给出标志信号并寄存输出接收到的数据
always @(posedge sys_clk or negedge sys_rst_n) begin        
    if (!sys_rst_n) begin
        uart_data <= 8'd0;                               
        uart_done <= 1'b0;
    end
    else if(rx_cnt == 4'd9) begin               //接收数据计数器计数到停止位时           
        uart_data <= rxdata;                    //寄存输出接收到的数据
        uart_done <= 1'b1;                      //并将接收完成标志位拉高
    end
    else begin
        uart_data <= 8'd0;                                   
        uart_done <= 1'b0; 
    end    
end

endmodule




//*****************************************************
//                ***---FIFO写模块---***
//*****************************************************
module fifo_wr(
    //mudule clock
    input                   clk    ,        // 时钟信号
    input                   rst_n  ,        // 复位信号

    //user interface
      input                   wrempty,        // 写空信号（从FIFO传回来的信号）
      input                   wrfull ,        // 写满信号（从FIFO传回来的信号）
      output    reg  [7:0]    data   ,        // 写入FIFO的数据（传给FIFO的信号）
      output    reg           wrreq           // 写请求（传给FIFO的信号）
);

//reg define
reg   [1:0]         flow_cnt;               // 状态流转计数

//*****************************************************
//**                    main code
//*****************************************************

//向FIFO中写入数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wrreq <= 1'b0;
        data  <= 8'd0;
        flow_cnt <= 2'd0;
    end
    else begin
        case(flow_cnt)
            2'd0: begin 
                if(wrempty) begin     //写空时，写请求拉高，跳到下一个状态
                    wrreq <= 1'b1;
                    flow_cnt <= flow_cnt + 1'b1;
                end 
                else
                    flow_cnt <= flow_cnt;
            end 
            2'd1: begin               //写满时，写请求拉低，跳回上一个状态
                if(wrfull) begin
                    wrreq <= 1'b0;
                    data  <= 8'd0;
                    flow_cnt <= 2'd0;
                end
                else begin            //没有写满的时候，写请求拉高，继续输入数据
                    wrreq <= 1'b1;
                    data  <= data + 1'd1;
                end
            end 
            default: flow_cnt <= 2'd0;
        endcase
    end
end

endmodule


	