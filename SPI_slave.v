module SPI_SLAVE (MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

// parameters declaration
parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter WRITE = 3'b010;
parameter READ_ADD = 3'b011;
parameter READ_DATA = 3'b100;

// inputs & outputs declaration
input MOSI,SS_n,clk,rst_n,tx_valid;      
input [7:0] tx_data;
output reg MISO,rx_valid;
output reg [9:0] rx_data;

// Declaration for next state & current state
reg [2:0] cs,ns;

// this internal signal used to distinguish between read_address state & read_data state (initially = 0)
reg read_diff;  
 
reg [3:0] MISO_counter;    // specified for converting tx_data into MISO
reg [3:0] MOSI_counter;   // specified for converting MOSI into rx_data 

// Always block for next state logic
always @ (*) begin
	case (cs)
		IDLE : begin
			if(SS_n)
				ns = IDLE;
			else 
				ns = CHK_CMD;
		end
		CHK_CMD : begin
			if (SS_n)
				ns = IDLE;
			else if (!MOSI)
				ns = WRITE;
			else if (!read_diff)
				ns = READ_ADD;
			else
				ns = READ_DATA;
		end
		WRITE : begin
			if (SS_n)
				ns = IDLE;
			else 
				ns = WRITE;
		end
		READ_ADD : begin
			if(SS_n)
				ns = IDLE;
			else 
				ns = READ_ADD;
		end
		READ_DATA : begin
			if(SS_n)
				ns = IDLE;
			else 
				ns = READ_DATA;
		end
		default : ns = IDLE;
	endcase
end

// Always block for state memory
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
		cs <= IDLE;
	else 
		cs <= ns;
end

// Always block for output signals 
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rx_valid <= 0;
		rx_data <= 0;
		MISO <= 0;
		read_diff <= 0;
		MOSI_counter <= 0;
		MISO_counter <= 0;
	end
	else begin
		case(cs)
			IDLE : begin
				rx_valid <= 0;
				MOSI_counter <= 0;
				MISO_counter <= 0;
				MISO <= 0;
			end
			CHK_CMD : begin
				MOSI_counter <= 10;
				MISO_counter <= 8;  
			end
			WRITE : begin
				if(MOSI_counter > 0) begin
					rx_data[MOSI_counter-1] <= MOSI;
					MOSI_counter <= MOSI_counter - 1;
				end
				else begin
					rx_valid <= 1;
				end
			end
			READ_ADD : begin
				if(MOSI_counter > 0) begin
					rx_data[MOSI_counter-1] <= MOSI;
					MOSI_counter <= MOSI_counter - 1;
				end
				else begin
					rx_valid <= 1;
					read_diff <= 1;
				end
			end
			READ_DATA : begin
				if(tx_valid) begin
					if(MISO_counter > 0) begin
						MISO <= tx_data[MISO_counter-1];
						MISO_counter <= MISO_counter - 1;
					end
				end
				else begin
					if (MOSI_counter > 0) begin
						rx_data[MOSI_counter-1] <= MOSI;
						MOSI_counter <= MOSI_counter - 1;
					end
					else begin
						rx_valid <= 1;
						read_diff <= 0;
					end
				end
			end
			default : begin
				rx_valid <= 0;
				rx_data <= 0;
				MISO <= 0;
				read_diff <= 0;
			end
		endcase
	end
end

endmodule