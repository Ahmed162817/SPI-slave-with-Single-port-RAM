module SPI_tb ();

// parameters declaration
parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter WRITE = 3'b010;
parameter READ_DATA = 3'b011;
parameter READ_ADD = 3'b100;

//local parameter indicate the number of times that all the operations are repeated
localparam N = 100;

// input & output Declaration
reg MOSI,SS_n,clk,rst_n;
wire MISO;

// internal read & write signals
reg [7:0] wr_addr, rd_addr;
reg [7:0] wr_data, rd_data;

// DUT instantiation
SPI_wrapper DUT (.MOSI(MOSI),.MISO(MISO),.clk(clk),.rst_n(rst_n),.SS_n(SS_n));

// clock Generation
initial begin
	clk = 0;
	forever
	#5 clk = ~clk;      // clock period = 10ns
end

// Generate test stimulus
initial begin
	$readmemb("initialized_RAM.txt",DUT.RAM_instance.RAM);

    //---------------------Test Reset Operation------------------//
    rst_n = 0;      wr_addr = 0;    rd_addr = 0;    SS_n = 1;
    wr_data = 0;    rd_data = 0;    MOSI = 0;
    repeat (5) begin
        @(negedge clk);
        if ( (DUT.slave_instance.cs != IDLE) || (MISO != 0) ) begin
            $display ("Error in Reset Operation");
            $stop;
        end
    end
    rst_n = 1;         // Deassert the reset signal

repeat (N) begin    

//--------------------Test Write Address Operation-----------//
    @(negedge clk);
    SS_n = 0;
    @(negedge clk);
    MOSI = 0;
    repeat (2) @(negedge clk);
    repeat (8) begin
    	@(negedge clk); 
        MOSI = $random;
        wr_addr = { wr_addr[6:0] , MOSI };  
    end
    @(negedge clk);  SS_n = 1;    // we must wait one clock cycle after storing the write address then end the communication
    repeat (2) @(negedge clk);
    if (DUT.RAM_instance.wr_addr != wr_addr) begin
        $display ("Error in Write Address Operation");
        $stop;
    end
    
//----------------------Test Write Data Operation-------------//
    @(negedge clk);
    SS_n = 0;
    @(negedge clk);
    MOSI = 0;
    @(negedge clk);
    MOSI = 0;
    @(negedge clk);
    MOSI = 1;
    repeat (8) begin
    	@(negedge clk);
        MOSI = $random;
        wr_data = { wr_data[6:0] , MOSI };
    end
    @(negedge clk);  SS_n = 1;    // we must wait one clock cycle after storing the write data then end the communication
    repeat (2) @(negedge clk);
    if (DUT.RAM_instance.RAM[DUT.RAM_instance.wr_addr] != wr_data) begin
        $display ("Error in Write Data Operation");
        $stop;
    end
    
//------------------------Test Read Address Operation-----------------//
    @(negedge clk);
    SS_n = 0;
    @(negedge clk);
    MOSI = 1;
    @(negedge clk);
    MOSI = 1;
    @(negedge clk);
    MOSI = 0;
    repeat (8) begin
    	@(negedge clk);
        MOSI = $random;
        rd_addr = { rd_addr[6:0] , MOSI };
    end
    @(negedge clk);  SS_n = 1;     // we must wait one clock cycle after storing the read address then end the communication
    repeat (2) @(negedge clk);
    if (DUT.RAM_instance.rd_addr != rd_addr) begin
        $display ("Error in Read Address Operation");
        $stop;
    end

//--------------------------Test Read Data Operation----------------------//
    @(negedge clk);
    SS_n = 0;
    @(negedge clk);
    MOSI = 1;
    repeat (2) @(negedge clk);
    repeat (8) begin
    	@(negedge clk);
        MOSI = $random;              // Dummy Data as we take the read_data from the RAM itself
    end
    // This 3 clock cycle delay consist of (1 clk cycle delay after finishing the randomization of MOSI bus with dummy data + 1 clk cycle delay for activate rx_valid + 1 clk cycle delay for activate tx_valid)
    repeat(3) @(negedge clk);    
    repeat (8) begin
        @(negedge clk);
        rd_data = { rd_data[6:0] , MISO };
    end
    @(negedge clk);  SS_n = 1;      // we must wait one clock cycle after storing the read data then end the communication
    repeat (2) @(negedge clk);
    if (DUT.RAM_instance.RAM[DUT.RAM_instance.rd_addr] != rd_data) begin
        $display ("Error in Read Data Operation");
        $stop;
    end

end     // end of the repeat loop

$display("SPI communication protocol is operate successfully");
@(negedge clk);
$stop;

end   // end of the initial block

endmodule