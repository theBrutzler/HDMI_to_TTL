// this code is KI generated
// 24-bit parallel RGB (800x480) -> HDMI converter for Tang Nano 9K.
//
// Clocking: the output runs on the on-board oscillator (27 MHz -> 24 MHz
// -> x15/2 = 180 MHz serial clock, /5 = 36 MHz pixel clock), independent
// of the source PCLK (which proved unusable as HDMI clock). The source is
// decoupled by a multi-line buffer; the output frame follows the source
// frame, so the frame rate of the source is kept.
//
// Test modes (UART command 1..3): test pattern instead of the source image.
// Mode 4 (diagnostic): test pattern with the HDMI clock from source PCLK.
// See debug_console.v.
//
// LEDs (on = low): 0 input enable, 1 PCLK present, 2 PLL locked,
//                  3 HSYNC present, 4 frames (via DE) present, 5 test mode

`default_nettype none

module top (
	input  wire       clk,        // 27 MHz on-board oscillator
	input  wire       resetn,     // push button, active low

	// parallel RGB input
	input  wire       rgb_pclk,
	input  wire       rgb_hs,
	input  wire       rgb_vs,
	input  wire       rgb_de,
	input  wire [7:0] rgb_r,
	input  wire [7:0] rgb_g,
	input  wire [7:0] rgb_b,

	// enable for the input buffer IC, high once the FPGA is running
	output reg        rgb_en,

	// debug
	input  wire       uart_rx,
	output wire       uart_tx,
	output wire [5:0] led,

	output wire       tmds_clk_n,
	output wire       tmds_clk_p,
	output wire [2:0] tmds_d_n,
	output wire [2:0] tmds_d_p
);

	localparam HS_ACTIVE_LOW  = 1;
	localparam VS_ACTIVE_LOW  = 1;
	localparam SAMPLE_FALLING = 1;   // input sampling edge of PCLK

	// ------------------------------------------------------------------
	// Input buffer enable (27 MHz domain, independent of PCLK, since PCLK
	// may itself pass through the buffer IC). ~39 ms after start/reset.
	// ------------------------------------------------------------------

	reg [1:0]  resetn_q = 0;
	reg [19:0] en_cnt = 0;

	initial rgb_en = 0;

	always @(posedge clk) begin
		resetn_q <= {resetn_q[0], resetn};
		if (!resetn_q[1]) begin
			en_cnt <= 0;
			rgb_en <= 0;
		end else if (!rgb_en) begin
			en_cnt <= en_cnt + 1'b1;
			if (&en_cnt)
				rgb_en <= 1;
		end
	end

	// ------------------------------------------------------------------
	// Source monitor + UART console (27 MHz domain)
	// ------------------------------------------------------------------

	wire        mon_tick;
	wire [31:0] mon_pclk_hz;
	wire [15:0] mon_fps, mon_h_total, mon_v_total, mon_hs_width, mon_vs_width;
	wire [15:0] mon_de_pixels, mon_de_lines, mon_vs_rises, mon_hs_glitches;
	wire        mon_hs_neg, mon_vs_neg, mon_hs_present;
	wire [2:0]  mode;
	wire        pll_lock;
	wire        conv_resync_toggle;

	// frame re-alignments per second (clk_p -> clk domain)
	reg [2:0]  rsy_sync = 0;
	reg [15:0] rsy_cnt = 0, rsy_per_sec = 0;

	always @(posedge clk) begin
		rsy_sync <= {rsy_sync[1:0], conv_resync_toggle};
		if (mon_tick) begin
			rsy_per_sec <= rsy_cnt;
			rsy_cnt     <= 0;
		end else if ((rsy_sync[2] ^ rsy_sync[1]) && !(&rsy_cnt)) begin
			rsy_cnt <= rsy_cnt + 1'b1;
		end
	end

	rgb_monitor #(.CLK_HZ(27000000), .SAMPLE_FALLING(SAMPLE_FALLING)) u_mon (
		.clk(clk),
		.pclk(rgb_pclk),
		.hs_in(rgb_hs),
		.vs_in(rgb_vs),
		.de_in(rgb_de),
		.tick(mon_tick),
		.pclk_hz(mon_pclk_hz),
		.fps(mon_fps),
		.h_total(mon_h_total),
		.v_total(mon_v_total),
		.hs_width(mon_hs_width),
		.vs_width(mon_vs_width),
		.hs_neg(mon_hs_neg),
		.vs_neg(mon_vs_neg),
		.de_pixels(mon_de_pixels),
		.de_lines(mon_de_lines),
		.vs_rises(mon_vs_rises),
		.hs_glitches(mon_hs_glitches),
		.hs_present(mon_hs_present)
	);

	debug_console #(.CLK_HZ(27000000), .BAUD(115200)) u_console (
		.clk(clk),
		.uart_rx(uart_rx),
		.uart_tx(uart_tx),
		.tick(mon_tick),
		.pclk_hz(mon_pclk_hz),
		.fps(mon_fps),
		.h_total(mon_h_total),
		.v_total(mon_v_total),
		.hs_width(mon_hs_width),
		.vs_width(mon_vs_width),
		.hs_neg(mon_hs_neg),
		.vs_neg(mon_vs_neg),
		.de_pixels(mon_de_pixels),
		.de_lines(mon_de_lines),
		.vs_rises(mon_vs_rises),
		.hs_glitches(mon_hs_glitches),
		.resyncs(rsy_per_sec),
		.pll_lock(pll_lock),
		.mode(mode)
	);

	wire test_mode = mode != 3'd0;
	wire pclk_mode = mode == 3'd4;   // diagnostic: HDMI clock from source PCLK

	assign led = ~{test_mode, mon_fps != 0, mon_hs_present, pll_lock,
	               mon_pclk_hz != 0, rgb_en};

	// ------------------------------------------------------------------
	// Output clocks: 24 MHz reference from the on-board oscillator
	// (mode 4: source PCLK)
	// ------------------------------------------------------------------

	wire clk_ref24;

	Gowin_rPLL_test u_pll_test (
		.clkin(clk),
		.clkoutd3(clk_ref24),
		.lock()
	);

	// switching glitches only make the PLL re-lock, which resets the output
	wire pll_clkin = pclk_mode ? rgb_pclk : clk_ref24;

	wire clk_p5;     // 5x pixel clock (serializer)
	wire clk_p;      // output pixel clock

	Gowin_rPLL u_pll (
		.clkin(pll_clkin),
		.clkout(clk_p5),
		.lock(pll_lock)
	);

	Gowin_CLKDIV u_div_5 (
		.clkout(clk_p),
		.hclkin(clk_p5),
		.resetn(pll_lock)
	);

	wire sys_resetn;

	Reset_Sync u_reset_sync (
		.resetn(sys_resetn),
		.ext_reset(resetn & pll_lock & rgb_en),
		.clk(clk_p)
	);

	// ------------------------------------------------------------------
	// Line buffer, test pattern, HDMI output
	// ------------------------------------------------------------------

	wire [23:0] vid_rgb;
	wire        vid_de, vid_hs, vid_vs;

	rgb_line_converter #(
		.H_ACTIVE(800),
		.V_ACTIVE(480),
		.HS_ACTIVE_LOW(HS_ACTIVE_LOW),
		.VS_ACTIVE_LOW(VS_ACTIVE_LOW),
		.DE_ACTIVE_LOW(0),
		.SAMPLE_FALLING(SAMPLE_FALLING),
		.OUT_H_TOTAL(1579)   // source line 1056 / 24.076 MHz = 43.86 us @ 36 MHz
	) u_conv (
		.pclk(rgb_pclk),
		.rgb_in({rgb_r, rgb_g, rgb_b}),
		.de_in(rgb_de),
		.hs_in(rgb_hs),

		.clk_out(clk_p),
		.resetn_out(sys_resetn),
		.rgb_out(vid_rgb),
		.de_out(vid_de),
		.hs_out(vid_hs),
		.vs_out(vid_vs),
		.resync_toggle(conv_resync_toggle)
	);

	reg [2:0] mode_p1, mode_p;

	always @(posedge clk_p) begin
		mode_p1 <= mode;
		mode_p  <= mode_p1;
	end

	// output line length at 36 MHz with 525 lines:
	// 1143 -> 60 Hz, 2286 -> 30 Hz, 1584 -> 43.3 Hz (= 1.5 x 1056 @ 24 MHz)
	wire [12:0] tp_h_total = mode_p == 3'd1 ? 13'd1143 :
	                         mode_p == 3'd2 ? 13'd2286 : 13'd1584;

	wire [23:0] tp_rgb;
	wire        tp_de, tp_hs, tp_vs;

	test_pattern #(
		.HS_ACTIVE_LOW(HS_ACTIVE_LOW),
		.VS_ACTIVE_LOW(VS_ACTIVE_LOW)
	) u_tp (
		.clk(clk_p),
		.resetn(sys_resetn),
		.h_total(tp_h_total),
		.rgb(tp_rgb),
		.de(tp_de),
		.hs(tp_hs),
		.vs(tp_vs)
	);

	wire test_p = mode_p != 3'd0;

	hdmi_tx u_hdmi (
		.clk_pixel(clk_p),
		.clk_5x(clk_p5),
		.resetn(sys_resetn),
		.rgb(test_p ? tp_rgb : vid_rgb),
		.de(test_p ? tp_de : vid_de),
		.hs(test_p ? tp_hs : vid_hs),
		.vs(test_p ? tp_vs : vid_vs),
		.tmds_clk_n(tmds_clk_n),
		.tmds_clk_p(tmds_clk_p),
		.tmds_d_n(tmds_d_n),
		.tmds_d_p(tmds_d_p)
	);

endmodule

module Reset_Sync (
	input  wire clk,
	input  wire ext_reset,
	output wire resetn
);

	reg [3:0] reset_cnt = 0;

	always @(posedge clk or negedge ext_reset) begin
		if (~ext_reset)
			reset_cnt <= 4'b0;
		else
			reset_cnt <= reset_cnt + !resetn;
	end

	assign resetn = &reset_cnt;

endmodule

`default_nettype wire
