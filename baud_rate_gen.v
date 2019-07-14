// RX baud rate generator .. common baud rates * 16
//system clk, assumed, 50MHz
// baud		// generated (baud * 16)	// mod (m)=(clk / baud generated)	// # bits of counter (n) // sel
// 2400		// 38400					// 1302								// 11					 // 00
// 4800		// 76800					// 651								// 10					 // 01
// 9600		// 153600					// 325								// 9					 // 10
// 19200	// 307200					// 163								// 8					 // 11

module baud_rate_gen
	(
	input wire clk, rst,
	input wire [1:0] baud_sel,
	output reg rx_baud_tick
	);
	// signal declaration
	wire b2400_tick, b4800_tick, b9600_tick, b19200_tick;
	reg clk2_2400, clk2_4800, clk2_9600, clk2_19200; 
	
	// body
	// mod-m counters instantiations
	// baud		// generated 	// m	// n
	// 2400		// 38400		// 1302	// 11
	mod_m_counter #(.n(11), .m(1302)) baud2400 (clk2_2400, rst, , b2400_tick);
	
	// baud		// generated 	// m	// n
	// 4800		// 76800		// 651	// 10
	mod_m_counter #(.n(10), .m(651)) baud4800 (clk2_4800, rst, , b4800_tick);
	
	// baud		// generated 	// m	// n
	// 9600		// 153600		// 325	// 9
	mod_m_counter #(.n(9), .m(325)) baud9600 (clk2_9600, rst, , b9600_tick);
	
	// baud		// generated 	// m	// n
	// 19200	// 307200		// 163	// 8
	mod_m_counter #(.n(8), .m(163)) bau19200 (clk2_19200, rst, , b19200_tick);
	
	// clock path Demux 
	 // This logic for saving power .. 
	 // not all bauds are generatd simultaniously..
	 // the clk will pass only to the selected baud block
	always @ * begin
		clk2_2400 = 0; clk2_4800 = 0; clk2_9600 = 0; clk2_19200 = 0; 
		case (baud_sel)
			2'b00: clk2_2400  = clk;
			2'b01: clk2_4800  = clk;
			2'b10: clk2_9600  = clk;
			2'b11: clk2_19200 = clk;
		endcase
	end // always
	
	//baud selecting logic
	always @ * begin
		case (baud_sel)
			2'b00: rx_baud_tick = b2400_tick;
			2'b01: rx_baud_tick = b4800_tick;
			2'b10: rx_baud_tick = b9600_tick;
			2'b11: rx_baud_tick = b19200_tick;
		endcase
	end // always
	
endmodule