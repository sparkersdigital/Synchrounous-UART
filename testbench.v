`timescale 1ns/ 1ps

module UARTtb;
////////////////////////////////// signals
reg clk, rst;
reg Rx;
reg Transmit;
wire Tx;

///////////////////////////////////////////////////////// DUT
UARTModule DUT (Tx, Rx, clk, rst, Transmit);

	//////////////////////////////////////////////////////////// clock generation
	always begin clk = 0; #10; clk = 1; #10; end//always

	///////////////////////////////////////////////////////////////////////////////// simulation
	event frame_done;
	/////////////////////////////////////////////////// 1st simulation phase: Rx
	initial begin
	/////////////initialization
	Rx = 1;
	Transmit = 1;
	
	///////////// resetting
	rst = 1;
	#80;
	rst = 0;
	#80;
	rst = 1;
	
	////////////// serial input through Rx. 
	//Let it be (0111_0101) from right to left
	#800; // random delay
	// force start bit
	Rx = 0;
	#104166.7; //time_period of data_bit: buad_rate = 9600 bit/sec (Hz) --> period = 1/9600 = 104_166.7 ns
	// force data bits
	Rx = 0; #104166.7; 
	Rx = 1; #104166.7; 
	Rx = 0; #104166.7; 
	Rx = 0; #104166.7; 
	//
	Rx = 0; #104166.7; 
	Rx = 0; #104166.7; 
	Rx = 0; #104166.7; 
	Rx = 0; #104166.7;
	// force stop bit
	Rx = 1; #104166.7;
	
	// setting event for triggering display 
	#204166.7; // random delay
	-> frame_done;														
	end//initial 
	
	/////////////////////////////////////////////////// 2st simulation phase: Tx
	initial begin
	@ (frame_done);
	$display ("%b", DUT.parallel_rx);
	$display ("%b", DUT.parallel_tx);
	$monitor ("%d: %b",$time ,DUT.TxModule1.parallel_tx_buff);
	$monitor ("%d: %b",$time ,DUT.TxModule1.parallel_tx);
	$monitor ("%d: %b",$time ,DUT.Tx);
	/////////////////// start Tx
	Transmit = 0;
	#1004166.7; //random delay. monitor Tx signal till stop
	$stop;		
	end//initial 
endmodule
