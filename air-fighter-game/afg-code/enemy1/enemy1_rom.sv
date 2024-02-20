module enemy1_rom (
	input logic clock,
	input logic [13:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:8999] /* synthesis ram_init_file = "./enemy1/enemy1.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
