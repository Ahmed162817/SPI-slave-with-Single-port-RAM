module RAM (din,clk,rst_n,rx_valid,dout,tx_valid);

// parameters Declaration
parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;

// inputs & outputs Declaration
input clk,rst_n,rx_valid;
input [9:0] din;
output reg [7:0] dout;
output reg tx_valid;

// RAM Declaration
reg [7:0] RAM [0:MEM_DEPTH-1];

//internal read & write addresses
reg [ADDR_SIZE-1:0] wr_addr;
reg [ADDR_SIZE-1:0] rd_addr;

// Always block for dout signal
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		dout <= 0;
		rd_addr <= 0;
		wr_addr <= 0;
	end
	else if(rx_valid) begin
		case({din[9],din[8]})
			2'b00 : wr_addr <= din[7:0];
			2'b01 : RAM[wr_addr] <= din[7:0];
			2'b10 : rd_addr <= din[7:0];
			2'b11 : dout <= RAM[rd_addr];	
		endcase
	end
end

// Always block for tx_valid signal
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
		tx_valid <= 0;
	else if (rx_valid == 1 && din[9:8] == 2'b11)
		tx_valid <= 1;
	else
		tx_valid <= 0;
end

endmodule