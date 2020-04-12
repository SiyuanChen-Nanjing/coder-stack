module fsm(
	input aclr, clock, cbs_ready, int_ready, counter, tail_counter,
	output record_en, delay_ren, delay_wen, counter_en, close_switch, tail_en, tail_mode, enc_en, tail_counter_enable, ready, out_valid,
	output [2:0] state);

parameter INIT = 3'd0;
parameter RECORD = 3'd1;
parameter WAIT_INT = 3'd2;
parameter OPERATE = 3'd3;
parameter LAST_OPERATE = 3'd4;
parameter TAIL = 3'd5;
parameter WAIT_TAIL = 3'd6;
parameter LAST_TAIL = 3'd7;

reg [2:0] state_curr, state_next;

wire count_valid;
reg [2:0] count = 0;
always @(posedge clock) begin
	if (aclr) begin
		count = 0;
	end
	else if (state_curr == OPERATE & count < 5) begin
		count = count + 1;
	end
end
assign count_valid = count > 4;

assign state = state_curr;

assign record_en = state_curr == RECORD;
assign delay_wen = state_curr == RECORD | state_curr == WAIT_INT | state_curr == OPERATE | state_curr == LAST_OPERATE;
assign delay_ren = state_curr == OPERATE;
assign tail_en = state_curr == LAST_OPERATE;
assign counter_en = state_curr == OPERATE | state_curr == LAST_OPERATE;
assign close_switch = state_curr == LAST_OPERATE | state_curr == TAIL | state_curr == WAIT_TAIL;
assign tail_mode = state_curr == TAIL | state_curr == WAIT_TAIL | state_curr == LAST_TAIL;
assign enc_en = state_curr == OPERATE | state_curr == LAST_OPERATE | state_curr == TAIL | state_curr == WAIT_TAIL;
assign tail_counter_enable = state_curr == LAST_OPERATE | state_curr == TAIL | state_curr == WAIT_TAIL;
assign ready = state_curr == INIT;
//assign out_valid = ((state_curr == OPERATE) & count_valid) | state_curr == LAST_OPERATE | state_curr == TAIL | state_curr == WAIT_TAIL | state_curr == LAST_TAIL;
assign out_valid_reg_in = state_curr == OPERATE | state_curr == LAST_OPERATE | state_curr == TAIL | state_curr == WAIT_TAIL;
wire out_valid_reg_in;
reg out_valid_reg;
assign out_valid = out_valid_reg;
always @(posedge clock, posedge aclr) begin
	if (aclr) begin
		out_valid_reg <= 1'b0;
	end
	else begin
		out_valid_reg <= out_valid_reg_in;
	end
end


always @(posedge clock, posedge aclr) begin
	if (aclr) begin
		state_curr <= INIT;
	end
	else begin
		state_curr <= state_next;
	end
end

always @(state_curr, cbs_ready, int_ready, counter, tail_counter) begin
	case (state_curr)
		INIT: begin
			if (cbs_ready) begin
				state_next <= RECORD;
			end
			else begin
				state_next <= INIT;
			end
		end
		RECORD: begin
			state_next <= WAIT_INT;
		end
		WAIT_INT: begin
			if (int_ready) begin
				state_next <= OPERATE;
			end
			else begin
				state_next <= WAIT_INT;
			end
		end
		OPERATE: begin
			if (counter) begin
				state_next <= LAST_OPERATE;
			end
			else begin
				state_next <= OPERATE;
			end
		end
		LAST_OPERATE: begin
			state_next <= TAIL;
		end
		TAIL: begin
			state_next <= WAIT_TAIL;
		end
		WAIT_TAIL: begin
			if (tail_counter) begin
				state_next <= LAST_TAIL;
			end
			else begin
				state_next <= WAIT_TAIL;
			end
		end
		LAST_TAIL: begin
			state_next <= INIT;
		end
	endcase
end

endmodule 
