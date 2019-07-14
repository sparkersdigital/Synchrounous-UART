module UARTModule (Tx, Rx, clk, rst, Transmit, OUT);
	input Transmit, Rx, clk, rst;
	output Tx;
	output OUT;
	
	// signal declaration
	wire rx_baud_tick;
	wire [7:0] parallel_rx, parallel_tx;
	
	// body
	
	baud_rate_gen baud_rate_gen1 (clk, rst, 2'b10, rx_baud_tick); // 10 at baud selector chooses 9600 buad rate
	
	RxModule RxModule1(clk, rst, rx_baud_tick, Rx, parallel_rx/*, buff_tick*/); // Transmit signal is the read signal to the FF
	
	TxModule TxModule1(clk, rst, Tx, parallel_tx, ~Transmit, buff_tick); // Transmit signal is the write signal to the FF
	
	// test local system
	assign parallel_tx = parallel_rx +8'b1;
	//increment Local_sys (parallel_rx, parallel_tx);
	
	assign OUT = (parallel_rx == 8'h20) ? 0 
               :(parallel_rx == 8'h40) ? 0 
               :(parallel_rx == 8'h80) ? 0 
               :(parallel_rx == 8'hff) ? 0 
               :1;
  
endmodule 

/*
module increment (out, in);
	output out
	output = input +1;
endmodule*/