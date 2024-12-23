//-------------------------------------------------------------------------
//    EnemyLevel1.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//-------------------------------------------------------------------------


module  fix ( input Reset, frame_clk,
					input [5:0] level,
               output [9:0]  fixX, fixY,
					output flagfix
					);

 
	 //Variables for later use
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, width, height, flag1;
	 
	 //Boundaries of the monitor
    parameter [9:0] Ball_X_Min=5;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=6;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=460;     // Bottommost point on the Y axis
	 
	 //50x60 enemy
    assign width = 12;  
	 assign height = 25;
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Enemy
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Don't move fix
				Ball_X_Motion <= 10'd0; 
				Ball_Y_Pos <= 400; //Set the fix to be at its starting position
				Ball_X_Pos <= 5;
        end
		  else if(level == 6'b000001) //Reset the position of fix if we go back to the starting screen
		  begin
            Ball_Y_Motion <= 10'd0; //Don't move the fix
				Ball_X_Motion <= 10'd0; 
				Ball_Y_Pos <= 400; //Set the fix to be at its starting position
				Ball_X_Pos <= 5;
		  end
		  else if(level != 6'b000100)
		  begin
		      Ball_Y_Motion <= 10'd0; //Don't move the fix if we are not in the level that the fix should come out in
				Ball_X_Motion <= 10'd0; 
		  end
        else //Move the fix accordingly if we are in the level that the fix should come out in
        begin
			 case (level)
				6'b000100 : //Level 2, start moving right
						begin
							Ball_Y_Motion <= 0; 
							Ball_X_Motion <= 1;
							flag1 = 1'b1;
							if((Ball_X_Pos + width) >= Ball_X_Max)
								begin
								Ball_Y_Motion <= 0; 
								Ball_X_Motion <= 0;
								flag1 = 1'b0; //Don't draw fix 
								end
						 end	
				default: //Default, do not move the fix
						begin
							Ball_Y_Motion <= 0; 
							Ball_X_Motion <= 0;
							flag1 = 1'b0;
						end
			endcase
			 Ball_Y_Pos = Ball_Y_Pos + Ball_Y_Motion;  // Update ball position
			 Ball_X_Pos = Ball_X_Pos + Ball_X_Motion;	
		end
	end

assign fixX = Ball_X_Pos;
assign fixY = Ball_Y_Pos;
assign flagfix = flag1;
    

endmodule
