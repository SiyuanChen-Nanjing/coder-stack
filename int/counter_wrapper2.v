module counter_wrapper2 (count_enable, block_size, clk, reset, count, target_reached);
	input count_enable;
	input block_size; // 0 for small and 1 for large
	input clk, reset;
	
	output [12:0] count;
	output target_reached;
	
	wire [12:0] target;
	//assign target = (block_size) ? (13'd6144) : (13'd1056);
	assign target = (block_size) ? (13'd6143) : (13'd1055); // one less than actual number
	
	wire [12:0] q, target_check;
	assign count = q;
	
	xor (target_check[0 ], target[0 ], q[0 ]);
	xor (target_check[1 ], target[1 ], q[1 ]);
	xor (target_check[2 ], target[2 ], q[2 ]);
	xor (target_check[3 ], target[3 ], q[3 ]);
	xor (target_check[4 ], target[4 ], q[4 ]);
	xor (target_check[5 ], target[5 ], q[5 ]);
	xor (target_check[6 ], target[6 ], q[6 ]);
	xor (target_check[7 ], target[7 ], q[7 ]);
	xor (target_check[8 ], target[8 ], q[8 ]);
	xor (target_check[9 ], target[9 ], q[9 ]);
	xor (target_check[10], target[10], q[10]);
	xor (target_check[11], target[11], q[11]);
	xor (target_check[12], target[12], q[12]);
	
	
	wire target_not_reached;
	or (target_not_reached, target_check[0 ], target_check[1 ], target_check[2 ], target_check[3 ],
	                        target_check[4 ], target_check[5 ], target_check[6 ], target_check[7 ],
									target_check[8 ], target_check[9 ], target_check[10], target_check[11],
									target_check[12]);
									
	not (target_reached, target_not_reached);
	
	//assign target_reached = (q==target)?1:0;
	wire enable;
	and (enable, count_enable, target_not_reached);
	
	counter2 counter2_inst (reset, enable, clk, q);
endmodule