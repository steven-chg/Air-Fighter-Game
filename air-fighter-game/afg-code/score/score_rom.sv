module score_rom (
	input logic clock,
	input logic [13:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:9599] /* synthesis ram_init_file = "./score/score.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
