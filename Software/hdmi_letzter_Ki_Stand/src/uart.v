// Minimal 8N1 UART transmitter and receiver.

`default_nettype none

module uart_tx #(
	parameter DIV = 234          // clock cycles per bit (27 MHz / 115200)
) (
	input  wire       clk,
	input  wire       start,
	input  wire [7:0] data,
	output reg        tx,
	output reg        busy
);
	reg [8:0]  sh;
	reg [15:0] cnt;
	reg [3:0]  n;

	initial begin
		tx   = 1;
		busy = 0;
	end

	always @(posedge clk) begin
		if (!busy) begin
			if (start) begin
				sh   <= {1'b1, data};    // stop bit, data
				tx   <= 0;               // start bit
				n    <= 0;
				cnt  <= DIV - 1;
				busy <= 1;
			end
		end else if (cnt != 0) begin
			cnt <= cnt - 1'b1;
		end else if (n == 9) begin
			busy <= 0;
		end else begin
			tx  <= sh[0];
			sh  <= sh >> 1;
			n   <= n + 1'b1;
			cnt <= DIV - 1;
		end
	end
endmodule

module uart_rx #(
	parameter DIV = 234
) (
	input  wire       clk,
	input  wire       rx,
	output reg        valid,
	output reg  [7:0] data
);
	reg [1:0]  rx_q = 2'b11;
	reg [15:0] cnt;
	reg [3:0]  n;
	reg        busy = 0;

	always @(posedge clk) begin
		rx_q  <= {rx_q[0], rx};
		valid <= 0;

		if (!busy) begin
			if (!rx_q[1]) begin          // start bit edge
				busy <= 1;
				cnt  <= DIV / 2;         // sample in the middle of the bit
				n    <= 0;
			end
		end else if (cnt != 0) begin
			cnt <= cnt - 1'b1;
		end else begin
			cnt <= DIV - 1;
			if (n == 0) begin
				if (rx_q[1])
					busy <= 0;           // glitch, not a start bit
				else
					n <= 1;
			end else if (n <= 8) begin
				data <= {rx_q[1], data[7:1]};
				n    <= n + 1'b1;
			end else begin
				busy  <= 0;
				valid <= rx_q[1];        // valid stop bit
			end
		end
	end
endmodule

`default_nettype wire
