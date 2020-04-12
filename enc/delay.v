module delay(input clock, aclr,  data_write, data_read, counter_mode, data_in,
				 output full_6144, usedw, actual_fifo_we, data_out);
	
	wire we, count_complete;
	
	//FIFO clocked on falling edge
	fifo delay_fifo(aclr, ~clock, data_in, data_read, we, full_6144, data_out, usedw);
	
	
	fifoFSM my_fifo_fsm(.init_we(data_write), .count_complete(count_complete), .clock(clock), .reset(aclr), .we(we));
	
	my_counter we_counter(.clk(clock), .en(we), .mode(counter_mode), .clr(aclr), .switch(count_complete));
	
	assign actual_fifo_we = we;
	
endmodule
