//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] BallX, BallY, AmmoX, AmmoY, DrawX, DrawY, Ball_W, Ball_H, Ammo_W, Ammo_H,
								input [9:0] Enemy11X, Enemy11Y, Enemy21X, Enemy21Y, Enem_W, Enem_H, e11_AmmoX, e11_AmmoY, e21_AmmoX, e21_AmmoY, e_Ammo_W, e_Ammo_H, 
								input [9:0] Enemy12X, Enemy12Y, Enemy13X, Enemy13Y, e12_AmmoX, e12_AmmoY, e13_AmmoX, e13_AmmoY, 
								input [9:0] Enemy22X, Enemy22Y, Enemy23X, Enemy23Y, e22_AmmoX, e22_AmmoY, e23_AmmoX, e23_AmmoY, 
								input [9:0] bossX, bossY, boss_AmmoY, boss_AmmoX, boss_AmmoY2, boss_AmmoX2, boss_AmmoY3, boss_AmmoX3,
								input [9:0] fixX, fixY,
								input logic flag, e11_flag, e12_flag, e13_flag, e21_flag, e22_flag, e23_flag, boss_flag, boss_flag2, boss_flag3, flagfix,
								input [1:0] phase,
								input [1:0] p11, p12, p13, p21, p22, p23,
							   input logic vga_clk, blank, frame_clk, reset,
								input logic [7:0] keycode, keycode1, keycode2,
                       output logic [3:0]  Red, Green, Blue,
							  output logic [5:0] current_level,
							  output logic hit_11, hit_12, hit_13, hit_21, hit_22, hit_23, hit_boss, hit_boss2, hit_boss3,
							  output logic jhit);
						
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////LEVELS/////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
logic [5:0] nextlevel;
logic [5:0] level;
assign current_level = level;


//Initialize these flags to 0 temporarily
logic level1end = 1'b0;
logic level2end = 1'b0;
logic level3end = 1'b0;
logic [2:0] damage;
logic [2:0] score;

always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset)
		level = 6'b000001; //Go to the start screen
	else 
		level <= nextlevel;
end

always_comb
begin
	nextlevel = level;
	case(level)
		6'b000001: //Start Screen
			begin
			if(keycode == 8'h28 || keycode1 == 8'h28 || keycode2 == 8'h28)
				nextlevel = 6'b000010;
			else
				nextlevel = 6'b000001;
			end
		6'b000010: //Level 1
			begin
				if(damage == 3'b011 || damage == 3'b100) //If we get hit 3 times, go to game over screen
					nextlevel = 6'b010000;
				else if(hite11 && hite12 && hite13) //Testing
					nextlevel = 6'b000100;
				else
					nextlevel = 6'b000010;
			end
		6'b000100: //Level 2
			begin
				if(damage == 3'b011 || damage == 3'b100) //If we get hit 3 times, go to game over screen
					nextlevel = 6'b010000;
				else if(hite21 && hite22 && hite23)
					nextlevel = 6'b001000;
				else
					nextlevel = 6'b000100;
			end
		6'b001000: //Level 3
			begin
				if(damage == 3'b011 || damage == 3'b100) //If we get hit 3 times, go to game over screen
					nextlevel = 6'b010000;
				else if((damage_boss == 15 || damage_boss==16))
					nextlevel = 6'b010000;
				else
					nextlevel = 6'b001000;
			end
		6'b010000: //Gameover/Dead Screen (Option to Go Back to start screen on press of enter)
			begin
			if(keycode == 8'h28 || keycode1 == 8'h28 || keycode2 == 8'h28)
				nextlevel = 6'b111111; //Go to an intermediate level and wait for release of enter 
				
			else
				nextlevel = 6'b010000;
			end
//		6'b100000: //Mission Complete/End Screen (Option to Go Back to start screen on press of enter)
//			begin
//			if(keycode == 8'h28 || keycode1 == 8'h28 || keycode2 == 8'h28)
//				nextlevel = 6'b111111; //Go to an intermediate level and wait for release of enter
//			else
//				nextlevel = 6'b100000;
//			end
		6'b111111:
			if(keycode != 8'h28 && keycode1 != 8'h28 && keycode2 != 8'h28)
				nextlevel = 6'b000001;
		default: ;
	endcase 
end
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////BACKGROUND/////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
		logic [3:0] background = 4'b0000;
		logic [3:0] bgd_r, bgd_g, bgd_b;
		logic start=0;
		logic endd = 0;
		logic [3:0] bgd1_r, bgd1_g, bgd1_b, bgd2_r, bgd2_g, bgd2_b, bgds_r, bgds_g, bgds_b, finalscore_red, finalscore_green, finalscore_blue;
		logic [3:0] bgdgo_r, bgdgo_g, bgdgo_b, bgdmc_r, bgdmc_g, bgdmc_b;
		logic [18:0] rom_address_bgd1, rom_address_bgd2, rom_address_start, rom_address_finalscore;
		logic [18:0] rom_address_bgdgo, rom_address_bgdmc;
		logic [3:0] rom_q_bgd1, rom_q_bgd2, rom_q_start, rom_q_finalscore;
		logic [3:0] rom_q_bgdgo, rom_q_bgdmc;
	

		assign rom_address_bgd1 = DrawX/3 + DrawY/3*240;
		assign rom_address_bgd2 = DrawX/4 + DrawY/4*160;
		assign rom_address_bgdgo = DrawX/3 + DrawY/3*213;
		assign rom_address_start = DrawX[9:1] + DrawY[9:1]*320;

always_ff @ (posedge frame_clk or posedge reset)
begin: Background
	if (reset)
		begin
		background = 4'b0000; //Start Screen
		start = 1'b0; //Game hasn't started yet
		endd = 1'b0; //Game hasn't ended yet 
		end
	else if(level == 6'b000001) //Reset everytime we go back to the start screen 
		begin
		start = 1'b0; //Reset start to 0 at start screen
		background = 4'b0000; //Set background to start screen
		endd = 1'b0; //Reset endd flag to 0 at start screen
		end
	else if(level == 6'b111111) //Intermediate level, set background to the start screen
		background = 4'b0000;
	else if(level == 6'b010000) //Game over/Died
	  begin
		  background = 4'b0100; //Game Over Screen
		  endd = 1'b1; //Set endd to 1 
	  end
//	else if(level == 6'b100000) //Mission end/Game finished
//	  begin
//		  background = 4'b1000; // Mission End Screen
//		  endd = 1'b1; //Set endd to 1
//	  end
	else
	begin
    case (keycode)
        8'h28 : //Enter
				begin
					background = 4'b0001; //Go to default first background
					start = 1'b1;
				end
        8'h1E : //1
            background = 4'b0001; //Switch to background 1
        8'h17 : //T
				begin
				if(keycode1 == 8'h1c || keycode2 == 8'h1c)
					background = 4'b0010; //Switch to background 2
				else
					background = background;
				end
        default: 
            if(start != 1'b1)
					begin
                background = 4'b0000; //Stay on start screen
					end
    endcase
    case (keycode1)
        8'h28 : //Enter
				begin
					background = 4'b0001; //Go to default first background
					start = 1'b1;
				end
        8'h1E : //1
            background = 4'b0001; //Switch to background 1
        8'h17 : //T
				begin
				if(keycode == 8'h1c || keycode2 == 8'h1c)
					background = 4'b0010; //Switch to background 2
				else
					background = background;
				end
        default: 
            if(start != 1'b1)
					begin
                background = 4'b0000; //Stay on start screen
					end
    endcase
    case (keycode2)
        8'h28 : //Enter
				begin
					background = 4'b0001; //Go to default first background
					start = 1'b1;
				end
        8'h1E : //1
            background = 4'b0001; //Switch to background 1
        8'h17 : //T
				begin
				if(keycode1 == 8'h1c || keycode == 8'h1c)
					background = 4'b0010; //Switch to background 2
				else
					background = background;
				end
        default: 
            if(start != 1'b1)
					begin
                background = 4'b0000; //Stay on start screen
					end
    endcase 
	end
end

always_latch
    begin: Background_RGB
        if (background == 4'b0001) //Background 1
        begin
            bgd_r = bgd1_r;
            bgd_g = bgd1_g;
            bgd_b = bgd1_b;
        end
        else if (background == 4'b0010) //Background 2
        begin
            bgd_r = bgd2_r;
            bgd_g = bgd2_g;
            bgd_b = bgd2_b;
        end
        else if (background == 4'b0100) //Game Over Screen
        begin
            bgd_r = bgdgo_r;
            bgd_g = bgdgo_g;
            bgd_b = bgdgo_b;
        end
//        else if (background == 4'b1000) //Mission Complete Screen
//        begin
//            bgd_r = bgdmc_r;
//            bgd_g = bgdmc_g;
//            bgd_b = bgdmc_b;
//        end
        else if (background == 4'b0000) //Start Screen
        begin
            bgd_r = bgds_r;
            bgd_g = bgds_g;
            bgd_b = bgds_b;
        end
    end
	
	
//Background 2	

bgd3_rom bgd3_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_bgd2),
	.q       (rom_q_bgd2)
);

bgd3_palette bgd3_palette (
	.index (rom_q_bgd2),
	.red   (bgd2_r),
	.green (bgd2_g),
	.blue  (bgd2_b)
);

//Background 1

bgd1_rom bgd1_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_bgd1),
	.q       (rom_q_bgd1)
);

bgd1_palette bgd1_palette (
	.index (rom_q_bgd1),
	.red   (bgd1_r),
	.green (bgd1_g),
	.blue  (bgd1_b)
);

//Start Screen

start_rom start_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_start),
	.q       (rom_q_start)
);

start_palette start_palette (
	.index (rom_q_start),
	.red   (bgds_r),
	.green (bgds_g),
	.blue  (bgds_b)
);

//Game Over Screen

gameover_rom gameover_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_bgdgo),
	.q       (rom_q_bgdgo)
);

gameover_palette gameover_palette (
	.index (rom_q_bgdgo),
	.red   (bgdgo_r),
	.green (bgdgo_g),
	.blue  (bgdgo_b)
);

//Final Score

result_rom result_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_finalscore),
	.q       (rom_q_finalscore)
);

result_palette result_palette (
	.index (rom_q_finalscore),
	.red   (finalscore_red),
	.green (finalscore_green),
	.blue  (finalscore_blue)
);

//Mission Complete Screen

//end_rom end_rom (
//	.clock   (negedge_vga_clk),
//	.address (rom_address_bgdmc),
//	.q       (rom_q_bgdmc)
//);
//
//end_palette end_palette (
//	.index (rom_q_bgdmc),
//	.red   (bgdmc_r),
//	.green (bgdmc_g),
//	.blue  (bgdmc_b)
//);

	

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////Level 1 Enemy and Ammo/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

//1-1

		logic enemy11on, e11_ammo_on;
		logic [3:0] e11_ammo_red, e11_ammo_green, e11_ammo_blue;
 		
		int enemy11_DistX, enemy11_DistY, enemy11_width, enemy11_height;
		assign enemy11_width = Enem_W;
		assign enemy11_height = Enem_H;
		assign enemy11_DistX = DrawX - Enemy11X;
		assign enemy11_DistY = DrawY - Enemy11Y;
		
		//Rom Address of Enemy 1-1 and its Ammo
		logic [18:0] rom_address_enem11, rom_address_e11_ammo;
		assign rom_address_enem11 = (DrawX - (Enemy11X-enemy11_width)) + (DrawY - (Enemy11Y-enemy11_height))* 50 + (50*58*p11);
		assign rom_address_e11_ammo = ((DrawX - (e11_AmmoX - e_Ammo_W)) + (DrawY - (e11_AmmoY - e_Ammo_H))*10);
		logic [3:0] rom_q_enem11, rom_q_e11_ammo;
		logic [3:0] enem11_red, enem11_green, enem11_blue;
		
		//Conditions to check if we are drawing enemy 1-1
		always_comb
		begin: enem11_on_proc
		  if ( (enemy11_DistX >= -enemy11_width) && (enemy11_DistX <= enemy11_width) && (enemy11_DistY >= -enemy11_height) && (enemy11_DistY <= enemy11_height))	
				enemy11on = 1'b1;
		  else 
				enemy11on = 1'b0;
		end 
	  
		logic e11;
	  	assign e11 = ((enemy11on == 1'b1) && (enem11_red != 4'ha || enem11_green != 4'h4 || enem11_blue != 4'ha) && (level == 6'b000010) && ~hite11);

		//Conditions to check if we are drawing enemy 1-1 ammo
		always_comb
		 begin:e11_ammo_on_proc
			  if ((DrawX <= (e11_AmmoX + e_Ammo_W)) && (DrawX >= (e11_AmmoX - e_Ammo_W)) && (DrawY >= (e11_AmmoY- e_Ammo_H)) && (DrawY <= (e11_AmmoY)))
					e11_ammo_on = 1'b1;
			  else 
					e11_ammo_on = 1'b0;
		 end 
		
		logic e11_am;
	  	assign e11_am = ((e11_ammo_on == 1'b1) && (e11_ammo_red != 4'ha || e11_ammo_green != 4'h4 || e11_ammo_blue != 4'ha)) && e11_flag && ~hit11 && ~hite11; 
		
		//Enemy 1-1 Explosion
		logic [3:0] explosion11_r, explosion11_g, explosion11_b;
		logic explosion11on;
		logic [18:0] rom_address_exp11;
		logic [3:0] rom_q_exp11;
		assign rom_address_exp11 = (DrawX - (Enemy11X-enemy11_width)) + (DrawY - (Enemy11Y-enemy11_height))* 50 + (50*58*animation11);
		logic explode11 = 1'b0;
		logic animation11;
		logic startexp11 = 1'b0;
		logic [2:0] counter11 = 3'b000;

		
		//Conditions to check if we are drawing enemy 1-1 explosion
		always_comb
		begin: enem11explosion_on_proc
		  if ( (enemy11_DistX >= -enemy11_width) && (enemy11_DistX <= enemy11_width) && (enemy11_DistY >= -enemy11_height) && (enemy11_DistY <= enemy11_height))	
				explosion11on = 1'b1;
		  else 
				explosion11on = 1'b0;
		end 
	  
		logic exp11;
	  	assign exp11 = ((explosion11on == 1'b1) && (explosion11_r != 4'h0 || explosion11_g != 4'h1 || explosion11_b != 4'h3) && explode11);
		
		
always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset) //Reset counter
		counter11 = 3'b000;
	else if(hite11 == 1'b0)
		begin
		startexp11 = 1'b0;
		explode11 = 1'b0;
		end
	else if(hite11 == 1'b1 && startexp11 == 1'b0) //Jet 1-1 is hit
		begin
		explode11 = 1'b1;
		animation11 = 1'b0;
		startexp11 = 1'b1;
		counter11 = 3'b000;
		end
	else if(counter11 == 3'b101 && animation11 == 1'b0)
		begin
		animation11 = 1'b1;
		counter11 = 3'b000;
		end
	else if(counter11 == 3'b101 && animation11 == 1'b1)
		begin
		explode11 = 1'b0;
		end
	else
		counter11 = counter11 + 3'b001;
end
		
explosion_rom explosion1_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_exp11),
	.q       (rom_q_exp11)
);

explosion_palette explosion1_palette (
	.index (rom_q_exp11),
	.red   (explosion11_r),
	.green (explosion11_g),
	.blue  (explosion11_b)
);
		
enemy1_rom enemy11_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_enem11),
	.q       (rom_q_enem11)
);

enemy1_palette enemy11_palette (
	.index (rom_q_enem11),
	.red   (enem11_red),
	.green (enem11_green),
	.blue  (enem11_blue)
);

enemy_ammo_rom enemy11_ammo_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_e11_ammo),
	.q       (rom_q_e11_ammo)
);

enemy_ammo_palette enemy11_ammo_palette (
	.index (rom_q_e11_ammo),
	.red   (e11_ammo_red),
	.green (e11_ammo_green),
	.blue  (e11_ammo_blue)
);	

//1-2

		logic enemy12on, e12_ammo_on;
		logic [3:0] e12_ammo_red, e12_ammo_green, e12_ammo_blue;
 		
		int enemy12_DistX, enemy12_DistY, enemy12_width, enemy12_height;
		assign enemy12_width = Enem_W;
		assign enemy12_height = Enem_H;
		assign enemy12_DistX = DrawX - Enemy12X;
		assign enemy12_DistY = DrawY - Enemy12Y;
		
		//Rom Address of Enemy 1-2 and its Ammo
		logic [18:0] rom_address_enem12, rom_address_e12_ammo;
		assign rom_address_enem12 = (DrawX - (Enemy12X-enemy12_width)) + (DrawY - (Enemy12Y-enemy12_height))* 50 + (50*58*p12);
		assign rom_address_e12_ammo = ((DrawX - (e12_AmmoX - e_Ammo_W)) + (DrawY - (e12_AmmoY - e_Ammo_H))*10);
		logic [3:0] rom_q_enem12, rom_q_e12_ammo;
		logic [3:0] enem12_red, enem12_green, enem12_blue;

		
		//Conditions to check if we are drawing enemy 1-2
		always_comb
		begin: enem12_on_proc
		  if ( (enemy12_DistX >= -enemy12_width) && (enemy12_DistX <= enemy12_width) && (enemy12_DistY >= -enemy12_height) && (enemy12_DistY <= enemy12_height))	
				enemy12on = 1'b1;
		  else 
				enemy12on = 1'b0;
		end 
	  
		logic e12;
	  	assign e12 = ((enemy12on == 1'b1) && (enem12_red != 4'ha || enem12_green != 4'h4 || enem12_blue != 4'ha) && (level == 6'b000010) && ~hite12);

		//Conditions to check if we are drawing enemy 1-2 ammo
		always_comb
		 begin:e12_ammo_on_proc
			  if ((DrawX <= (e12_AmmoX + e_Ammo_W)) && (DrawX >= (e12_AmmoX - e_Ammo_W)) && (DrawY >= (e12_AmmoY- e_Ammo_H)) && (DrawY <= (e12_AmmoY)))
					e12_ammo_on = 1'b1;
			  else 
					e12_ammo_on = 1'b0;
		 end 
		
		logic e12_am;
	  	assign e12_am = ((e12_ammo_on == 1'b1) && (e12_ammo_red != 4'ha || e12_ammo_green != 4'h4 || e12_ammo_blue != 4'ha)) && e12_flag && ~hit12 && ~hite12; 

		//Enemy 1-2 Explosion
		logic [3:0] explosion12_r, explosion12_g, explosion12_b;
		logic explosion12on;
		logic [18:0] rom_address_exp12;
		logic [3:0] rom_q_exp12;
		assign rom_address_exp12 = (DrawX - (Enemy12X-enemy12_width)) + (DrawY - (Enemy12Y-enemy12_height))* 50 + (50*58*animation12);
		logic explode12 = 1'b0;
		logic animation12;
		logic startexp12 = 1'b0;
		logic [2:0] counter12 = 3'b000;

		
		//Conditions to check if we are drawing enemy 1-2 explosion
		always_comb
		begin: enem12explosion_on_proc
		  if ( (enemy12_DistX >= -enemy12_width) && (enemy12_DistX <= enemy12_width) && (enemy12_DistY >= -enemy12_height) && (enemy12_DistY <= enemy12_height))	
				explosion12on = 1'b1;
		  else 
				explosion12on = 1'b0;
		end 
	  
		logic exp12;
	  	assign exp12 = ((explosion12on == 1'b1) && (explosion12_r != 4'h0 || explosion12_g != 4'h1 || explosion12_b != 4'h3) && explode12);
		
		
always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset) //Reset counter
		counter12 = 3'b000;
	else if(hite12 == 1'b0)
		begin
		startexp12 = 1'b0;
		explode12 = 1'b0;
		end
	else if(hite12 == 1'b1 && startexp12 == 1'b0) //Jet 1-2 is hit
		begin
		explode12 = 1'b1;
		animation12 = 1'b0;
		startexp12 = 1'b1;
		counter12 = 3'b000;
		end
	else if(counter12 == 3'b101 && animation12 == 1'b0)
		begin
		animation12 = 1'b1;
		counter12 = 3'b000;
		end
	else if(counter12 == 3'b101 && animation12 == 1'b1)
		begin
		explode12 = 1'b0;
		end
	else
		counter12 = counter12 + 3'b001;
end
		
explosion_rom explosion12_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_exp12),
	.q       (rom_q_exp12)
);

explosion_palette explosion12_palette (
	.index (rom_q_exp12),
	.red   (explosion12_r),
	.green (explosion12_g),
	.blue  (explosion12_b)
);
		
		
enemy1_rom enemy12_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_enem12),
	.q       (rom_q_enem12)
);

enemy1_palette enemy12_palette (
	.index (rom_q_enem12),
	.red   (enem12_red),
	.green (enem12_green),
	.blue  (enem12_blue)
);

enemy_ammo_rom enemy12_ammo_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_e12_ammo),
	.q       (rom_q_e12_ammo)
);

enemy_ammo_palette enemy12_ammo_palette (
	.index (rom_q_e12_ammo),
	.red   (e12_ammo_red),
	.green (e12_ammo_green),
	.blue  (e12_ammo_blue)
);	

//1-3

		logic enemy13on, e13_ammo_on;
		logic [3:0] e13_ammo_red, e13_ammo_green, e13_ammo_blue;
 		
		int enemy13_DistX, enemy13_DistY, enemy13_width, enemy13_height;
		assign enemy13_width = Enem_W;
		assign enemy13_height = Enem_H;
		assign enemy13_DistX = DrawX - Enemy13X;
		assign enemy13_DistY = DrawY - Enemy13Y;
		
		//Rom Address of Enemy 1-3 and its Ammo
		logic [18:0] rom_address_enem13, rom_address_e13_ammo;
		assign rom_address_enem13 = (DrawX - (Enemy13X-enemy13_width)) + (DrawY - (Enemy13Y-enemy13_height))* 50 + (50*58*p13);
		assign rom_address_e13_ammo = ((DrawX - (e13_AmmoX - e_Ammo_W)) + (DrawY - (e13_AmmoY - e_Ammo_H))*10);
		logic [3:0] rom_q_enem13, rom_q_e13_ammo;
		logic [3:0] enem13_red, enem13_green, enem13_blue;

		
		//Conditions to check if we are drawing enemy 1-3
		always_comb
		begin: enem13_on_proc
		  if ( (enemy13_DistX >= -enemy13_width) && (enemy13_DistX <= enemy13_width) && (enemy13_DistY >= -enemy13_height) && (enemy13_DistY <= enemy13_height))	
				enemy13on = 1'b1;
		  else 
				enemy13on = 1'b0;
		end 
	  
		logic e13;
	  	assign e13 = ((enemy13on == 1'b1) && (enem13_red != 4'ha || enem13_green != 4'h4 || enem13_blue != 4'ha) && (level == 6'b000010) && ~hite13);

		//Conditions to check if we are drawing enemy 1-3 ammo
		always_comb
		 begin:e13_ammo_on_proc
			  if ((DrawX <= (e13_AmmoX + e_Ammo_W)) && (DrawX >= (e13_AmmoX - e_Ammo_W)) && (DrawY >= (e13_AmmoY- e_Ammo_H)) && (DrawY <= (e13_AmmoY)))
					e13_ammo_on = 1'b1;
			  else 
					e13_ammo_on = 1'b0;
		 end 
		
		logic e13_am;
	  	assign e13_am = ((e13_ammo_on == 1'b1) && (e13_ammo_red != 4'ha || e13_ammo_green != 4'h4 || e13_ammo_blue != 4'ha)) && e13_flag && ~hit13 && ~hite13; 
		
		//Enemy 1-3 Explosion
		logic [3:0] explosion13_r, explosion13_g, explosion13_b;
		logic explosion13on;
		logic [18:0] rom_address_exp13;
		logic [3:0] rom_q_exp13;
		assign rom_address_exp13 = (DrawX - (Enemy13X-enemy13_width)) + (DrawY - (Enemy13Y-enemy13_height))* 50 + (50*58*animation13);
		logic explode13 = 1'b0;
		logic animation13;
		logic startexp13 = 1'b0;
		logic [2:0] counter13 = 3'b000;

		
		//Conditions to check if we are drawing enemy 1-3 explosion
		always_comb
		begin: enem13explosion_on_proc
		  if ( (enemy13_DistX >= -enemy13_width) && (enemy13_DistX <= enemy13_width) && (enemy13_DistY >= -enemy13_height) && (enemy13_DistY <= enemy13_height))	
				explosion13on = 1'b1;
		  else 
				explosion13on = 1'b0;
		end 
	  
		logic exp13;
	  	assign exp13 = ((explosion13on == 1'b1) && (explosion13_r != 4'h0 || explosion13_g != 4'h1 || explosion13_b != 4'h3) && explode13);
		
		
always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset) //Reset counter
		counter13 = 3'b000;
	else if(hite13 == 1'b0)
		begin
		startexp13 = 1'b0;
		explode13 = 1'b0;
		end
	else if(hite13 == 1'b1 && startexp13 == 1'b0) //Jet 1-3 is hit
		begin
		explode13 = 1'b1;
		animation13 = 1'b0;
		startexp13 = 1'b1;
		counter13 = 3'b000;
		end
	else if(counter13 == 3'b101 && animation13 == 1'b0)
		begin
		animation13 = 1'b1;
		counter13 = 3'b000;
		end
	else if(counter13 == 3'b101 && animation13 == 1'b1)
		begin
		explode13 = 1'b0;
		end
	else
		counter13 = counter13 + 3'b001;
end
		
explosion_rom explosion13_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_exp13),
	.q       (rom_q_exp13)
);

explosion_palette explosion13_palette (
	.index (rom_q_exp13),
	.red   (explosion13_r),
	.green (explosion13_g),
	.blue  (explosion13_b)
);
		
enemy1_rom enemy13_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_enem13),
	.q       (rom_q_enem13)
);

enemy1_palette enemy13_palette (
	.index (rom_q_enem13),
	.red   (enem13_red),
	.green (enem13_green),
	.blue  (enem13_blue)
);

enemy_ammo_rom enemy13_ammo_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_e13_ammo),
	.q       (rom_q_e13_ammo)
);

enemy_ammo_palette enemy13_ammo_palette (
	.index (rom_q_e13_ammo),
	.red   (e13_ammo_red),
	.green (e13_ammo_green),
	.blue  (e13_ammo_blue)
);	
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////Level 2 Enemy and Ammo/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

//2-1

		logic enemy21on, e21_ammo_on;
		logic [3:0] e21_ammo_red, e21_ammo_green, e21_ammo_blue;
 		
		int enemy21_DistX, enemy21_DistY, enemy21_width, enemy21_height;
		assign enemy21_width = Enem_W;
		assign enemy21_height = Enem_H;
		assign enemy21_DistX = DrawX - Enemy21X;
		assign enemy21_DistY = DrawY - Enemy21Y;
		
		//Rom Address of Enemy 2-1 and its Ammo
		logic [18:0] rom_address_enem21, rom_address_e21_ammo;
		assign rom_address_enem21 = (DrawX - (Enemy21X-enemy21_width)) + (DrawY - (Enemy21Y-enemy21_height))* 50 + (50*58*p21);
		assign rom_address_e21_ammo = ((DrawX - (e21_AmmoX - e_Ammo_W)) + (DrawY - (e21_AmmoY - e_Ammo_H))*10);
		logic [3:0] rom_q_enem21, rom_q_e21_ammo;
		logic [3:0] enem21_red, enem21_green, enem21_blue;

		
		//Conditions to check if we are drawing enemy 2-1
		always_comb
		begin: enem21_on_proc
		  if ( (enemy21_DistX >= -enemy21_width) && (enemy21_DistX <= enemy21_width) && (enemy21_DistY >= -enemy21_height) && (enemy21_DistY <= enemy21_height))	
				enemy21on = 1'b1;
		  else 
				enemy21on = 1'b0;
		end 
	  
		logic e21;
	  	assign e21 = ((enemy21on == 1'b1) && (enem21_red != 4'ha || enem21_green != 4'h4 || enem21_blue != 4'ha) && (level == 6'b000100) && ~hite21);

		//Conditions to check if we are drawing enemy 2-1 ammo
		always_comb
		 begin:e21_ammo_on_proc
			  if ((DrawX <= (e21_AmmoX + e_Ammo_W)) && (DrawX >= (e21_AmmoX - e_Ammo_W)) && (DrawY >= (e21_AmmoY- e_Ammo_H)) && (DrawY <= (e21_AmmoY)))
					e21_ammo_on = 1'b1;
			  else 
					e21_ammo_on = 1'b0;
		 end 
		
		logic e21_am;
	  	assign e21_am = ((e21_ammo_on == 1'b1) && (e21_ammo_red != 4'ha || e21_ammo_green != 4'h4 || e21_ammo_blue != 4'ha)) && e21_flag && ~hit21 && ~hite21;
		
		//Enemy 2-1 Explosion
		logic [3:0] explosion21_r, explosion21_g, explosion21_b;
		logic explosion21on;
		logic [18:0] rom_address_exp21;
		logic [3:0] rom_q_exp21;
		assign rom_address_exp21 = (DrawX - (Enemy21X-enemy21_width)) + (DrawY - (Enemy21Y-enemy21_height))* 50 + (50*58*animation21);
		logic explode21 = 1'b0;
		logic animation21;
		logic startexp21 = 1'b0;
		logic [2:0] counter21 = 3'b000;

		
		//Conditions to check if we are drawing enemy 2-1 explosion
		always_comb
		begin: enem21explosion_on_proc
		  if ( (enemy21_DistX >= -enemy21_width) && (enemy21_DistX <= enemy21_width) && (enemy21_DistY >= -enemy21_height) && (enemy21_DistY <= enemy21_height))	
				explosion21on = 1'b1;
		  else 
				explosion21on = 1'b0;
		end 
	  
		logic exp21;
	  	assign exp21 = ((explosion21on == 1'b1) && (explosion21_r != 4'h0 || explosion21_g != 4'h1 || explosion21_b != 4'h3) && explode21);
		
		
always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset) //Reset counter
		counter21 = 3'b000;
	else if(hite21 == 1'b0)
		begin
		startexp21 = 1'b0;
		explode21 = 1'b0;
		end
	else if(hite21 == 1'b1 && startexp21 == 1'b0) //Jet 2-1 is hit
		begin
		explode21 = 1'b1;
		animation21 = 1'b0;
		startexp21 = 1'b1;
		counter21 = 3'b000;
		end
	else if(counter21 == 3'b101 && animation21 == 1'b0)
		begin
		animation21 = 1'b1;
		counter21 = 3'b000;
		end
	else if(counter21 == 3'b101 && animation21 == 1'b1)
		begin
		explode21 = 1'b0;
		end
	else
		counter21 = counter21 + 3'b001;
end
		
explosion_rom explosion21_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_exp21),
	.q       (rom_q_exp21)
);

explosion_palette explosion21_palette (
	.index (rom_q_exp21),
	.red   (explosion21_r),
	.green (explosion21_g),
	.blue  (explosion21_b)
);
		
enemy1_rom enemy21_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_enem21),
	.q       (rom_q_enem21)
);

enemy1_palette enemy21_palette (
	.index (rom_q_enem21),
	.red   (enem21_red),
	.green (enem21_green),
	.blue  (enem21_blue)
);

enemy_ammo_rom enemy21_ammo_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_e21_ammo),
	.q       (rom_q_e21_ammo)
);

enemy_ammo_palette enemy21_ammo_palette (
	.index (rom_q_e21_ammo),
	.red   (e21_ammo_red),
	.green (e21_ammo_green),
	.blue  (e21_ammo_blue)
);		

//2-2

		logic enemy22on, e22_ammo_on;
		logic [3:0] e22_ammo_red, e22_ammo_green, e22_ammo_blue;
 		
		int enemy22_DistX, enemy22_DistY, enemy22_width, enemy22_height;
		assign enemy22_width = Enem_W;
		assign enemy22_height = Enem_H;
		assign enemy22_DistX = DrawX - Enemy22X;
		assign enemy22_DistY = DrawY - Enemy22Y;
		
		//Rom Address of Enemy 2-2 and its Ammo
		logic [18:0] rom_address_enem22, rom_address_e22_ammo;
		assign rom_address_enem22 = (DrawX - (Enemy22X-enemy22_width)) + (DrawY - (Enemy22Y-enemy22_height))* 50 + (50*58*p22);
		assign rom_address_e22_ammo = ((DrawX - (e22_AmmoX - e_Ammo_W)) + (DrawY - (e22_AmmoY - e_Ammo_H))*10);
		logic [3:0] rom_q_enem22, rom_q_e22_ammo;
		logic [3:0] enem22_red, enem22_green, enem22_blue;

		
		//Conditions to check if we are drawing enemy 2-2
		always_comb
		begin: enem22_on_proc
		  if ( (enemy22_DistX >= -enemy22_width) && (enemy22_DistX <= enemy22_width) && (enemy22_DistY >= -enemy22_height) && (enemy22_DistY <= enemy22_height))	
				enemy22on = 1'b1;
		  else 
				enemy22on = 1'b0;
		end 
	  
		logic e22;
	  	assign e22 = ((enemy22on == 1'b1) && (enem22_red != 4'ha || enem22_green != 4'h4 || enem22_blue != 4'ha) && (level == 6'b000100) && ~hite22);

		//Conditions to check if we are drawing enemy 2-2 ammo
		always_comb
		 begin:e22_ammo_on_proc
			  if ((DrawX <= (e22_AmmoX + e_Ammo_W)) && (DrawX >= (e22_AmmoX - e_Ammo_W)) && (DrawY >= (e22_AmmoY- e_Ammo_H)) && (DrawY <= (e22_AmmoY)))
					e22_ammo_on = 1'b1;
			  else 
					e22_ammo_on = 1'b0;
		 end 
		
		logic e22_am;
	  	assign e22_am = ((e22_ammo_on == 1'b1) && (e22_ammo_red != 4'ha || e22_ammo_green != 4'h4 || e22_ammo_blue != 4'ha)) && e22_flag && ~hit22 && ~hite22;
		
		//Enemy 2-2 Explosion
		logic [3:0] explosion22_r, explosion22_g, explosion22_b;
		logic explosion22on;
		logic [18:0] rom_address_exp22;
		logic [3:0] rom_q_exp22;
		assign rom_address_exp22 = (DrawX - (Enemy22X-enemy22_width)) + (DrawY - (Enemy22Y-enemy22_height))* 50 + (50*58*animation22);
		logic explode22 = 1'b0;
		logic animation22;
		logic startexp22 = 1'b0;
		logic [2:0] counter22 = 3'b000;

		
		//Conditions to check if we are drawing enemy 2-2 explosion
		always_comb
		begin: enem22explosion_on_proc
		  if ( (enemy22_DistX >= -enemy22_width) && (enemy22_DistX <= enemy22_width) && (enemy22_DistY >= -enemy22_height) && (enemy22_DistY <= enemy22_height))	
				explosion22on = 1'b1;
		  else 
				explosion22on = 1'b0;
		end 
	  
		logic exp22;
	  	assign exp22 = ((explosion22on == 1'b1) && (explosion22_r != 4'h0 || explosion22_g != 4'h1 || explosion22_b != 4'h3) && explode22);
		
		
always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset) //Reset counter
		counter22 = 3'b000;
	else if(hite22 == 1'b0)
		begin
		startexp22 = 1'b0;
		explode22 = 1'b0;
		end
	else if(hite22 == 1'b1 && startexp22 == 1'b0) //Jet 2-2 is hit
		begin
		explode22 = 1'b1;
		animation22 = 1'b0;
		startexp22 = 1'b1;
		counter22 = 3'b000;
		end
	else if(counter22 == 3'b101 && animation22 == 1'b0)
		begin
		animation22 = 1'b1;
		counter22 = 3'b000;
		end
	else if(counter22 == 3'b101 && animation22 == 1'b1)
		begin
		explode22 = 1'b0;
		end
	else
		counter22 = counter22 + 3'b001;
end
		
explosion_rom explosion22_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_exp22),
	.q       (rom_q_exp22)
);

explosion_palette explosion22_palette (
	.index (rom_q_exp22),
	.red   (explosion22_r),
	.green (explosion22_g),
	.blue  (explosion22_b)
);
		
enemy1_rom enemy22_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_enem22),
	.q       (rom_q_enem22)
);

enemy1_palette enemy22_palette (
	.index (rom_q_enem22),
	.red   (enem22_red),
	.green (enem22_green),
	.blue  (enem22_blue)
);

enemy_ammo_rom enemy22_ammo_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_e22_ammo),
	.q       (rom_q_e22_ammo)
);

enemy_ammo_palette enemy22_ammo_palette (
	.index (rom_q_e22_ammo),
	.red   (e22_ammo_red),
	.green (e22_ammo_green),
	.blue  (e22_ammo_blue)
);

//2-3

		logic enemy23on, e23_ammo_on;
		logic [3:0] e23_ammo_red, e23_ammo_green, e23_ammo_blue;
 		
		int enemy23_DistX, enemy23_DistY, enemy23_width, enemy23_height;
		assign enemy23_width = Enem_W;
		assign enemy23_height = Enem_H;
		assign enemy23_DistX = DrawX - Enemy23X;
		assign enemy23_DistY = DrawY - Enemy23Y;
		
		//Rom Address of Enemy 2-3 and its Ammo
		logic [18:0] rom_address_enem23, rom_address_e23_ammo;
		assign rom_address_enem23 = (DrawX - (Enemy23X-enemy23_width)) + (DrawY - (Enemy23Y-enemy23_height))* 50 + (50*58*p23);
		assign rom_address_e23_ammo = ((DrawX - (e23_AmmoX - e_Ammo_W)) + (DrawY - (e23_AmmoY - e_Ammo_H))*10);
		logic [3:0] rom_q_enem23, rom_q_e23_ammo;
		logic [3:0] enem23_red, enem23_green, enem23_blue;

		
		//Conditions to check if we are drawing enemy 2-3
		always_comb
		begin: enem23_on_proc
		  if ( (enemy23_DistX >= -enemy23_width) && (enemy23_DistX <= enemy23_width) && (enemy23_DistY >= -enemy23_height) && (enemy23_DistY <= enemy23_height))	
				enemy23on = 1'b1;
		  else 
				enemy23on = 1'b0;
		end 
	  
		logic e23;
	  	assign e23 = ((enemy23on == 1'b1) && (enem23_red != 4'ha || enem23_green != 4'h4 || enem23_blue != 4'ha) && (level == 6'b000100) && ~hite23);

		//Conditions to check if we are drawing enemy 2-3 ammo
		always_comb
		 begin:e23_ammo_on_proc
			  if ((DrawX <= (e23_AmmoX + e_Ammo_W)) && (DrawX >= (e23_AmmoX - e_Ammo_W)) && (DrawY >= (e23_AmmoY- e_Ammo_H)) && (DrawY <= (e23_AmmoY)))
					e23_ammo_on = 1'b1;
			  else 
					e23_ammo_on = 1'b0;
		 end 
		
		logic e23_am;
	  	assign e23_am = ((e23_ammo_on == 1'b1) && (e23_ammo_red != 4'ha || e23_ammo_green != 4'h4 || e23_ammo_blue != 4'ha)) && e23_flag && ~hit23 && ~hite23;
		
		//Enemy 2-3 Explosion
		logic [3:0] explosion23_r, explosion23_g, explosion23_b;
		logic explosion23on;
		logic [18:0] rom_address_exp23;
		logic [3:0] rom_q_exp23;
		assign rom_address_exp23 = (DrawX - (Enemy23X-enemy23_width)) + (DrawY - (Enemy23Y-enemy23_height))* 50 + (50*58*animation23);
		logic explode23 = 1'b0;
		logic animation23;
		logic startexp23 = 1'b0;
		logic [2:0] counter23 = 3'b000;

		
		//Conditions to check if we are drawing enemy 2-3 explosion
		always_comb
		begin: enem23explosion_on_proc
		  if ( (enemy23_DistX >= -enemy23_width) && (enemy23_DistX <= enemy23_width) && (enemy23_DistY >= -enemy23_height) && (enemy23_DistY <= enemy23_height))	
				explosion23on = 1'b1;
		  else 
				explosion23on = 1'b0;
		end 
	  
		logic exp23;
	  	assign exp23 = ((explosion23on == 1'b1) && (explosion23_r != 4'h0 || explosion23_g != 4'h1 || explosion23_b != 4'h3) && explode23);
		
		
always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset) //Reset counter
		counter23 = 3'b000;
	else if(hite23 == 1'b0)
		begin
		startexp23 = 1'b0;
		explode23 = 1'b0;
		end
	else if(hite23 == 1'b1 && startexp23 == 1'b0) //Jet 2-3 is hit
		begin
		explode23 = 1'b1;
		animation23 = 1'b0;
		startexp23 = 1'b1;
		counter23 = 3'b000;
		end
	else if(counter23 == 3'b101 && animation23 == 1'b0)
		begin
		animation23 = 1'b1;
		counter23 = 3'b000;
		end
	else if(counter23 == 3'b101 && animation23 == 1'b1)
		begin
		explode23 = 1'b0;
		end
	else
		counter23 = counter23 + 3'b001;
end
		
explosion_rom explosion23_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_exp23),
	.q       (rom_q_exp23)
);

explosion_palette explosion23_palette (
	.index (rom_q_exp23),
	.red   (explosion23_r),
	.green (explosion23_g),
	.blue  (explosion23_b)
);
		
		
enemy1_rom enemy23_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_enem23),
	.q       (rom_q_enem23)
);

enemy1_palette enemy23_palette (
	.index (rom_q_enem23),
	.red   (enem23_red),
	.green (enem23_green),
	.blue  (enem23_blue)
);

enemy_ammo_rom enemy23_ammo_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_e23_ammo),
	.q       (rom_q_e23_ammo)
);

enemy_ammo_palette enemy23_ammo_palette (
	.index (rom_q_e23_ammo),
	.red   (e23_ammo_red),
	.green (e23_ammo_green),
	.blue  (e23_ammo_blue)
);
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////Level 3 Enemy and Ammo/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		

		logic boss_on, boss_ammo_on, boss_ammo_on2, boss_ammo_on3;
		logic [3:0] boss_ammo_red, boss_ammo_green, boss_ammo_blue, boss_ammo_red2, boss_ammo_green2, boss_ammo_blue2, boss_ammo_red3, boss_ammo_green3, boss_ammo_blue3;
 		
		int boss_DistX, boss_DistY, boss_width, boss_height, temp;
		assign boss_width = 120;
		assign boss_height = 90;
		assign boss_DistX = DrawX - bossX;
		assign boss_DistY = DrawY - bossY;
		logic [9:0] boss_am_w, boss_am_h;
		assign boss_am_w = 25;
		assign boss_am_h = 50;
		assign temp = 45;
		
		//Rom Address of Enemy 2-3 and its Ammo
		logic [18:0] rom_address_boss, rom_address_boss_ammo, rom_address_boss_ammo2, rom_address_boss_ammo3;
		assign rom_address_boss = (DrawX - (bossX-boss_width)) + (DrawY - (bossY-boss_height))* 240;
		assign rom_address_boss_ammo = ((DrawX - (boss_AmmoX - boss_am_w)) + (DrawY - (boss_AmmoY - boss_am_h)-1)*50);
//		assign rom_address_boss_ammo2 = ((DrawX - (boss_AmmoX2 - boss_am_w)) + (DrawY - (boss_AmmoY2 - boss_am_h)-1)*50);
//		assign rom_address_boss_ammo3 = ((DrawX - (boss_AmmoX3 - boss_am_w)) + (DrawY - (boss_AmmoY3 - boss_am_h)-1)*50);
		logic [3:0] rom_q_boss, rom_q_boss_ammo, rom_q_boss_ammo2, rom_q_boss_ammo3;
		logic [3:0] boss_red, boss_green, boss_blue;
		
		always_comb
		begin
			if(DrawY - (boss_AmmoY - boss_am_h) <= 5)
			begin
				rom_address_boss_ammo2 = ((DrawX - (boss_AmmoX2 - boss_am_w)) + (DrawY - (boss_AmmoY2 - boss_am_h)*50));
				rom_address_boss_ammo3 = ((DrawX - (boss_AmmoX3 - boss_am_w)) + (DrawY - (boss_AmmoY3 - boss_am_h)*50));
			end
			else
			begin
				rom_address_boss_ammo2 = ((DrawX - (boss_AmmoX2 - boss_am_w)) + (DrawY - (boss_AmmoY2 - boss_am_h)-1)*50);
				rom_address_boss_ammo3 = ((DrawX - (boss_AmmoX3 - boss_am_w)) + (DrawY - (boss_AmmoY3 - boss_am_h)-1)*50);
			end
		end

		
		//Conditions to check if we are drawing boss
		always_comb
		begin: boss_on_proc
		  if ( (boss_DistX >= -boss_width) && (boss_DistX <= boss_width) && (boss_DistY >= -boss_height) && (boss_DistY <= boss_height))	
				boss_on = 1'b1;
		  else 
				boss_on = 1'b0;
		end 
	  
		logic boss;
	  	assign boss = (boss_on == 1'b1) && (boss_red != 4'ha || boss_green != 4'h4 || boss_blue != 4'ha) && (level == 6'b001000) && ~(damage_boss == 15 || damage_boss==16);

		//Conditions to check if we are drawing boss ammo 1
		always_comb
		 begin:boss_ammo_on_proc
			  if ((DrawX <= (boss_AmmoX + boss_am_w)) && (DrawX >= (boss_AmmoX - boss_am_w)) && (DrawY >= (boss_AmmoY- boss_am_h)) && (DrawY <= (boss_AmmoY)))
					boss_ammo_on = 1'b1;
			  else 
					boss_ammo_on = 1'b0;
		 end 
		
		logic boss_am;
	  	assign boss_am = ((boss_ammo_on == 1'b1) && (boss_ammo_red != 4'ha || boss_ammo_green != 4'h4 || boss_ammo_blue != 4'ha)) && boss_flag && ~hitboss && ~(damage_boss == 15 || damage_boss==16);
		
		//Conditions to check if we are drawing boss ammo 2
		always_comb
		 begin:boss_ammo_on_proc2
			  if ((DrawX <= (boss_AmmoX2 + boss_am_w)) && (DrawX >= (boss_AmmoX2 - boss_am_w)) && (DrawY >= (boss_AmmoY2- temp)) && (DrawY <= (boss_AmmoY2)))
					boss_ammo_on2 = 1'b1;
			  else 
					boss_ammo_on2 = 1'b0;
		 end 
		
		logic boss_am2;
	  	assign boss_am2 = ((boss_ammo_on2 == 1'b1) && (boss_ammo_red2 != 4'ha || boss_ammo_green2 != 4'h4 || boss_ammo_blue2 != 4'ha)) && boss_flag2 && ~hitboss2 && ~(damage_boss == 15 || damage_boss==16);
		
		//Conditions to check if we are drawing boss ammo 3
		always_comb
		 begin:boss_ammo_on_proc3
			  if ((DrawX <= (boss_AmmoX3 + boss_am_w)) && (DrawX >= (boss_AmmoX3 - boss_am_w)) && (DrawY >= (boss_AmmoY3- temp)) && (DrawY <= (boss_AmmoY3)))
					boss_ammo_on3 = 1'b1;
			  else 
					boss_ammo_on3 = 1'b0;
		 end 
		
		logic boss_am3;
	  	assign boss_am3 = ((boss_ammo_on3 == 1'b1) && (boss_ammo_red3 != 4'ha || boss_ammo_green3 != 4'h4 || boss_ammo_blue3 != 4'ha)) && boss_flag3 && ~hitboss3 && ~(damage_boss == 15 || damage_boss==16);

boss_rom boss_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_boss),
	.q       (rom_q_boss)
);

boss_palette boss_palette (
	.index (rom_q_boss),
	.red   (boss_red),
	.green (boss_green),
	.blue  (boss_blue)
);

boss_am_rom boss_am_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_boss_ammo),
	.q       (rom_q_boss_ammo)
);

boss_am_palette boss_am_palette (
	.index (rom_q_boss_ammo),
	.red   (boss_ammo_red),
	.green (boss_ammo_green),
	.blue  (boss_ammo_blue)
);

boss_am_rom boss2_am_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_boss_ammo2),
	.q       (rom_q_boss_ammo2)
);

boss_am_palette boss2_am_palette (
	.index (rom_q_boss_ammo2),
	.red   (boss_ammo_red2),
	.green (boss_ammo_green2),
	.blue  (boss_ammo_blue2)
);

boss_am_rom boss3_am_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_boss_ammo3),
	.q       (rom_q_boss_ammo3)
);

boss_am_palette boss3_am_palette (
	.index (rom_q_boss_ammo3),
	.red   (boss_ammo_red3),
	.green (boss_ammo_green3),
	.blue  (boss_ammo_blue3)
);





		//Boss Explosion
		logic [3:0] expbossr, expbossg, expbossb;
		logic expbosson;
		logic [18:0] rom_address_expb;
		logic [3:0] rom_q_expb;
		assign rom_address_expb = (DrawX - (bossX-enemy23_width))/2 + (DrawY - (bossY-enemy23_height))/2* 50 + (50*58*animationb);
		logic explodeb = 1'b0;
		logic animationb;
		logic startexpb = 1'b0;
		logic [2:0] counterb = 3'b000;
		
		int bossexp_DistX, bossexp_DistY;
		assign bossexp_DistX = bossX - enemy23_width;
		assign bossexp_DistY = bossY - enemy23_height;

		//Conditions to check if we are drawing boss explosion
		always_comb
		begin: bossexp_on_proc
		  if ( (bossexp_DistX >= -2*enemy23_width) && (bossexp_DistX <= 2*enemy23_width) && (bossexp_DistY >= -2*enemy23_height) && (bossexp_DistY <= 2*enemy23_height))	
				expbosson = 1'b1;
		  else 
				expbosson = 1'b0;
		end 
	  
		logic expb;
	  	assign expb = ((expbosson == 1'b1) && (expbossr != 4'h0 || expbossg != 4'h1 || expbossb != 4'h3) && explodeb);
		
always_ff @ (posedge frame_clk or posedge reset)
begin
	if(reset) //Reset counter
		counterb = 3'b000;
	else if(damage_boss != 15 && damage_boss != 16)
		begin
		startexpb = 1'b0;
		explodeb = 1'b0;
		end
	else if(damage_boss == 15 || damage_boss == 16) //Jet 2-3 is hit
		begin
		explodeb = 1'b1;
		animationb = 1'b0;
		startexpb = 1'b1;
		counterb = 3'b000;
		end
	else if(counterb == 3'b101 && animationb == 1'b0)
		begin
		animationb = 1'b1;
		counterb = 3'b000;
		end
	else if(counterb == 3'b101 && animationb == 1'b1)
		begin
		explodeb = 1'b0;
		end
	else
		counterb = counterb + 3'b001;
end
		
explosion_rom explosionboss_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_expb),
	.q       (rom_q_expb)
);

explosion_palette explosionboss_palette (
	.index (rom_q_expb),
	.red   (expbossr),
	.green (expbossg),
	.blue  (expbossb)
);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////Health Bar Control/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

//NEED TO ADD CONDITION SO THAT ONE SHOT WILL NOT KILL THE PLANE AND THE SHOT/ENEMY WILL DISAPPEAR
logic hit11, hit12, hit13, hit21, hit22, hit23, hitboss, hitboss2, hitboss3;
assign hit_11 = hit11;
assign hit_12 = hit12;
assign hit_13 = hit13;
assign hit_21 = hit21;
assign hit_22 = hit22;
assign hit_23 = hit23;
assign hit_boss = hitboss;
assign hit_boss2 = hitboss2;
assign hit_boss3 = hitboss3;

							  


always_ff @(posedge vga_clk or posedge reset)
begin
	if(reset)
		begin
		damage = 3'b000;
		hit11 = 1'b0;
		hit12 = 1'b0;
		hit13 = 1'b0;
		hit21 = 1'b0;
		hit22 = 1'b0;
		hit23 = 1'b0;
		hitboss = 1'b0;
		hitboss2 = 1'b0;
		hitboss3 = 1'b0;
		touchfix = 1'b0;
		end
	else if(touchfix)
		begin
		damage = 3'b000;
		hit11 = 1'b0;
		hit12 = 1'b0;
		hit13 = 1'b0;
		hit21 = 1'b0;
		hit22 = 1'b0;
		hit23 = 1'b0;
		hitboss = 1'b0;
		hitboss2 = 1'b0;
		hitboss3 = 1'b0;
		touchfix = 1'b0;
		end
	else if(level == 6'b000001) //Start Screen
		begin
		damage = 3'b000;
		hit11 = 1'b0;
		hit12 = 1'b0;
		hit13 = 1'b0;
		hit21 = 1'b0;
		hit22 = 1'b0;
		hit23 = 1'b0;
		hitboss = 1'b0;
		hitboss2 = 1'b0;
		hitboss3 = 1'b0;
		touchfix = 1'b0;
		end
	else if(b == 1'b1)
		begin
		if(e11 == 1'b1)
			begin
			damage = damage + 3'b001;
			hit11 = 1'b0;
			hit12 = 1'b0;
			hit13 = 1'b0;
			hit21 = 1'b0;
			hit22 = 1'b0;
			hit23 = 1'b0;
			hitboss = 1'b0;
			hitboss2 = 1'b0;
			hitboss3 = 1'b0;
			touchfix = touchfix;
			end
		if(e12 == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = 1'b0;
			hit12 = 1'b0;
			hit13 = 1'b0;
			hit21 = 1'b0;
			hit22 = 1'b0;
			hit23 = 1'b0;
			hitboss = 1'b0;
			hitboss2 = 1'b0;
			hitboss3 = 1'b0;
			touchfix = touchfix;
			end
		if(e13 == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = 1'b0;
			hit12 = 1'b0;
			hit13 = 1'b0;
			hit21 = 1'b0;
			hit22 = 1'b0;
			hit23 = 1'b0;
			hitboss = 1'b0;
			hitboss2 = 1'b0;
			hitboss3 = 1'b0;
			touchfix = touchfix;
			end
		if(e21 == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = 1'b0;
			hit12 = 1'b0;
			hit13 = 1'b0;
			hit21 = 1'b0;
			hit22 = 1'b0;
			hit23 = 1'b0;
			hitboss = 1'b0;
			hitboss2 = 1'b0;
			hitboss3 = 1'b0;
			touchfix = touchfix;
			end
		if(e22 == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = 1'b0;
			hit12 = 1'b0;
			hit13 = 1'b0;
			hit21 = 1'b0;
			hit22 = 1'b0;
			hit23 = 1'b0;
			hitboss = 1'b0;
			hitboss2 = 1'b0;
			hitboss3 = 1'b0;
			touchfix = touchfix;
			end
		if(e23 == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = 1'b0;
			hit12 = 1'b0;
			hit13 = 1'b0;
			hit21 = 1'b0;
			hit22 = 1'b0;
			hit23 = 1'b0;
			hitboss = 1'b0;
			hitboss2 = 1'b0;
			hitboss3 = 1'b0;
			touchfix = touchfix;
			end 
		if(boss == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = 1'b0;
			hit12 = 1'b0;
			hit13 = 1'b0;
			hit21 = 1'b0;
			hit22 = 1'b0;
			hit23 = 1'b0;
			hitboss = 1'b0;
			hitboss2 = 1'b0;
			hitboss3 = 1'b0;
			touchfix = touchfix;
			end
		if(e11_am == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = 1'b1;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(e12_am == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = 1'b1;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(e13_am == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = 1'b1;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(e21_am == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = 1'b1;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(e22_am == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = 1'b1;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(e23_am == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = 1'b1;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(boss_am == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = 1'b1;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(boss_am2 == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = 1'b1;
			hitboss3 = hitboss3;
			touchfix = touchfix;
			end
		if(boss_am3 == 1'b1)
			begin
			damage = damage+ 3'b001;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = 1'b1;
			touchfix = touchfix;
			end
		if(fix == 1'b1)
			begin
			damage = damage;
			hit11 = hit11;
			hit12 = hit12;
			hit13 = hit13;
			hit21 = hit21;
			hit22 = hit22;
			hit23 = hit23;
			hitboss = hitboss;
			hitboss2 = hitboss2;
			hitboss3 = hitboss3;
			touchfix = 1'b1;
			end
		end
	else
		begin
		damage = damage;
		hit11 = hit11 && ((Enemy11Y + Enem_H) != e11_AmmoY);
		hit12 = hit12 && ((Enemy12Y + Enem_H) != e12_AmmoY);
		hit13 = hit13 && ((Enemy13Y + Enem_H) != e13_AmmoY);
		hit21 = hit21 && ((Enemy21Y + Enem_H) != e21_AmmoY);
		hit22 = hit22 && ((Enemy22Y + Enem_H) != e22_AmmoY);
		hit23 = hit23 && ((Enemy23Y + Enem_H) != e23_AmmoY);
		hitboss = hitboss && ((bossY + Enem_H) != boss_AmmoY);
		hitboss2 = hitboss2 && ((bossY + Enem_H +10) != boss_AmmoY2);
		hitboss3 = hitboss3 && ((bossY + Enem_H +10) != boss_AmmoY3);
		touchfix = touchfix;
		end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////Enemy Collision///////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

logic hite11, hite12, hite13, hite21, hite22, hite23;
int damage_boss;
logic boss_collide;

logic just_hit;

always_ff @(posedge vga_clk or posedge reset)
begin
	if(reset)
		begin
		score = 3'b000;
		damage_boss = 0;
		just_hit = 1'b0;
		hite11 = 1'b0;
		hite12 = 1'b0;
		hite13 = 1'b0;
		hite21 = 1'b0;
		hite22 = 1'b0;
		hite23 = 1'b0;
		boss_collide = 1'b0;
		end
	else if(start == 1'b0)
		begin
		just_hit = 1'b0;
		score = 3'b000;
		damage_boss = 0;
		hite11 = 1'b0;
		hite12 = 1'b0;
		hite13 = 1'b0;
		hite21 = 1'b0;
		hite22 = 1'b0;
		hite23 = 1'b0;
		boss_collide = 1'b0;
		end
	else if(am == 1'b1)
		begin
		if(e11 == 1'b1)
			begin
			score = score + 3'b001;
			damage_boss = damage_boss;
			just_hit = 1'b1;
			hite11 = 1'b1;
			hite12 = hite12;
			hite13 = hite13;
			hite21 = hite21;
			hite22 = hite22;
			hite23 = hite23;
			boss_collide = 1'b0;
			end
		if(e12 == 1'b1)
			begin
			score = score + 3'b001;
			damage_boss = damage_boss;
			just_hit = 1'b1;
			hite11 = hite11;
			hite12 = 1'b1;
			hite13 = hite13;
			hite21 = hite21;
			hite22 = hite22;
			hite23 = hite23;
			boss_collide = 1'b0;
			end
		if(e13 == 1'b1)
			begin
			score = score + 3'b001;
			damage_boss = damage_boss;
			just_hit = 1'b1;
			hite11 = hite11;
			hite12 = hite12;
			hite13 = 1'b1;
			hite21 = hite21;
			hite22 = hite22;
			hite23 = hite23;
			boss_collide = 1'b0;
			end
		if(e21 == 1'b1)
			begin
			score = score + 3'b001;
			damage_boss = damage_boss;
			just_hit = 1'b1;
			hite11 = hite11;
			hite12 = hite12;
			hite13 = hite13;
			hite21 = 1'b1;
			hite22 = hite22;
			hite23 = hite23;
			boss_collide = 1'b0;
			end
		if(e22 == 1'b1)
			begin
			score = score + 3'b001;
			damage_boss = damage_boss;
			just_hit = 1'b1;
			hite11 = hite11;
			hite12 = hite12;
			hite13 = hite13;
			hite21 = hite21;
			hite22 = 1'b1;
			hite23 = hite23;
			boss_collide = 1'b0;
			end
		if(e23 == 1'b1)
			begin
			score = score + 3'b001;
			damage_boss = damage_boss;
			just_hit = 1'b1;
			hite11 = hite11;
			hite12 = hite12;
			hite13 = hite13;
			hite21 = hite21;
			hite22 = hite22;
			hite23 = 1'b1;
			boss_collide = 1'b0;
			end
		if(boss == 1'b1)
			begin
			damage_boss = damage_boss + 1;
			just_hit = 1'b1;
			hite11 = hite11;
			hite12 = hite12;
			hite13 = hite13;
			hite21 = hite21;
			hite22 = hite22;
			hite23 = hite23;
			boss_collide = 1'b1;
			if(damage_boss == 15)
				score = score + 3'b001;
			else
				score = score;
			end
		end
	else
		begin
			score = score;
			just_hit = (just_hit && ((BallY-Ball_H) != AmmoY));
			damage_boss = damage_boss;
			hite11 = hite11;
			hite12 = hite12;
			hite13 = hite13;
			hite21 = hite21;
			hite22 = hite22;
			hite23 = hite23;
			boss_collide = 1'b0;
		end
end


assign jhit = just_hit;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////0000000///00000///000000//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////00/////00////////00////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////00/////00000/////00////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////00/00/////00////////00////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////00000/////00000/////00////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		logic ball_on, health_on, score_on, ammo_on;
		int DistX, DistY, width, height;
		assign width = Ball_W;
		assign height = Ball_H;
		assign DistX = DrawX - BallX;
		assign DistY = DrawY - BallY;
		int HealthX, HealthY, scoreX, scoreY;
		assign HealthX = 480;
		assign HealthY = 440;
		logic [18:0] rom_address_jet, rom_address_h, rom_address_ammo, rom_address_fix;
		logic [3:0] rom_q_jet, rom_q_h, rom_q_ammo, rom_q_fix;
		logic [3:0] jet_red, jet_green, jet_blue;
		logic [3:0] fix_red, fix_green, fix_blue;
		logic [3:0] h_red, h_green, h_blue;
		logic [3:0] ammo_red, ammo_green, ammo_blue;
		logic negedge_vga_clk;
		// read from ROM on negedge, set pixel on posedge
		assign negedge_vga_clk = ~vga_clk;
	 
	 	assign scoreX = 370;
		assign scoreY = 325;	 

	 always_comb
    begin:Ball_on_proc
        if ( (DistX >= -width && DistX <= width) && (DistY >= -height && DistY <= height))	
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
	 
	 always_comb
    begin:health_on_proc
        if ((DrawX >= HealthX) && (DrawY >= HealthY))
            health_on = 1'b1;
        else 
            health_on = 1'b0;
     end 

	 always_comb
    begin:ammo_on_proc
        if ((DrawX <= (AmmoX + Ammo_W)) && (DrawX >= (AmmoX - Ammo_W)) && (DrawY >= (AmmoY - Ammo_H)) && (DrawY <= (AmmoY)))
            ammo_on = 1'b1;
        else 
            ammo_on = 1'b0;
    end  
		
	 always_comb
	 begin:score_on_proc
		  if ((DrawX >= scoreX) && (DrawX <= scoreX + 150) && (DrawY >= scoreY) && (DrawY <= scoreY+ 40))
				score_on = 1'b1;
		  else 
				score_on = 1'b0;
	  end 


	assign rom_address_jet = (DrawX - (BallX-width)) + (DrawY - (BallY-height))* 40 + (40*49*phase);
	assign rom_address_h = ((DrawX - HealthX) + ((DrawY - HealthY)* 160) + 40*160*damage);
	assign rom_address_ammo = ((DrawX - (AmmoX - Ammo_W)) + (DrawY - (AmmoY - Ammo_H))*10);
	assign rom_address_finalscore = ((DrawX - scoreX)/3 + ((DrawY - scoreY)/2* 50) + 50*20*score);

	
	logic h,b,sc, am;
	assign h = ((health_on == 1'b1) && (h_red != 4'ha || h_green != 4'h4 || h_blue != 4'ha)) && start && ~endd;
	assign b = ((ball_on == 1'b1) && (jet_red != 4'ha || jet_green != 4'h4 || jet_blue != 4'ha)) && start && ~endd;
	assign am = ((flag == 1'b1) && (ammo_red != 4'h2 || ammo_green != 4'hb || ammo_blue != 4'h4)) && start && ammo_on && ~endd && ~boss_collide;
	assign sc = ((score_on == 1'b1) && (finalscore_red != 4'h0 || finalscore_green != 4'h0 || finalscore_blue != 4'h0)) && (background == 4'b0100);


	 always_ff @(posedge vga_clk)
    begin:RGB_Display
		if(!blank)
			begin
				Red = 4'b0000;
				Green = 4'b0000;
				Blue = 4'b0000;
			end
		else if(h==1'b1)
        begin 
				Red = h_red;
				Green = h_green;
				Blue = h_blue;
        end 
		else if(sc==1'b1)
        begin 
				Red = finalscore_red;
				Green = finalscore_green;
				Blue = finalscore_blue;
        end		  
		else  if(b==1'b1)
			begin
				Red = jet_red;
				Green = jet_green;
				Blue = jet_blue;
			end  
		else  if(e11==1'b1)
			begin
				Red = enem11_red;
				Green = enem11_green;
				Blue = enem11_blue;
			end 
		else  if(e12==1'b1)
			begin
				Red = enem12_red;
				Green = enem12_green;
				Blue = enem12_blue;
			end 
		else  if(e13==1'b1)
			begin
				Red = enem13_red;
				Green = enem13_green;
				Blue = enem13_blue;
			end 
		else  if(e21==1'b1)
			begin
				Red = enem21_red;
				Green = enem21_green;
				Blue = enem21_blue;
			end 
		else  if(e22==1'b1)
			begin
				Red = enem22_red;
				Green = enem22_green;
				Blue = enem22_blue;
			end 
		else  if(e23==1'b1)
			begin
				Red = enem23_red;
				Green = enem23_green;
				Blue = enem23_blue;
			end 
		else  if(boss==1'b1)
			begin
				Red = boss_red;
				Green = boss_green;
				Blue = boss_blue;
			end 
		else  if(am==1'b1)
			begin
				Red = ammo_red;
				Green = ammo_green;
				Blue = ammo_blue;
			end 
		else if(e11_am == 1'b1)
			begin
				Red = e11_ammo_red;
				Green = e11_ammo_green;
				Blue = e11_ammo_blue;
			end
		else if(e12_am == 1'b1)
			begin
				Red = e12_ammo_red;
				Green = e12_ammo_green;
				Blue = e12_ammo_blue;
			end
		else if(e13_am == 1'b1)
			begin
				Red = e13_ammo_red;
				Green = e13_ammo_green;
				Blue = e13_ammo_blue;
			end
		else if(e21_am == 1'b1)
			begin
				Red = e21_ammo_red;
				Green = e21_ammo_green;
				Blue = e21_ammo_blue;
			end
		else if(e22_am == 1'b1)
			begin
				Red = e22_ammo_red;
				Green = e22_ammo_green;
				Blue = e22_ammo_blue;
			end
		else if(e23_am == 1'b1)
			begin
				Red = e23_ammo_red;
				Green = e23_ammo_green;
				Blue = e23_ammo_blue;
			end
		else  if(boss_am==1'b1)
			begin
				Red = boss_ammo_red;
				Green = boss_ammo_green;
				Blue = boss_ammo_blue;
			end 
		else  if(boss_am2==1'b1)
			begin
				Red = boss_ammo_red2;
				Green = boss_ammo_green2;
				Blue = boss_ammo_blue2;
			end 
		else  if(boss_am3==1'b1)
			begin
				Red = boss_ammo_red3;
				Green = boss_ammo_green3;
				Blue = boss_ammo_blue3;
			end 
		else if(exp11 == 1'b1)
			begin
				Red = explosion11_r;
				Green = explosion11_g;
				Blue = explosion11_b;
			end
		else if(exp12 == 1'b1)
			begin
				Red = explosion12_r;
				Green = explosion12_g;
				Blue = explosion12_b;
			end
		else if(exp13 == 1'b1)
			begin
				Red = explosion13_r;
				Green = explosion13_g;
				Blue = explosion13_b;
			end
		else if(exp21 == 1'b1)
			begin
				Red = explosion21_r;
				Green = explosion21_g;
				Blue = explosion21_b;
			end
		else if(exp22 == 1'b1)
			begin
				Red = explosion22_r;
				Green = explosion22_g;
				Blue = explosion22_b;
			end
		else if(exp23 == 1'b1)
			begin
				Red = explosion23_r;
				Green = explosion23_g;
				Blue = explosion23_b;
			end
		else if(expb == 1'b1)
			begin
				Red = expbossr;
				Green = expbossg;
				Blue = expbossb;
			end
		else if(fix == 1'b1)
			begin
				Red = fix_red;
				Green = fix_green;
				Blue = fix_blue;
			end
		else
			begin
				Red = bgd_r; 
				Green = bgd_g;
				Blue = bgd_b;
			end
	end

healthbar_rom healthbar_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_h),
	.q       (rom_q_h)
);

healthbar_palette healthbar_palette (
	.index (rom_q_h),
	.red   (h_red),
	.green (h_green),
	.blue  (h_blue)
);
//score_rom score_rom (
//	.clock   (negedge_vga_clk),
//	.address (rom_address_sc),
//	.q       (rom_q_sc)
//);
//
//score_palette score_palette (
//	.index (rom_q_sc),
//	.red   (sc_red),
//	.green (sc_green),
//	.blue  (sc_blue)
//);

fighterjet_rom fighterjet_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_jet),
	.q       (rom_q_jet)
);

fighterjet_palette fighterjet_palette (
	.index (rom_q_jet),
	.red   (jet_red),
	.green (jet_green),
	.blue  (jet_blue)
);

ammo_rom ammo_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_ammo),
	.q       (rom_q_ammo)
);

ammo_palette ammo_palette (
	.index (rom_q_ammo),
	.red   (ammo_red),
	.green (ammo_green),
	.blue  (ammo_blue)
);
			
		logic fixon; 		
		int fix_DistX, fix_DistY;
		assign fix_DistX = DrawX - fixX;
		assign fix_DistY = DrawY - fixY;
		
		//Rom Address 
		assign rom_address_fix = (DrawX - (fixX-12)) + (DrawY - (fixY-12))*25;


		//Conditions to check if we are drawing fix
		always_comb
		begin: fix_on_proc
		  if ( (fix_DistX >= -1*12) && (fix_DistX <= 12) && (fix_DistY >= -1*12) && (fix_DistY <= 12))	
				fixon = 1'b1;
		  else 
				fixon = 1'b0;
		end 
		
		always_latch
		begin: fix_proc
		  if(reset || level != 6'b000100)
				touched = 1'b0;
		  else if (touchfix)	
				touched = 1'b1;
		  else 
				touched = touched;
		end 
	  
		logic fix;
		logic touchfix;
		logic touched;
	  	assign fix = ((fixon == 1'b1) && (fix_red != 4'ha || fix_green != 4'h4 || fix_blue != 4'ha) && (level == 6'b000100) && ~touched && flagfix);
		


		
fix_rom fix_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_fix),
	.q       (rom_q_fix)
);

fix_palette fix_palette (
	.index (rom_q_fix),
	.red   (fix_red),
	.green (fix_green),
	.blue  (fix_blue)
);






endmodule


