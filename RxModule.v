module RxModule (clk, rst, rx_baud_tick, serial_rx, parallel_rx_out/*, buff_tick*/);
//////////////////////////////// Signals
input clk, rst;
input rx_baud_tick;
input serial_rx;
output [7:0] parallel_rx_out;

//wire [1:0] baud_sel;
wire rx_baud_tick;

reg [7:0] parallel_rx_nxt;
reg [7:0] parallel_rx;
reg [7:0] parallel_rx_buff_nxt;
reg [7:0] parallel_rx_buff;
reg [1:0] state;
reg [1:0] state_nxt;
reg [2:0] count8;
reg [2:0] count8_nxt;
reg [3:0] count16;
reg [3:0] count16_nxt;


parameter [1:0] oversamp = 2'b00, start8samp = 2'b01, data16samp = 2'b10, stop = 2'b11;

/////////////////////////////////////////////////////////////////////////////////////// body
							
///////////////////////////////////////////////////////////////// register
	always @ (negedge clk) begin
	//******* resetting
		if (!rst) begin
			state <= oversamp;
			count8 <= 3'b0;
			count16 <= 4'b0;
			parallel_rx <=7'b0;
		end//if
		//******* normal operation
		else begin
			// at baud rate do the following
				state <= state_nxt;
				count8 <= count8_nxt;
				count16 <= count16_nxt;
				parallel_rx <= parallel_rx_nxt; // serial to parallel shifting
				parallel_rx_buff <= parallel_rx_buff_nxt; // buffering
		end//else
	end//always
	
///////////////////////////////////////////////////// next-state logic
	always @ * begin
	//******* default next-state signal
		state_nxt = state;
		count8_nxt = count8;
		count16_nxt = count16;
		parallel_rx_nxt = parallel_rx;
		parallel_rx_buff_nxt = parallel_rx_buff;
		
	//******* next-state logic for state cases @ baud rate
	case (state)
		oversamp: begin
			if (rx_baud_tick) begin
			if (serial_rx == 0) begin
				state_nxt = start8samp;
				count8_nxt = 3'b0;
			end//if
			end//if baud
		end//case .oversamp
		
		start8samp: begin
			if (rx_baud_tick) begin
			if (count8 == 7) begin //there is extra clock cycle between count8 and count16 for state transition, so, count 7 only
				state_nxt = data16samp;
				count8_nxt = 3'b0;
				count16_nxt = 4'b0;
			end//if
			else begin
				count8_nxt = count8 + 3'b1;
			end//else
			end//if baud
		end//case .start8samp
		
		data16samp: begin
			if (rx_baud_tick) begin
			if (count16 == 15 ) begin
				count16_nxt = 4'b0;
				parallel_rx_nxt = {serial_rx, parallel_rx[7:1]};
				if (count8 == 7) begin // use count 8 this time to count #data_bits shifted
					state_nxt = stop;
					count16_nxt = 4'b0;
				end//if
				else begin
					count8_nxt = count8 + 3'b1;
				end//else
			end//if
			else begin
				count16_nxt = count16 + 4'b1;
			end//else
			end//if baud
		end//case . data16samp
		
		stop: begin
			if (rx_baud_tick) begin
			if (count16 == 15) begin
				state_nxt = oversamp;
				parallel_rx_buff_nxt = parallel_rx;
			end//if
			else begin
				count16_nxt = count16 + 4'b1;
			end//else
			end//if baud
		end//case .stop
	endcase
	end//always*
	
/////////////////////////////////////////////////////// output logic
	assign parallel_rx_out = parallel_rx_buff[7:0];
endmodule