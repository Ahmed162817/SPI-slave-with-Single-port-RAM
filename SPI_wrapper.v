module SPI_wrapper (MOSI,MISO,SS_n,clk,rst_n);

// input & output Declaration
input MOSI,SS_n,clk,rst_n;
output MISO;

// internal signals for rx_data & tx_data & rx_valid & tx_valid
wire [9:0] rx_data;
wire rx_valid,tx_valid;
wire [7:0] tx_data;

// SPI module instantiation
SPI_SLAVE slave_instance (.MOSI(MOSI),.MISO(MISO),.SS_n(SS_n),.clk(clk),.rst_n(rst_n),.rx_data(rx_data),.rx_valid(rx_valid),.tx_data(tx_data),.tx_valid(tx_valid));

// RAM module instantiation
RAM RAM_instance (.din(rx_data),.clk(clk),.rst_n(rst_n),.rx_valid(rx_valid),.dout(tx_data),.tx_valid(tx_valid));

endmodule