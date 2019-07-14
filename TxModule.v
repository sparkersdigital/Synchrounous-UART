//`timescale 1ns/1ps

module TxModule (clk, rst, serial_tx, parallel_tx_in, start_tx, buff_tick);

	/// Signals
	///*wire tx_baud_tick;
	input clk, rst;
	input buff_tick;
	//parameter [7:0] parallel_tx_const = 8'h40; // 'hD4 
	input [7:0] parallel_tx_in;
	reg [7:0] parallel_tx_buff_nxt;
	reg [7:0] parallel_tx_buff;
	reg [7:0] parallel_tx_nxt;
	reg [7:0] parallel_tx;
	reg [1:0]state;
	reg [1:0]state_nxt;
	parameter [1:0] idle = 2'b00, start = 2'b01, data = 2'b10, stop = 2'b11;
	output reg serial_tx;
	input start_tx;
	reg [2:0]data_count;
	reg [2:0] data_count_nxt;
	//----------------------------------------------
	
	/// 9600 baud generator .. m = 50M/9600 = 5208 .. n = 13
	mod_m_counter  #( .n(13), .m(5208))tx_baud_gen(clk, rst, , tx_baud_tick);
	//------------------------------------------------------------
	
	/// body
	
	
								///******* register
	always @ (negedge clk) begin
	//******* resetting
		if (!rst) begin
			state<= idle;
			data_count<=0;
			//parallel_tx<=parallel_tx_const;
		end//if
	//******* normal operation
		else begin
			// at tx baud rate do the following
			if (tx_baud_tick) begin
				if (start_tx) begin
					parallel_tx_buff <= parallel_tx_buff_nxt;
				end//if
				state <= state_nxt;
				data_count<=data_count_nxt;
				parallel_tx<= parallel_tx_nxt;
			end//if
		end//else
	end//always
	
	
								///******* next-state logic
	always @ * begin
	//******* default next-state signal
		state_nxt = state;
		data_count_nxt = data_count;
		parallel_tx_nxt = parallel_tx;
		parallel_tx_buff_nxt = parallel_tx_buff;
		
	//******* next-state logic for state cases
	case (state)
		idle: begin
			serial_tx = 1;
			if (start_tx) begin
				state_nxt = start;
				parallel_tx_buff_nxt = parallel_tx_in;
			end//if
		end//case .idle
		
		start: begin
			serial_tx =0;
			state_nxt = data;
			parallel_tx_nxt = parallel_tx_buff;
		end//case .start
		
		data: begin
			serial_tx = parallel_tx[0];
			parallel_tx_nxt = {parallel_tx [0],parallel_tx [7:1]};
			if (data_count == 7) begin
				state_nxt = stop;
			end//if
			else begin
				data_count_nxt = data_count+3'b1;
			end//else
		end//case .data
		
		stop: begin
			if (start_tx) begin
				state_nxt = stop;
				serial_tx = 1;
			end//if
			else begin
				data_count_nxt = 0;
				serial_tx = 1;
				state_nxt = idle;
			end//else
		end//case .stop
	endcase
	end//always
endmodule