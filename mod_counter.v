module mod_m_counter 
	#(
	  parameter n = 4, // outptut # bits
				m = 123 // mod
	)
	(
	 input clk, rst,
	 output [n-1:0] count, 
	 output max_tick
	);
	
	// signal declaration
	reg [n-1:0] count_reg, count_next;
	
	/// body
	// register
	always @ (negedge clk) begin
		if (!rst)
			count_reg <=0;
		else	
		count_reg <= count_next;
	end // always
	
	// next-state logic
	always @ * begin
	if (count_reg == m-1)
	 count_next = 0;
	 else
	 count_next = count_reg + 1;
	end // always
	
	// output logic
	assign count = count_reg;
	assign max_tick = (count_reg == (m-1)) ? 1'b1 : 1'b0;
endmodule