//-------------------------------------------------------------------------
//    Ammo.sv                                                            --
//-------------------------------------------------------------------------


module  ammo ( input Reset, frame_clk,
					input [7:0] keycode, keycode1, keycode2,
               input [9:0]  BallX, BallY, Ball_W, Ball_H,
					input logic jhit,
					output [9:0] AmmoX, AmmoY, Ammo_W, Ammo_H,
					output flag
				 );
    
	//Taking center bottom point of ammo as AmmoX and AmmoY
		
	//Variables for later use
	logic [9:0] Ammo_X_Pos, Ammo_X_Motion, Ammo_Y_Pos, Ammo_Y_Motion, width, height;
	logic [9:0] Ammo_X_Start;  // Start position on the X axis
	logic [9:0] Ammo_Y_Start;  // Start position on the Y axis
	assign Ammo_X_Start = BallX; //Set start position to be the tip of the enemy jet
	assign Ammo_Y_Start = BallY - Ball_H;
	logic flag1;

	//Y Bound of the monitor
	parameter [9:0] Ammo_Y_Min = 5;       // Topmost point on the Y axis
 
	//10x20 ammo
	assign width = 5;  
	assign height = 20;
   
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_Ammo
	  if (Reset)  // Asynchronous Reset
	  begin 
			Ammo_Y_Motion <= 10'd0; //Don't move the ammo
			Ammo_X_Motion <= 10'd0; 
			Ammo_Y_Pos <= Ammo_Y_Start; //Set the starting position of the ammo
			Ammo_X_Pos <= Ammo_X_Start;
			flag1 <= 1'b0; //Do not draw ammo
	  end
	  else if (flag1 == 1'b1) //Ammo is already shot, move it upwards and check boundary
	  begin
			Ammo_X_Motion <= 0; //Move the ammo upwards
			Ammo_Y_Motion <= -5; 
			if ( (Ammo_Y_Pos + Ammo_Y_Motion) <= Ammo_Y_Min || (jhit==1'b1) || (Ammo_Y_Pos) <= Ammo_Y_Min)//If the ammo position exceeds the top boundary
				begin
				Ammo_Y_Motion <= 0;  //Don't move the ammo
				Ammo_X_Motion <= 0;
				Ammo_Y_Pos <= Ammo_Y_Start; //Update ammo position
				Ammo_X_Pos <= Ammo_X_Start;
				flag1 <= 1'b0; //Do not draw ammo
				end
			else
				begin
				Ammo_Y_Pos <= (Ammo_Y_Pos + Ammo_Y_Motion); //Update ammo position
				Ammo_X_Pos <= (Ammo_X_Pos + Ammo_X_Motion);
				end
	  end
	  else if(flag1== 1'b0) //If we aren't drawing ammo
	  begin
			if(keycode == 8'h2c || keycode1 == 8'h2c || keycode2 == 8'h2c) //If we press space/fire the ammo
			begin
				Ammo_X_Motion <= 0; //Move the ammo upwards
				Ammo_Y_Motion <= -5; 
				Ammo_Y_Pos <= Ammo_Y_Start; //Reset the ammo to its start position at the tip of the jet
				Ammo_X_Pos <= Ammo_X_Start;
				flag1 <= 1'b1; //Draw the ammo
			end
		end
	end

	
	//Assign output values
	assign AmmoX = Ammo_X_Pos;
	assign AmmoY = Ammo_Y_Pos;
	assign Ammo_W = width;  
	assign Ammo_H = height;
	assign flag = flag1;
    

endmodule
