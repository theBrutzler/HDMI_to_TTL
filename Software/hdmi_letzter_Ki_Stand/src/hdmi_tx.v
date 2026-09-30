// DVI/HDMI transmitter: 3x TMDS encoder, 10:1 serializer, LVDS outputs.
// clk_5x must be 5x clk_pixel (OSER10 serializes on both edges).

`default_nettype none

module hdmi_tx (
	input  wire        clk_pixel,
	input  wire        clk_5x,
	input  wire        resetn,

	input  wire [23:0] rgb,      // {R, G, B}
	input  wire        de,       // active high
	input  wire        hs,       // sent as-is (polarity chosen upstream)
	input  wire        vs,

	output wire        tmds_clk_n,
	output wire        tmds_clk_p,
	output wire [2:0]  tmds_d_n,
	output wire [2:0]  tmds_d_p
);
	wire [9:0] enc_b, enc_g, enc_r;

	// channel 0 (blue) carries HSYNC/VSYNC during blanking
	svo_tmds u_tmds_b (
		.clk(clk_pixel),
		.resetn(resetn),
		.de(de),
		.ctrl({vs, hs}),
		.din(rgb[7:0]),
		.dout(enc_b)
	);

	svo_tmds u_tmds_g (
		.clk(clk_pixel),
		.resetn(resetn),
		.de(de),
		.ctrl(2'b00),
		.din(rgb[15:8]),
		.dout(enc_g)
	);

	svo_tmds u_tmds_r (
		.clk(clk_pixel),
		.resetn(resetn),
		.de(de),
		.ctrl(2'b00),
		.din(rgb[23:16]),
		.dout(enc_r)
	);

	wire [2:0] tmds_d;

	OSER10 u_ser [2:0] (
		.Q(tmds_d),
		.D0({enc_r[0], enc_g[0], enc_b[0]}),
		.D1({enc_r[1], enc_g[1], enc_b[1]}),
		.D2({enc_r[2], enc_g[2], enc_b[2]}),
		.D3({enc_r[3], enc_g[3], enc_b[3]}),
		.D4({enc_r[4], enc_g[4], enc_b[4]}),
		.D5({enc_r[5], enc_g[5], enc_b[5]}),
		.D6({enc_r[6], enc_g[6], enc_b[6]}),
		.D7({enc_r[7], enc_g[7], enc_b[7]}),
		.D8({enc_r[8], enc_g[8], enc_b[8]}),
		.D9({enc_r[9], enc_g[9], enc_b[9]}),
		.PCLK(clk_pixel),
		.FCLK(clk_5x),
		.RESET(~resetn)
	);

	ELVDS_OBUF u_obuf [3:0] (
		.I({clk_pixel, tmds_d}),
		.O({tmds_clk_p, tmds_d_p}),
		.OB({tmds_clk_n, tmds_d_n})
	);

endmodule

`default_nettype wire
