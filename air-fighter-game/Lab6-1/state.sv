//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									health,
					 input logic [2:0] cont,
					input logic [7:0] keycode,
				output logic [2:0] level,
				output logic health_new
				);

	enum logic [3:0] {Start, level1, level2, level3, End, Gameover}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Start;
		else if(health==0)
			State <= Gameover;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		start = 0;
		level = 0;
	
		// Assign next state
		unique case (State)
			Start : 
				if (keycode == 8'h28) 
					Next_state = level1; 
			level1 : 
				if (cont == 3'b001) 
					Next_state = level2; 
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			level2 : 
				if (cont== 3'b010) 
					Next_state = level3; 
			level3 : 
				if (cont== 3'b100) 
					Next_state = End; 
			End : 
				if (keycode == 8'h28) 
					Next_state = Start; 
			Gameover : 
				if (keycode == 8'h28) 
					Next_state = Start;
			default : ;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Start: level = 3'b000;
			level1 

			level2 : 
			level3 :
			End : 

			Gameover : 

			default : ;
		endcase
	end 

	
endmodule
