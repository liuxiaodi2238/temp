`timescale 1 ps/ 1 ps
module tb_task1_vlg_tst();

reg clk;
reg res;
reg uart_rxd;
// wires                                               
wire [7:0]  seg_led;
wire [5:0]  seg_sel;
wire uart_txd;

parameter T=20000;


// assign statements (if any)                          
task1 i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.res(res),
	.seg_led(seg_led),
	.seg_sel(seg_sel),
	.uart_rxd(uart_rxd),
	.uart_txd(uart_txd)
);


//定义时钟和res信号
initial 
begin
clk=1'b0;
res=1'b1; end

always #(T/2)   clk=~clk;


//定义UART端信号
initial 
begin uart_rxd=1'b1;
#(52080*T)  uart_rxd=1'b0;  //起始位
#(5208*T)  uart_rxd=1'b1;   //1
#(5208*T)  uart_rxd=1'b0;   //2
#(5208*T)  uart_rxd=1'b1;   //3
#(5208*T)  uart_rxd=1'b0;   //4
#(5208*T)  uart_rxd=1'b0;   //5
#(5208*T)  uart_rxd=1'b1;   //6
#(5208*T)  uart_rxd=1'b0;   //7
#(5208*T)  uart_rxd=1'b1;   //8
#(5208*T)  uart_rxd=1'b1;   //停止位		

#(5208000*T)  uart_rxd=1'b0;	
#(5208*T)  uart_rxd=1'b1;   //1
#(5208*T)  uart_rxd=1'b0;   //2
#(5208*T)  uart_rxd=1'b1;   //3
#(5208*T)  uart_rxd=1'b0;   //4
#(5208*T)  uart_rxd=1'b0;   //5
#(5208*T)  uart_rxd=1'b1;   //6
#(5208*T)  uart_rxd=1'b0;   //7
#(5208*T)  uart_rxd=1'b1;   //8
#(5208*T)  uart_rxd=1'b1;   //停止位	
end												  
                                                
endmodule




//***********第一版
/*`timescale 1 ps/ 1 ps
module tb_task1_vlg_tst();

reg clk;
reg res;
reg uart_rxd;
// wires                                               
wire [7:0]  seg_led;
wire [5:0]  seg_sel;
wire uart_txd;

parameter T=20000;


// assign statements (if any)                          
task1 i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.res(res),
	.seg_led(seg_led),
	.seg_sel(seg_sel),
	.uart_rxd(uart_rxd),
	.uart_txd(uart_txd)
);


//定义时钟和res信号
initial 
begin
clk=1'b0;
res=1'b1; end

always #(T/2)   clk=~clk;


//定义UART端信号
initial 
begin uart_rxd=1'b1;
#(1000*T)  uart_rxd=1'b0;  //起始位
#(261*T)  uart_rxd=1'b1;   //1
#(261*T)  uart_rxd=1'b0;   //2
#(261*T)  uart_rxd=1'b1;   //3
#(261*T)  uart_rxd=1'b0;   //4
#(261*T)  uart_rxd=1'b0;   //5
#(261*T)  uart_rxd=1'b1;   //6
#(261*T)  uart_rxd=1'b0;   //7
#(261*T)  uart_rxd=1'b1;   //8
#(261*T)  uart_rxd=1'b1;   //停止位		

#(100000*T)  uart_rxd=1'b0;	
#(261*T)  uart_rxd=1'b1;   //1
#(261*T)  uart_rxd=1'b0;   //2
#(261*T)  uart_rxd=1'b1;   //3
#(261*T)  uart_rxd=1'b0;   //4
#(261*T)  uart_rxd=1'b0;   //5
#(261*T)  uart_rxd=1'b1;   //6
#(261*T)  uart_rxd=1'b0;   //7
#(261*T)  uart_rxd=1'b1;   //8
#(261*T)  uart_rxd=1'b1;   //停止位	
end												  
                                                
endmodule*/