module enemy_ammo_rom (
	input logic clock,
	input logic [7:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:199] /* synthesis ram_init_file = "./enemy_ammo/enemy_ammo.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
