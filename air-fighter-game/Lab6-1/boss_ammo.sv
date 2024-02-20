//-------------------------------------------------------------------------
//    Ammo.sv                                                            --
//-------------------------------------------------------------------------


module  boss_ammo ( input Reset, frame_clk,
					input [5:0] level,
					input hit,
               input [9:0]  BallX, BallY, Ball_W, Ball_H,  Ammo_X_Start, Ammo_Y_Start,
					input [9:0] jetX, jetY,
					output [9:0] AmmoX, AmmoY,
					output flag
				 );
    
	//Taking center bottom point of ammo as AmmoX and AmmoY
	
	//Variables for later use
	logic [9:0] Ammo_X_Pos, Ammo_X_Motion, Ammo_Y_Pos, Ammo_Y_Motion;
//	logic [9:0] Ammo_X_Start;  // Start position on the X axis
//	logic [9:0] Ammo_Y_Start;  // Start position on the Y axis
//	assign Ammo_X_Start = BallX;
//	assign Ammo_Y_Start = BallY + Ball_H;
	logic flag1, ready;
	int distX, distY;
	
	assign distX = jetX-Ammo_X_Pos;
	assign distY = jetY-Ammo_Y_Pos;

	//Y Bottom Bound of Monitor 
	parameter [9:0] Ammo_Y_Max=472;     // Bottommost point on the Y axis	
	parameter [9:0] Ammo_X_Max=637; 
	parameter [9:0] Ammo_X_Min=3; 	
   
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_Ammo
	  if (Reset)  // Asynchronous Reset
	  begin 
			Ammo_Y_Motion <= 10'd0; //Do not move ammo
			Ammo_X_Motion <= 10'd0; 
			Ammo_Y_Pos = Ammo_Y_Start; //Set ammo start position
			Ammo_X_Pos = Ammo_X_Start;
			ready <= 1'b0; //Ammo not yet fired
			flag1 <= 1'b0; //Do not draw ammo
	  end
	  else if(level != 6'b001000)
	  begin
			Ammo_Y_Motion <= 10'd0; //Don't move the ammo if we are not in the level that the ammo should come out in
			Ammo_X_Motion <= 10'd0; 
			flag1 <= 1'b0; //Do not draw ammo
			ready <= 1'b0;
			Ammo_Y_Pos = Ammo_Y_Start; //Set ammo start position
			Ammo_X_Pos = Ammo_X_Start;
	  end
	  else if ((level == 6'b001000))// We should draw the ammo
	  begin 
			if(ready == 1'b0) //Ammo is ready to get fired
				begin
//					if(BallY <= 79)
//						begin
//				Ammo_Y_Pos = Ammo_Y_Start; //Set ammo start position
//				Ammo_X_Pos = Ammo_X_Start
//						end
//					else
//						begin
						Ammo_X_Motion <= distX/50; //Set ammo to go towards the jet
						Ammo_Y_Motion <= distY/50;
						ready <= 1'b1;
//						end
				end
			else 
				begin
					flag1 <= 1'b1; //Draw the ammo
					if ( (Ammo_Y_Pos + Ammo_Y_Motion) >= Ammo_Y_Max || hit == 1'b1 || (Ammo_X_Pos + Ammo_X_Motion) >= Ammo_X_Max || (Ammo_X_Pos + Ammo_X_Motion) <= Ammo_X_Min) //If the ammo goes out of bounds or hits the jet
						begin
						Ammo_Y_Pos <= Ammo_Y_Start; //Reset to the tip of the enemy jet
						Ammo_X_Pos <= Ammo_X_Start;
						ready <= 1'b0;
						end
					else //If the ammo is still within y bounds
						begin
						Ammo_Y_Pos <= (Ammo_Y_Pos + Ammo_Y_Motion); //Keep moving the ammo downwards
						Ammo_X_Pos <= (Ammo_X_Pos + Ammo_X_Motion);
						end 
					Ammo_X_Motion <=Ammo_X_Motion;
					Ammo_Y_Motion <=Ammo_Y_Motion;
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
