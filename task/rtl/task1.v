module task1(clk,res, uart_rxd,seg_sel,seg_led,uart_txd);
   input clk,res,uart_rxd;
	output uart_txd;
	output [5:0]seg_sel;
	output [7:0]seg_led;
	
//parameter&wire&reg
  wire clk,res,uart_rxd,uart_txd;
  wire [5:0]seg_sel;
  wire [7:0]seg_led;



  wire uart_done;
  wire [7:0]uart_data;
  
  wire empty;
  wire full;
  
  wire [7:0]send_data;


//main code
      //例化接收模块，在传输完成后得到传输数据
		uart_recv u_uart_recv(
			.sys_clk    (clk),                  //in-系统时钟
			.sys_rst_n  (res),                //in-系统复位，低电平有效
			.uart_rxd   (uart_rxd),                 //in-UART接收端口
			.uart_done  (uart_done),                //out-接收一帧数据完成标志信号
			.uart_data  (uart_data)              //out-串转并后接收的数据
			);
		
	    
		 //定义FIFO并将传输数据保存到FIFO中
		 FIFO_ip	FIFO_ip_inst (
			.clock ( clk ),        //in-
			.data ( uart_data ),   //in-
			.rdreq ( full ),           //in-读请求
			.wrreq ( uart_done ),   //in-写请求
			.empty ( empty),        //out-读侧*空
			.full ( full ),         //out-读侧*满     只有一个时钟，读侧和写侧都是一样的
			.q ( send_data)              //out-FIFO数据
			);
	 
	    
			//例化UART发送模块(这一块要认真的研究一下还没有搞定)
			uart_send  	u_uart_send(                 
				.sys_clk        (clk),
				.sys_rst_n      (res),
				.uart_en        (full),     //读请求
				.uart_din       (send_data),   //发送的数据
				.uart_txd       (uart_txd)  //发送端口
				);
				
			//
			assign seg_sel=6'b111111;
			assign seg_led=8'b11111111;
						
			
		  
	 
//always@(posedge clk or negedge res)
 endmodule   








