module boss_am_rom (
	input logic clock,
	input logic [11:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:2499] /* synthesis ram_init_file = "./boss_am/boss_am.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
