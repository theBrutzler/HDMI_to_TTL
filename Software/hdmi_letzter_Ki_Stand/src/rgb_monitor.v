// Measures the timing of the parallel RGB source and hands the results
// to the system clock domain once per frame / second.
//
// Lines are delimited by HSYNC edges at least MIN_LINE pclk cycles apart
// (shorter ones are counted as glitches). Frames are delimited by DE: the
// first line with DE after at least MIN_VBLANK lines without DE starts a
// new frame, so the measurement does not depend on VSYNC.
//
// Sync polarity is detected from the duty cycle: the shorter level is
// taken as the active sync pulse.

`default_nettype none

module rgb_monitor #(
	parameter CLK_HZ         = 27000000,
	parameter SAMPLE_FALLING = 1,
	parameter MIN_LINE       = 256,
	parameter MIN_VBLANK     = 4
) (
	input  wire        clk,          // system clock (27 MHz)

	// raw source signals
	input  wire        pclk,
	input  wire        hs_in,
	input  wire        vs_in,
	input  wire        de_in,
	input  wire [23:0] rgb_in,

	// results, clk domain
	output reg         tick,         // one pulse per second after update
	output reg  [31:0] pclk_hz,
	output reg  [15:0] fps,          // DE frames per second
	output reg  [15:0] h_total,      // pclk cycles per line
	output reg  [15:0] v_total,      // lines per frame
	output reg  [15:0] hs_width,     // pclk cycles
	output reg  [15:0] vs_width,     // lines
	output reg         hs_neg,       // 1 = active low
	output reg         vs_neg,
	output reg  [15:0] de_pixels,    // max. DE-high pixels per line
	output reg  [15:0] de_lines,     // lines with DE high per frame
	output reg  [15:0] vs_rises,     // VSYNC rising edges per frame (1 = clean)
	output reg  [15:0] hs_glitches,  // rejected HSYNC edges per frame
	output reg  [15:0] de_start_min, // DE start within the line (pclk after HSYNC edge)
	output reg  [15:0] de_start_max,
	output reg  [23:0] bits_high,    // RGB bits that were 1 during DE in a frame
	output reg         hs_present
);

	// ------------------------------------------------------------------
	// pclk domain
	// ------------------------------------------------------------------

	reg        cap_hs, cap_vs, cap_de;
	reg [23:0] cap_rgb;

	generate
		if (SAMPLE_FALLING) begin : g_cap_neg
			always @(negedge pclk)
				{cap_hs, cap_vs, cap_de, cap_rgb} <= {hs_in, vs_in, de_in, rgb_in};
		end else begin : g_cap_pos
			always @(posedge pclk)
				{cap_hs, cap_vs, cap_de, cap_rgb} <= {hs_in, vs_in, de_in, rgb_in};
		end
	endgenerate

	reg        hs_q = 0, vs_q = 0, de_q = 0, hs_d = 0, vs_d = 0, de_d = 0;
	reg [23:0] rgb_q = 0;

	always @(posedge pclk) begin
		hs_q  <= cap_hs;
		vs_q  <= cap_vs;
		de_q  <= cap_de;
		rgb_q <= cap_rgb;
		hs_d  <= hs_q;
		vs_d  <= vs_q;
		de_d  <= de_q;
	end

	reg [2:0] pdiv = 0;
	always @(posedge pclk)
		pdiv <= pdiv + 1'b1;

	reg [15:0] hcnt = 0, hhigh = 0, decnt = 0;

	wire hs_rise   = hs_q && !hs_d;
	wire vs_rise   = vs_q && !vs_d;
	wire line_end  = hs_rise && hcnt >= MIN_LINE;
	wire hs_glitch = hs_rise && hcnt < MIN_LINE;

	wire has_de      = decnt != 0;
	reg  [7:0] blank_cnt = 0;
	wire frame_start = line_end && has_de && blank_cnt >= MIN_VBLANK;

	// per frame
	reg [15:0] lines = 0, vhigh = 0, delines = 0, depx_max = 0;
	reg [15:0] vsr_cnt = 0, gl_cnt = 0;
	reg [15:0] dex_min = 16'hFFFF, dex_max = 0;
	reg [23:0] mask = 0;

	// published results, stable for a frame after fr_toggle
	reg [15:0] r_htotal = 0, r_hwidth = 0, r_vtotal = 0, r_vwidth = 0;
	reg [15:0] r_depx = 0, r_delines = 0, r_vsr = 0, r_gl = 0;
	reg [15:0] r_dex_min = 0, r_dex_max = 0;
	reg [23:0] r_mask = 0;
	reg        r_hneg = 0, r_vneg = 0;

	wire de_rise = de_q && !de_d;
	reg        fr_toggle = 0, ln_toggle = 0;

	wire hneg = hhigh > (hcnt >> 1);
	wire vneg = vhigh > (lines >> 1);

	always @(posedge pclk) begin
		if (line_end) begin
			hcnt      <= 1;
			hhigh     <= 1;
			decnt     <= de_q;
			ln_toggle <= !ln_toggle;
			blank_cnt <= has_de ? 8'd0 : (&blank_cnt) ? blank_cnt : blank_cnt + 1'b1;
		end else begin
			if (!(&hcnt))
				hcnt <= hcnt + 1'b1;
			if (!(&hhigh))
				hhigh <= hhigh + hs_q;
			if (!(&decnt))
				decnt <= decnt + de_q;
		end

		if (frame_start) begin
			// the line ending now is the first line of the new frame
			r_htotal  <= hcnt;
			r_hneg    <= hneg;
			r_hwidth  <= hneg ? hcnt - hhigh : hhigh;
			r_vtotal  <= lines;
			r_vneg    <= vneg;
			r_vwidth  <= vneg ? lines - vhigh : vhigh;
			r_depx    <= depx_max;
			r_delines <= delines;
			r_vsr     <= vsr_cnt;
			r_gl      <= gl_cnt;
			r_dex_min <= dex_min;
			r_dex_max <= dex_max;
			r_mask    <= mask;
			fr_toggle <= !fr_toggle;

			lines    <= 1;
			vhigh    <= vs_q;
			delines  <= 1;
			depx_max <= decnt;
			vsr_cnt  <= vs_rise;
			gl_cnt   <= hs_glitch;
			dex_min  <= 16'hFFFF;
			dex_max  <= 0;
			mask     <= 0;
		end else begin
			if (de_rise) begin
				if (hcnt < dex_min)
					dex_min <= hcnt;
				if (hcnt > dex_max)
					dex_max <= hcnt;
			end
			if (de_q)
				mask <= mask | rgb_q;
			if (line_end) begin
				lines   <= lines + 1'b1;
				vhigh   <= vhigh + vs_q;
				delines <= delines + has_de;
				if (decnt > depx_max)
					depx_max <= decnt;
			end
			if (vs_rise && !(&vsr_cnt))
				vsr_cnt <= vsr_cnt + 1'b1;
			if (hs_glitch && !(&gl_cnt))
				gl_cnt <= gl_cnt + 1'b1;
		end
	end

	// ------------------------------------------------------------------
	// clk domain
	// ------------------------------------------------------------------

	reg [2:0] s_pdiv = 0, s_fr = 0, s_ln = 0;

	always @(posedge clk) begin
		s_pdiv <= {s_pdiv[1:0], pdiv[2]};
		s_fr   <= {s_fr[1:0], fr_toggle};
		s_ln   <= {s_ln[1:0], ln_toggle};
	end

	wire pdiv_rise = s_pdiv[1] && !s_pdiv[2];
	wire fr_edge   = s_fr[1] ^ s_fr[2];
	wire ln_edge   = s_ln[1] ^ s_ln[2];

	reg [24:0] sec_cnt = 0;
	reg [28:0] pcnt = 0;
	reg [15:0] fcnt = 0;
	reg        lseen = 0;

	initial begin
		tick = 0; pclk_hz = 0; fps = 0; hs_present = 0;
		h_total = 0; v_total = 0; hs_width = 0; vs_width = 0;
		hs_neg = 0; vs_neg = 0; de_pixels = 0; de_lines = 0;
		vs_rises = 0; hs_glitches = 0;
		de_start_min = 0; de_start_max = 0; bits_high = 0;
	end

	always @(posedge clk) begin
		tick <= 0;

		if (pdiv_rise)
			pcnt <= pcnt + 1'b1;
		if (ln_edge)
			lseen <= 1;
		if (fr_edge && !(&fcnt))
			fcnt <= fcnt + 1'b1;

		if (sec_cnt == CLK_HZ - 1) begin
			sec_cnt    <= 0;
			pclk_hz    <= {pcnt, 3'b000};
			fps        <= fcnt;
			hs_present <= lseen;
			pcnt       <= 0;
			fcnt       <= 0;
			lseen      <= 0;
			tick       <= 1;
			if (fcnt == 0) begin
				h_total     <= 0;
				v_total     <= 0;
				hs_width    <= 0;
				vs_width    <= 0;
				hs_neg      <= 0;
				vs_neg      <= 0;
				de_pixels   <= 0;
				de_lines    <= 0;
				vs_rises    <= 0;
				hs_glitches <= 0;
				de_start_min <= 0;
				de_start_max <= 0;
				bits_high    <= 0;
			end
		end else begin
			sec_cnt <= sec_cnt + 1'b1;
		end

		// r_* changed together with fr_toggle and are stable for a frame
		if (fr_edge) begin
			h_total     <= r_htotal;
			v_total     <= r_vtotal;
			hs_width    <= r_hwidth;
			vs_width    <= r_vwidth;
			hs_neg      <= r_hneg;
			vs_neg      <= r_vneg;
			de_pixels   <= r_depx;
			de_lines    <= r_delines;
			vs_rises    <= r_vsr;
			hs_glitches <= r_gl;
			de_start_min <= r_dex_min;
			de_start_max <= r_dex_max;
			bits_high    <= r_mask;
		end
	end

endmodule

`default_nettype wire
