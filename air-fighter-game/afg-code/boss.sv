//-------------------------------------------------------------------------
//    EnemyLevel1.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//-------------------------------------------------------------------------


module  boss ( input Reset, frame_clk,
					input [5:0] level,
					input [9:0] Enemy_X_Original, Enemy_Y_Original, 
               output [9:0]  EnemyX, EnemyY
					);
					
	 //LEVEL TO DECIDE IF ENEMY WILL SHIFT LEFT AND RIGHT IN MOTION
	 //PHASE TO DETERMINE LEFT AND RIGHT TILT OF IMAGE
	 //WILL CALL THIS MODULE MULTIPLE TIMES TO INSTANTIATE MULTIPLE ENEMIES 
	 //EACH ENEMY'S ORIGINAL POSITIONS WILL BE CALCULATED IN THE COLOR_MAPPER MODULE
	 //TAKING CENTER POINT OF ENEMY AS X AND Y
	 
	 //Variables for later use
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, width, height;
	 
	 //Boundaries of the monitor
    parameter [9:0] Ball_X_Min=5;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=6;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=200;     // Bottommost point on the Y axis
	 
	 //50x60 enemy
    assign width = 120;  
	 assign height = 90;
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Enemy
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Don't move the jet
				Ball_X_Motion <= 10'd0; 
				Ball_Y_Pos <= Enemy_Y_Original; //Set the jet to be at its starting position
				Ball_X_Pos <= Enemy_X_Original;
        end
		  else if(level == 6'b000001) //Reset the position of the jet if we go back to the starting screen
		  begin
            Ball_Y_Motion <= 10'd0; //Don't move the jet
				Ball_X_Motion <= 10'd0; 
				Ball_Y_Pos <= Enemy_Y_Original; //Reset the jet to be at its starting position
				Ball_X_Pos <= Enemy_X_Original;
		  end
		  else if(level != 6'b001000)
		  begin
		      Ball_Y_Motion <= 10'd0; //Don't move the jet if we are not in the level that the jet should come out in
				Ball_X_Motion <= 10'd0; 
		  end
        else //Move the jet accordingly if we are in the level that the jet should come out in
        begin
			 case (level)
				6'b001000 : //Level 2, come down to the right y position and shift left and right on the screen
						begin
							if ( Ball_Y_Pos <= 80) //If we are not yet at the target y position, move the jet downwards
								begin
								Ball_X_Motion <= 0; 
								Ball_Y_Motion<= 1; //Go down to target Y 
								end
							else //If we have reached the target y position, shift left and right
								begin
									if(Ball_X_Motion ==0) //If jet just arrived at target y position, move it right
										begin
										Ball_X_Motion <= 2; //Go right
										Ball_Y_Motion<= 0;
										end
									else if ( (Ball_X_Pos + width) >= Ball_X_Max )  // Ball is at the Right edge, bounce!
										  begin
										  Ball_Y_Motion <= 0;  
										  Ball_X_Motion <= -2; //Go left
										  end
									else if ( (Ball_X_Pos - width) <= Ball_X_Min )  // Ball is at the Left edge, bounce!
										  begin
										  Ball_Y_Motion <= 0;  
										  Ball_X_Motion <= 2; //Go right
										  end
									else
										begin
										Ball_Y_Motion <= Ball_Y_Motion;  // 2's complement.
										Ball_X_Motion <= Ball_X_Motion;
										end
								end
						end
				default: //Default, do not move the jet
						begin
							Ball_Y_Motion <= 0; 
							Ball_X_Motion <= 0;
						end
			endcase
			 Ball_Y_Pos = Ball_Y_Pos + Ball_Y_Motion;  // Update ball position
			 Ball_X_Pos = Ball_X_Pos + Ball_X_Motion;	
		end
	end

//Determine the phase of the plane to determine left, right, or no tilt in the image


		 
//Assign outputs 

assign EnemyX = Ball_X_Pos;
assign EnemyY = Ball_Y_Pos;
    

endmodule
