//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk,
					input [7:0] keycode, keycode1, keycode2,
					input [5:0] level,
               output [9:0]  BallX, BallY, Ball_W, Ball_H,
					output [1:0] phase);
					
	//TAKING CENTER POINT AS X AND Y POSITION
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_X_final, Ball_Y_Pos, Ball_Y_Motion, width, height, Ball_X_Motion2, Ball_Y_Motion2, Ball_X_Motion3, Ball_Y_Motion3;
	 logic [1:0] p;
	 
    parameter [9:0] Ball_X_Center=220;  // Original position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=5;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=6;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=474;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
	 
    assign width = 20;  
	 assign height = 25;
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
            Ball_Y_Motion2 <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion2 <= 10'd0; //Ball_X_Step;
            Ball_Y_Motion3 <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion3 <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
		  else if(level == 6'b000001) //Reset the position of the jet if we are at the starting screen
		  begin
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
            Ball_Y_Motion2 <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion2 <= 10'd0; //Ball_X_Step;
            Ball_Y_Motion3 <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion3 <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center; //Reset jet position
				Ball_X_Pos <= Ball_X_Center;
			end
        else 
        begin
				begin
					 case (keycode)
						8'h04 : begin
									Ball_X_Motion <= -3;//A
									Ball_Y_Motion<= 0;
									if ( (Ball_X_Pos - width) <= Ball_X_Min )  // Ball is at the Left edge, hold!
									  begin
									  Ball_Y_Motion <= 0;  // 2's complement.
									  Ball_X_Motion <= 0;
									  end
								  end
								  
						8'h07 : begin
								  Ball_X_Motion <= 3;//D
								  Ball_Y_Motion <= 0;
								  if ( (Ball_X_Pos + width) >= Ball_X_Max )  // Ball is at the Right edge, hold!
									  begin
									  Ball_Y_Motion <= 0;  // 2's complement.
									  Ball_X_Motion <= 0;
									  end
								  end
						8'h16 : begin
								  Ball_Y_Motion <= 3;//S
								  Ball_X_Motion <= 0;
								  if ( (Ball_Y_Pos + height) >= Ball_Y_Max )  // Ball is at the bottom edge, hold!
									  begin
									  Ball_Y_Motion <= 0;  // 2's complement.
									  Ball_X_Motion <= 0;
									  end
								 end
						8'h1A : begin
								  Ball_Y_Motion <= -3;//W
								  Ball_X_Motion <= 0;
								  if ( (Ball_Y_Pos - height) <= Ball_Y_Min )  // Ball is at the top edge, hold!
									  begin
									  Ball_Y_Motion <= 0;  // 2's complement.
									  Ball_X_Motion <= 0;
									  end
								 end	  
						default: begin
									Ball_Y_Motion <= 0;  // 2's complement.
									Ball_X_Motion <= 0;
									end
					endcase
				 end
				begin
					 case (keycode1)
						8'h04 : begin
									Ball_X_Motion2 <=  -3;//A
									Ball_Y_Motion2 <= 0;
									if ( (Ball_X_Pos - width) <= Ball_X_Min )  // Ball is at the Left edge, hold!
									  begin
									  Ball_Y_Motion2 <= 0;  // 2's complement.
									  Ball_X_Motion2 <= 0;
									  end
								  end
								  
						8'h07 : begin
								  Ball_X_Motion2 <= 3;//D
								  Ball_Y_Motion2 <= 0;
								  if ( (Ball_X_Pos + width) >= Ball_X_Max )  // Ball is at the Right edge, hold!
									  begin
									  Ball_Y_Motion2 <= 0;  // 2's complement.
									  Ball_X_Motion2 <= 0;
									  end
								  end
						8'h16 : begin
								  Ball_Y_Motion2 <= 3;//S
								  Ball_X_Motion2 <= 0;
								  if ( (Ball_Y_Pos + height) >= Ball_Y_Max )  // Ball is at the bottom edge, hold!
									  begin
									  Ball_Y_Motion2 <= 0;  // 2's complement.
									  Ball_X_Motion2 <= 0;
									  end
								 end
						8'h1A : begin
								  Ball_Y_Motion2 <= -3;//W
								  Ball_X_Motion2 <= 0;
								  if ( (Ball_Y_Pos - height) <= Ball_Y_Min )  // Ball is at the top edge, hold!
									  begin
									  Ball_Y_Motion2 <= 0;  // 2's complement.
									  Ball_X_Motion2 <= 0;
									  end
								 end	  
						default: begin
									Ball_Y_Motion2 <= 0;  // 2's complement.
									Ball_X_Motion2 <= 0;
									end
					endcase
				 end
				begin
					 case (keycode2)
						8'h04 : begin
									Ball_X_Motion3 <=  -3;//A
									Ball_Y_Motion3 <= 0;
									if ( (Ball_X_Pos - width) <= Ball_X_Min )  // Ball is at the Left edge, hold!
									  begin
									  Ball_Y_Motion3 <= 0;  // 2's complement.
									  Ball_X_Motion3 <= 0;
									  end
								  end
								  
						8'h07 : begin
								  Ball_X_Motion3 <= 3;//D
								  Ball_Y_Motion3 <= 0;
								  if ( (Ball_X_Pos + width) >= Ball_X_Max )  // Ball is at the Right edge, hold!
									  begin
									  Ball_Y_Motion3 <= 0;  // 2's complement.
									  Ball_X_Motion3 <= 0;
									  end
								  end
						8'h16 : begin
								  Ball_Y_Motion3 <= 3;//S
								  Ball_X_Motion3 <= 0;
								  if ( (Ball_Y_Pos + height) >= Ball_Y_Max )  // Ball is at the bottom edge, hold!
									  begin
									  Ball_Y_Motion3 <= 0;  // 2's complement.
									  Ball_X_Motion3 <= 0;
									  end
								 end
						8'h1A : begin
								  Ball_Y_Motion3 <= -3;//W
								  Ball_X_Motion3 <= 0;
								  if ( (Ball_Y_Pos - height) <= Ball_Y_Min )  // Ball is at the top edge, hold!
									  begin
									  Ball_Y_Motion3 <= 0;  // 2's complement.
									  Ball_X_Motion3 <= 0;
									  end
								 end	  
						default: begin
									Ball_Y_Motion3 <= 0;  // 2's complement.
									Ball_X_Motion3 <= 0;
									end
					endcase
				 end

				 Ball_X_final = (Ball_X_Motion + Ball_X_Motion2 + Ball_X_Motion3);
				 Ball_Y_Pos = (Ball_Y_Pos + Ball_Y_Motion3 + Ball_Y_Motion2+ Ball_Y_Motion);  // Update ball position
				 Ball_X_Pos = (Ball_X_Pos + Ball_X_final);
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of Ball_Y_pos.  Will the new value of Ball_Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
      
			
		end  
    end
	 
    always_latch
		 begin
			if(Ball_X_final == 0)
				p = 2'b01;
			else if(Ball_X_final[9] ==1)
				p = 2'b10;
			else if(Ball_X_final[9] ==0)
				p = 2'b00;
		 end
	
	 assign phase = p;
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
	 
	 assign Ball_W = width;  
	 assign Ball_H = height;
    

endmodule
