//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballwidth, ballheight, ammoxsig, ammoysig, ammowidth, ammoheight;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;
	logic [7:0] keycode1;
	logic [7:0] keycode2;
	logic [1:0] phase;
	logic flag;
	
	
	logic [9:0] Enemy11X, Enemy11Y, e11_ammoxsig, e11_ammoysig, Enemy12X, Enemy12Y, e12_ammoxsig, e12_ammoysig, Enemy13X, Enemy13Y, e13_ammoxsig, e13_ammoysig; //Level 1 enemies
	logic [9:0] Enemy21X, Enemy21Y, e21_ammoxsig, e21_ammoysig, Enemy22X, Enemy22Y, e22_ammoxsig, e22_ammoysig, Enemy23X, Enemy23Y, e23_ammoxsig, e23_ammoysig; //Level 2 enemies
	logic [9:0] boss_X, boss_Y, boss_ammoxsig1, boss_ammoysig1, boss_ammoxsig2, boss_ammoysig2, boss_ammoxsig3, boss_ammoysig3;
	logic [9:0] fixX, fixY;
	logic [9:0] enemywidth, enemyheight, e_ammowidth, e_ammoheight; //Level 1 and 2 enemy dimensions
	logic [1:0] p11, p12, p13, p21, p22, p23; //Phases of all 6 jets (3 in each level 1 & 2)
	logic [5:0] level;
	logic [9:0] target1_Y = 50;
	logic [9:0] target2_Y = 150;
	logic [9:0] target3_Y = 100;
	logic [9:0] Enemy_X1_Original = 170;
	logic [9:0] Enemy_Y1_Original = 0;
	logic [9:0] Enemy_X2_Original = 340;
	logic [9:0] Enemy_Y2_Original = 0;
	logic [9:0] Enemy_X3_Original = 510;
	logic [9:0] Enemy_Y3_Original = 0;
	logic [9:0] boss_X_Original = 340;
	logic [9:0] boss_Y_Original = 30;
	logic flag1, flag2, flag3, flag4, flag5, flag6, flagboss;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red;
	assign VGA_B = Blue;
	assign VGA_G = Green;
	
	
	lab62_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export 	(KEY), //Originally key_external_connection_export           //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST), //Originally usb_rsb_export
		.usb_irq_export(USB_IRQ), //Originally usb_irq_export
		.usb_gpx_export(USB_GPX), //Originally usb_gpx_export
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}), //Originally hex_digits_export
		.leds_export({hundreds, signs, LEDR}), //Originally leds_export
		.keycode_export(keycode), //Originally keycode_export
		.keycode1_export(keycode1),
		.keycode2_export(keycode2)
		
	 );
	 
	 
	//instantiate a vga_controller, ball, and color_mapper here with the ports.

	 
	 vga_controller vga_c (
		.Clk(MAX10_CLK1_50),
		.Reset(Reset_h),
		.hs(VGA_HS),
		.vs(VGA_VS),
		.pixel_clk(VGA_Clk),
		.blank(blank),
		.sync(sync),
		.DrawX(drawxsig),
		.DrawY(drawysig)
	 );

//Input
// Clk 50 MHz clock
// Reset reset signal	 
//Output
// hs Horizontal sync pulse.  Active low
// vs Vertical sync pulse.  Active low
// pixel_clk 25 MHz pixel clock output
// blank Blanking interval indicator.  Active low.
// sync Composite Sync signal.  Active low.  We don't use it in this lab,
//   but the video DAC on the DE2 board requires an input for it.
// DrawX horizontal coordinate
// DrawY vertical coordinate
												  
	ball test_ball (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.keycode(keycode),
		.keycode1(keycode1),
		.keycode2(keycode2),
		.level(level),
		.BallX(ballxsig),
		.BallY(ballysig),
		.Ball_W(ballwidth),
		.Ball_H(ballheight),
		.phase(phase)
	);
	
	ammo test_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.keycode(keycode),
		.keycode1(keycode1),
		.keycode2(keycode2),
		.BallX(ballxsig),
		.BallY(ballysig),
		.Ball_W(ballwidth),
		.Ball_H(ballheight),
		.jhit(just_hit),
		.AmmoX(ammoxsig),
		.AmmoY(ammoysig),
		.Ammo_W(ammowidth),
		.Ammo_H(ammoheight),
		.flag(flag)
	);
	
//////////////////////////////////////////////////////////////////////////
//////////////////////////LEVEL 1 ENEMIES/////////////////////////////////
//////////////////////////////////////////////////////////////////////////

	//50x60 enemy
	assign enemywidth = 25;
	assign enemyheight = 30;
	//10x20 enemy ammo
	assign e_ammowidth = 5;
	assign e_ammoheight = 20;
	
	logic hit11, hit12, hit13, hit21, hit22, hit23, hitboss;
	logic just_hit;

	//1-1
	
	enemy_level enemylevel1_1 (
	.Reset(Reset_h),
	.frame_clk(VGA_VS),
	.level(level),
	.jetlevel(6'b000010),
	.Enemy_X_Original(Enemy_X1_Original),
	.Enemy_Y_Original(Enemy_Y1_Original),
	.target_Y(target1_Y),
	.EnemyX(Enemy11X),
	.EnemyY(Enemy11Y),
	.phase(p11)
	);

	enemy_ammo enemy11_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hit11),
		.ammolevel(6'b000010),
		.BallX(Enemy11X),
		.BallY(Enemy11Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.AmmoX(e11_ammoxsig),
		.AmmoY(e11_ammoysig),
		.flag(flag1)
	);

	//1-2
	
	enemy_level enemylevel1_2 (
	.Reset(Reset_h),
	.frame_clk(VGA_VS),
	.level(level),
	.jetlevel(6'b000010),
	.Enemy_X_Original(Enemy_X2_Original),
	.Enemy_Y_Original(Enemy_Y2_Original),
	.target_Y(target2_Y),
	.EnemyX(Enemy12X),
	.EnemyY(Enemy12Y),
	.phase(p12)
	);

	enemy_ammo enemy12_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hit12),
		.ammolevel(6'b000010),
		.BallX(Enemy12X),
		.BallY(Enemy12Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.AmmoX(e12_ammoxsig),
		.AmmoY(e12_ammoysig),
		.flag(flag2)
	);

	//1-3
	
	enemy_level enemylevel1_3 (
	.Reset(Reset_h),
	.frame_clk(VGA_VS),
	.level(level),
	.jetlevel(6'b000010),
	.Enemy_X_Original(Enemy_X3_Original),
	.Enemy_Y_Original(Enemy_Y3_Original),
	.target_Y(target3_Y),
	.EnemyX(Enemy13X),
	.EnemyY(Enemy13Y),
	.phase(p13)
	);

	enemy_ammo enemy13_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hit13),
		.ammolevel(6'b000010),
		.BallX(Enemy13X),
		.BallY(Enemy13Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.AmmoX(e13_ammoxsig),
		.AmmoY(e13_ammoysig),
		.flag(flag3)
	);
	
//////////////////////////////////////////////////////////////////////////
//////////////////////////LEVEL 2 ENEMIES/////////////////////////////////
//////////////////////////////////////////////////////////////////////////

	//2-1
	enemy_level enemylevel2_1 (
	.Reset(Reset_h),
	.frame_clk(VGA_VS),
	.level(level),
	.jetlevel(6'b000100),
	.Enemy_X_Original(Enemy_X1_Original),
	.Enemy_Y_Original(Enemy_Y1_Original),
	.target_Y(target1_Y),
	.EnemyX(Enemy21X),
	.EnemyY(Enemy21Y),
	.phase(p21)
	);

	enemy_ammo enemy21_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hit21),
		.ammolevel(6'b000100),
		.BallX(Enemy21X),
		.BallY(Enemy21Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.AmmoX(e21_ammoxsig),
		.AmmoY(e21_ammoysig),
		.flag(flag4)
	);

	//2-2

	enemy_level enemylevel2_2 (
	.Reset(Reset_h),
	.frame_clk(VGA_VS),
	.level(level),
	.jetlevel(6'b000100),
	.Enemy_X_Original(Enemy_X2_Original),
	.Enemy_Y_Original(Enemy_Y2_Original),
	.target_Y(target2_Y),
	.EnemyX(Enemy22X),
	.EnemyY(Enemy22Y),
	.phase(p22)
	);

	enemy_ammo enemy22_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hit22),
		.ammolevel(6'b000100),
		.BallX(Enemy22X),
		.BallY(Enemy22Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.AmmoX(e22_ammoxsig),
		.AmmoY(e22_ammoysig),
		.flag(flag5)
	);

	//2-3

	enemy_level enemylevel2_3 (
	.Reset(Reset_h),
	.frame_clk(VGA_VS),
	.level(level),
	.jetlevel(6'b000100),
	.Enemy_X_Original(Enemy_X3_Original),
	.Enemy_Y_Original(Enemy_Y3_Original),
	.target_Y(target3_Y),
	.EnemyX(Enemy23X),
	.EnemyY(Enemy23Y),
	.phase(p23)
	);

	enemy_ammo enemy23_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hit23),
		.ammolevel(6'b000100),
		.BallX(Enemy23X),
		.BallY(Enemy23Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.AmmoX(e23_ammoxsig),
		.AmmoY(e23_ammoysig),
		.flag(flag6)
	);
	
	
//////////////////////////////////////////////////////////////////////////
////////////////////////////BOSS//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

logic[9:0] bossam1x, bossam1y, bossam2x, bossam2y, bossam3x, bossam3y;
logic flagboss2, flagboss3;
logic hitboss2, hitboss3;
	
boss final_boss (
	.Reset(Reset_h),
	.frame_clk(VGA_VS),
	.level(level),
	.Enemy_X_Original(boss_X_Original),
	.Enemy_Y_Original(boss_Y_Original),
	.EnemyX(boss_X),
	.EnemyY(boss_Y)
	);

	assign bossam1x = boss_X;
	assign bossam1y = boss_Y + enemyheight;
	
boss_ammo boss1_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hitboss),
		.BallX(boss_X),
		.BallY(boss_Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.Ammo_X_Start(bossam1x),
		.Ammo_Y_Start(bossam1y),
		.jetX(ballxsig),
		.jetY(ballysig),
		.AmmoX(boss_ammoxsig1),
		.AmmoY(boss_ammoysig1),
		.flag(flagboss)
	);
	
	assign bossam2x = boss_X + 50;
	assign bossam2y = boss_Y + enemyheight + 10;

boss_ammo boss2_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hitboss2),
		.BallX(boss_X),
		.BallY(boss_Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.Ammo_X_Start(bossam2x),
		.Ammo_Y_Start(bossam2y),
		.jetX(ballxsig),
		.jetY(ballysig),
		.AmmoX(boss_ammoxsig2),
		.AmmoY(boss_ammoysig2),
		.flag(flagboss2)
	);
	
	assign bossam3x = boss_X - 50;
	assign bossam3y = boss_Y + enemyheight + 10;

boss_ammo boss3_ammo (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.hit(hitboss3),
		.BallX(boss_X),
		.BallY(boss_Y),
		.Ball_W(enemywidth),
		.Ball_H(enemyheight),
		.Ammo_X_Start(bossam3x),
		.Ammo_Y_Start(bossam3y),
		.jetX(ballxsig),
		.jetY(ballysig),
		.AmmoX(boss_ammoxsig3),
		.AmmoY(boss_ammoysig3),
		.flag(flagboss3)
	);
	

fix fix2 (
		.Reset(Reset_h),
		.frame_clk(VGA_VS),
		.level(level),
		.fixX(fixX),
		.fixY(fixY),
		.flagfix(flagfix)
	);
	
	logic flagfix;

	
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

	color_mapper colormap (
		.BallX(ballxsig),
		.BallY(ballysig),
		.AmmoX(ammoxsig),
		.AmmoY(ammoysig),
		.DrawX(drawxsig),
		.DrawY(drawysig),
		.Ball_W(ballwidth),
		.Ball_H(ballheight),
		.Ammo_W(ammowidth),
		.Ammo_H(ammoheight),
		.Enemy11X(Enemy11X), //Level 1-1 Enemy
		.Enemy11Y(Enemy11Y),
		.Enemy12X(Enemy12X), //Level 1-2 Enemy
		.Enemy12Y(Enemy12Y),
		.Enemy13X(Enemy13X), //Level 1-3 Enemy
		.Enemy13Y(Enemy13Y),
		.Enemy21X(Enemy21X), //Level 2-1 Enemy
		.Enemy21Y(Enemy21Y),
		.Enemy22X(Enemy22X), //Level 2-2 Enemy
		.Enemy22Y(Enemy22Y),
		.Enemy23X(Enemy23X), //Level 2-3 Enemy
		.Enemy23Y(Enemy23Y),
		.bossX(boss_X),
		.bossY(boss_Y),
		.Enem_W(enemywidth), //Level 1 & 2 Enemy Dimensions
		.Enem_H(enemyheight),
		.e11_AmmoX(e11_ammoxsig), //Level 1-1 Ammo
		.e11_AmmoY(e11_ammoysig),
		.e12_AmmoX(e12_ammoxsig), //Level 1-2 Ammo
		.e12_AmmoY(e12_ammoysig),
		.e13_AmmoX(e13_ammoxsig), //Level 1-3 Ammo
		.e13_AmmoY(e13_ammoysig),
		.e21_AmmoX(e21_ammoxsig), //Level 2-1 Ammo
		.e21_AmmoY(e21_ammoysig),
		.e22_AmmoX(e22_ammoxsig), //Level 2-2 Ammo
		.e22_AmmoY(e22_ammoysig),
		.e23_AmmoX(e23_ammoxsig), //Level 2-3 Ammo
		.e23_AmmoY(e23_ammoysig),
		.boss_AmmoY(boss_ammoysig),
		.boss_AmmoX(boss_ammoxsig),
		.boss_AmmoY2(boss_ammoysig2),
		.boss_AmmoX2(boss_ammoxsig2),
		.boss_AmmoY3(boss_ammoysig3),
		.boss_AmmoX3(boss_ammoxsig3),
		.e_Ammo_W(e_ammowidth), //Level 1 & 2 Enemy Ammo Dimensions
		.e_Ammo_H(e_ammoheight),
		.fixX(fixX),
		.fixY(fixY),
		.flag(flag),
		.e11_flag(flag1), //Enemy 1-1 Ammo Flag
		.e12_flag(flag2), //Enemy 1-2 Ammo Flag
		.e13_flag(flag3), //Enemy 1-3 Ammo Flag
		.e21_flag(flag4), //Enemy 2-1 Ammo Flag
		.e22_flag(flag5), //Enemy 2-2 Ammo Flag
		.e23_flag(flag6), //Enemy 2-3 Ammo Flag
		.boss_flag(flagboss),
		.boss_flag2(flagboss2),
		.boss_flag3(flagboss3),
		.flagfix(flagfix),
		.phase(phase),
		.p11(p11), //Enemy 1-1 Phase
		.p12(p12), //Enemy 1-2 Phase
		.p13(p13), //Enemy 1-3 Phase
		.p21(p21), //Enemy 2-1 Phase
		.p22(p22), //Enemy 2-2 Phase
		.p23(p23), //Enemy 2-3 Phase
		.vga_clk(VGA_Clk),
		.blank(blank),
		.frame_clk(VGA_VS),
		.reset(Reset_h),
		.keycode(keycode),
		.keycode1(keycode1),
		.keycode2(keycode2),
		.Red(Red),
		.Green(Green),
		.Blue(Blue),
		.current_level(level),
		.hit_11(hit11),
		.hit_12(hit12),
		.hit_13(hit13),
		.hit_21(hit21),
		.hit_22(hit22),
		.hit_23(hit23),
		.hit_boss(hitboss),
		.hit_boss2(hitboss2),
		.hit_boss3(hitboss3),
		.jhit(just_hit)
	);

endmodule
