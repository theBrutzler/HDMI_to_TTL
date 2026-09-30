// 800x480 test pattern with adjustable line length (h_total).
//
// Color bars, grayscale ramp in the lower quarter, 1 px frame at the
// picture edge and a box moving by 3 px per frame (shows frame updates).
// Border and box use the inverted background color.

`default_nettype none

module test_pattern #(
	parameter H_ACTIVE      = 800,
	parameter V_ACTIVE      = 480,
	parameter HS_WIDTH      = 96,
	parameter H_START       = 240,   // HSYNC + back porch
	parameter V_TOTAL       = 525,
	parameter VS_LINES      = 3,
	parameter V_START       = 35,    // VSYNC + back porch (lines)
	parameter HS_ACTIVE_LOW = 1,
	parameter VS_ACTIVE_LOW = 1
) (
	input  wire        clk,
	input  wire        resetn,
	input  wire [12:0] h_total,
	output reg  [23:0] rgb,          // {R, G, B}
	output reg         de,
	output reg         hs,
	output reg         vs
);
	reg [12:0] hc;
	reg [9:0]  vc;
	reg [7:0]  frame;

	always @(posedge clk) begin
		if (!resetn) begin
			hc    <= 0;
			vc    <= 0;
			frame <= 0;
		end else if (hc >= h_total - 1'b1) begin
			hc <= 0;
			if (vc == V_TOTAL - 1) begin
				vc    <= 0;
				frame <= frame + 1'b1;
			end else begin
				vc <= vc + 1'b1;
			end
		end else begin
			hc <= hc + 1'b1;
		end
	end

	wire [12:0] x  = hc - H_START;
	wire [9:0]  y  = vc - V_START;
	wire [9:0]  bx = {frame, 1'b0} + frame;   // 3 px per frame

	wire active = hc >= H_START && hc < H_START + H_ACTIVE &&
	              vc >= V_START && vc < V_START + V_ACTIVE;

	reg [23:0] bg;

	always @(*) begin
		if (y >= V_ACTIVE * 3 / 4)
			bg = {3{x[9:2] + x[9:4]}};           // grayscale ramp
		else if (x < 100) bg = 24'hFFFFFF;       // white
		else if (x < 200) bg = 24'hFFFF00;       // yellow
		else if (x < 300) bg = 24'h00FFFF;       // cyan
		else if (x < 400) bg = 24'h00FF00;       // green
		else if (x < 500) bg = 24'hFF00FF;       // magenta
		else if (x < 600) bg = 24'hFF0000;       // red
		else if (x < 700) bg = 24'h0000FF;       // blue
		else              bg = 24'h000000;       // black
	end

	wire border = x == 0 || x == H_ACTIVE - 1 || y == 0 || y == V_ACTIVE - 1;
	wire box    = x >= bx && x < bx + 32 && y >= 224 && y < 256;

	always @(posedge clk) begin
		rgb <= !active ? 24'd0 : (border || box) ? ~bg : bg;
		de  <= active;
		hs  <= (hc < HS_WIDTH) ^ (HS_ACTIVE_LOW != 0);
		vs  <= (vc < VS_LINES) ^ (VS_ACTIVE_LOW != 0);
	end

endmodule

`default_nettype wire
