// UART debug console (115200 8N1).
//
// Prints one status line per second. Commands:
//   0  normal operation (RGB source)
//   1  test pattern, ~60 Hz
//   2  test pattern, ~30 Hz
//   3  test pattern, ~43 Hz (like the 24 MHz, 1056 x 525 source)
//   4  test pattern, ~43 Hz, but clocked from the source PCLK
//   ?  help

`default_nettype none

module debug_console #(
	parameter CLK_HZ = 27000000,
	parameter BAUD   = 115200
) (
	input  wire        clk,
	input  wire        uart_rx,
	output wire        uart_tx,

	input  wire        tick,
	input  wire [31:0] pclk_hz,
	input  wire [15:0] fps,
	input  wire [15:0] h_total,
	input  wire [15:0] v_total,
	input  wire [15:0] hs_width,
	input  wire [15:0] vs_width,
	input  wire        hs_neg,
	input  wire        vs_neg,
	input  wire [15:0] de_pixels,
	input  wire [15:0] de_lines,
	input  wire [15:0] vs_rises,
	input  wire [15:0] hs_glitches,
	input  wire [15:0] resyncs,
	input  wire        pll_lock,

	output reg  [2:0]  mode
);
	localparam DIV = CLK_HZ / BAUD;

	// ------------------------------------------------------------------
	// UART
	// ------------------------------------------------------------------

	reg        tx_start = 0;
	reg  [7:0] tx_data;
	wire       tx_busy;
	wire       rx_valid;
	wire [7:0] rx_data;

	uart_tx #(.DIV(DIV)) u_tx (
		.clk(clk),
		.start(tx_start),
		.data(tx_data),
		.tx(uart_tx),
		.busy(tx_busy)
	);

	uart_rx #(.DIV(DIV)) u_rx (
		.clk(clk),
		.rx(uart_rx),
		.valid(rx_valid),
		.data(rx_data)
	);

	// ------------------------------------------------------------------
	// Messages: right-aligned, zero bytes are skipped.
	// 8'h80+n prints number n, 8'h90/8'h91 print HS/VS polarity.
	// ------------------------------------------------------------------

	localparam MSG_LEN = 80;

	localparam [8*MSG_LEN-1:0] MSG_STATUS = {
		"PCLK=", 8'h80, " FPS=", 8'h81, " HT=", 8'h82, " VT=", 8'h83,
		" HS=", 8'h90, 8'h84, " VS=", 8'h91, 8'h85,
		" DE=", 8'h86, "x", 8'h87, " VSR=", 8'h8a, " HSGL=", 8'h8b,
		" RSY=", 8'h8c, " LOCK=", 8'h88, " MODE=", 8'h89,
		8'h0d, 8'h0a
	};

	localparam [8*MSG_LEN-1:0] MSG_HELP = {
		8'h0d, 8'h0a,
		"0=Quelle 1=T60Hz 2=T30Hz 3=T43Hz 4=T43Hz@PCLK ?=Hilfe",
		8'h0d, 8'h0a
	};

	reg        sel;                  // 0: status, 1: help
	reg  [6:0] idx;

	wire [8*MSG_LEN-1:0] msg = sel ? MSG_HELP : MSG_STATUS;
	wire [7:0]           ch  = msg[8*(MSG_LEN-1-idx) +: 8];

	function [31:0] num_value(input [3:0] n);
		case (n)
			4'd0:    num_value = pclk_hz;
			4'd1:    num_value = fps;
			4'd2:    num_value = h_total;
			4'd3:    num_value = v_total;
			4'd4:    num_value = hs_width;
			4'd5:    num_value = vs_width;
			4'd6:    num_value = de_pixels;
			4'd7:    num_value = de_lines;
			4'd8:    num_value = pll_lock;
			4'd9:    num_value = mode;
			4'd10:   num_value = vs_rises;
			4'd11:   num_value = hs_glitches;
			4'd12:   num_value = resyncs;
			default: num_value = 0;
		endcase
	endfunction

	function [31:0] next_pow(input [31:0] p);
		case (p)
			32'd1000000000: next_pow = 32'd100000000;
			32'd100000000:  next_pow = 32'd10000000;
			32'd10000000:   next_pow = 32'd1000000;
			32'd1000000:    next_pow = 32'd100000;
			32'd100000:     next_pow = 32'd10000;
			32'd10000:      next_pow = 32'd1000;
			32'd1000:       next_pow = 32'd100;
			32'd100:        next_pow = 32'd10;
			default:        next_pow = 32'd1;
		endcase
	endfunction

	// ------------------------------------------------------------------
	// Printer / command FSM
	// ------------------------------------------------------------------

	localparam S_IDLE      = 4'd0,
	           S_CHAR      = 4'd1,
	           S_NEXT      = 4'd2,
	           S_NUM_SUB   = 4'd3,
	           S_NUM_EMIT  = 4'd4,
	           S_NUM_NEXT  = 4'd5,
	           S_SEND      = 4'd6,
	           S_SEND_WAIT = 4'd7;

	reg [3:0]  state = S_IDLE;
	reg [3:0]  ret;
	reg [7:0]  out_c;
	reg [31:0] nval, pow;
	reg [3:0]  digit;
	reg        started;

	reg help_pending = 1;            // print help once after start
	reg status_pending = 0;

	initial mode = 0;

	always @(posedge clk) begin
		if (tick)
			status_pending <= 1;

		if (rx_valid) begin
			case (rx_data)
				"0", "1", "2", "3", "4": mode <= rx_data[2:0];
				"?":                help_pending <= 1;
				default: ;
			endcase
		end

		case (state)
			S_IDLE: begin
				idx <= 0;
				if (help_pending) begin
					help_pending <= 0;
					sel   <= 1;
					state <= S_CHAR;
				end else if (status_pending) begin
					status_pending <= 0;
					sel   <= 0;
					state <= S_CHAR;
				end
			end

			S_CHAR: begin
				if (ch == 8'h00) begin
					state <= S_NEXT;
				end else if (ch[7] && ch[4]) begin
					out_c <= (ch[0] ? vs_neg : hs_neg) ? "-" : "+";
					ret   <= S_NEXT;
					state <= S_SEND;
				end else if (ch[7]) begin
					nval    <= num_value(ch[3:0]);
					pow     <= 32'd1000000000;
					digit   <= 0;
					started <= 0;
					state   <= S_NUM_SUB;
				end else begin
					out_c <= ch;
					ret   <= S_NEXT;
					state <= S_SEND;
				end
			end

			S_NEXT: begin
				if (idx == MSG_LEN - 1) begin
					state <= S_IDLE;
				end else begin
					idx   <= idx + 1'b1;
					state <= S_CHAR;
				end
			end

			S_NUM_SUB: begin
				if (nval >= pow) begin
					nval  <= nval - pow;
					digit <= digit + 1'b1;
				end else begin
					state <= S_NUM_EMIT;
				end
			end

			S_NUM_EMIT: begin
				if (digit != 0 || started || pow == 1) begin
					out_c   <= "0" + digit;
					started <= 1;
					ret     <= S_NUM_NEXT;
					state   <= S_SEND;
				end else begin
					state <= S_NUM_NEXT;
				end
			end

			S_NUM_NEXT: begin
				digit <= 0;
				if (pow == 1) begin
					state <= S_NEXT;
				end else begin
					pow   <= next_pow(pow);
					state <= S_NUM_SUB;
				end
			end

			S_SEND: begin
				if (!tx_busy) begin
					tx_data  <= out_c;
					tx_start <= 1;
					state    <= S_SEND_WAIT;
				end
			end

			S_SEND_WAIT: begin
				tx_start <= 0;
				state    <= ret;
			end

			default: state <= S_IDLE;
		endcase
	end

endmodule

`default_nettype wire
