//-------------------------------------------------------------------------
//    Ammo.sv                                                            --
//-------------------------------------------------------------------------


module  enemy_ammo ( input Reset, frame_clk,
					input [5:0] level,
					input hit,
					input [5:0] ammolevel,
               input [9:0]  BallX, BallY, Ball_W, Ball_H,
					output [9:0] AmmoX, AmmoY,
					output flag
				 );
    
	//Taking center bottom point of ammo as AmmoX and AmmoY
	
	//Variables for later use
	logic [9:0] Ammo_X_Pos, Ammo_X_Motion, Ammo_Y_Pos, Ammo_Y_Motion;
	logic [9:0] Ammo_X_Start;  // Start position on the X axis
	logic [9:0] Ammo_Y_Start;  // Start position on the Y axis
	assign Ammo_X_Start = BallX;
	assign Ammo_Y_Start = BallY + Ball_H;
	logic flag1;

	//Y Bottom Bound of Monitor 
	parameter [9:0] Ammo_Y_Max=472;     // Bottommost point on the Y axis	 
   
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_Ammo
	  if (Reset)  // Asynchronous Reset
	  begin 
			Ammo_Y_Motion <= 10'd0; //Do not move ammo
			Ammo_X_Motion <= 10'd0; 
			Ammo_Y_Pos <= Ammo_Y_Start; //Set ammo start position
			Ammo_X_Pos <= Ammo_X_Start;
			flag1 <= 1'b0; //Do not draw ammo
	  end
	  else if(level != ammolevel)
	  begin
			Ammo_Y_Motion <= 10'd0; //Don't move the ammo if we are not in the level that the ammo should come out in
			Ammo_X_Motion <= 10'd0; 
			flag1 <= 1'b0; //Do not draw ammo
	  end
	  else if ((level == 6'b000010) || (level == 6'b000100))// We should draw the ammo
	  begin
			Ammo_X_Motion <= 0; //Move the ammo downwards
			Ammo_Y_Motion <= 8;
			flag1 <= 1'b1; //Draw the ammo
			if ( (Ammo_Y_Pos + Ammo_Y_Motion) >= Ammo_Y_Max || hit == 1'b1) //If the ammo goes out of bounds
				begin
				Ammo_Y_Pos <= Ammo_Y_Start; //Reset to the tip of the enemy jet
				Ammo_X_Pos <= Ammo_X_Start;
				end
			else //If the ammo is still within y bounds
				begin
				Ammo_Y_Pos <= (Ammo_Y_Pos + Ammo_Y_Motion); //Keep moving the ammo downwards
				Ammo_X_Pos <= (Ammo_X_Pos + Ammo_X_Motion);
				end 
	  end
	  else //If we are not in levels 1, 2, or 3
	  begin
			flag1 <= 1'b0;
		end
	end
	
	//Assign output values
	assign AmmoX = Ammo_X_Pos;
	assign AmmoY = Ammo_Y_Pos;
	assign flag = flag1;
    
endmodule
