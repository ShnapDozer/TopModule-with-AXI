`timescale 1ns / 1ps

module TopModule_tb;

    localparam STEP                     = 10;

    localparam AXI_DATA_WIDTH	        = 32;
    localparam AXI_ADDR_WIDTH	        = 8;

    typedef logic   [AXI_DATA_WIDTH - 1 : 0]    axi_data_t;
    typedef logic   [AXI_ADDR_WIDTH - 1 : 0]    axi_addr_t;
    typedef logic   [(AXI_DATA_WIDTH/8)-1 : 0]  axi_strb_t;
    typedef logic   [1 : 0]                     axi_resp_t;

    logic aclk;
    logic aresetn;

    axi_addr_t    S00_AXI_awaddr;
    logic         S00_AXI_awvalid;
    logic         S00_AXI_awready;
    axi_data_t    S00_AXI_wdata;
    axi_strb_t    S00_AXI_wstrb;
    logic         S00_AXI_wvalid;
    logic         S00_AXI_wready;
    axi_resp_t    S00_AXI_bresp;
    logic         S00_AXI_bvalid;
    logic         S00_AXI_bready;
    axi_addr_t    S00_AXI_araddr;
    logic         S00_AXI_arvalid;
    logic         S00_AXI_arready;
    axi_data_t    S00_AXI_rdata;
    axi_resp_t    S00_AXI_rresp;
    logic         S00_AXI_rvalid;
    logic         S00_AXI_rready;

    axi_data_t    read_data;


    TopModule DUT
    (
          .clk(                     aclk)
        , .areset_n(                aresetn)

        , .S00_AXI_AWADDR(          S00_AXI_awaddr)
        , .S00_AXI_AWVALID(         S00_AXI_awvalid)
        , .S00_AXI_AWREADY(         S00_AXI_awready)
        , .S00_AXI_WDATA(           S00_AXI_wdata)
        , .S00_AXI_WSTRB(           S00_AXI_wstrb)
        , .S00_AXI_WVALID(          S00_AXI_wvalid)
        , .S00_AXI_WREADY(          S00_AXI_wready)
        , .S00_AXI_BRESP(           S00_AXI_bresp)
        , .S00_AXI_BVALID(          S00_AXI_bvalid)
        , .S00_AXI_BREADY(          S00_AXI_bready)
        , .S00_AXI_ARADDR(          S00_AXI_araddr)
        , .S00_AXI_ARVALID(         S00_AXI_arvalid)
        , .S00_AXI_ARREADY(         S00_AXI_arready)
        , .S00_AXI_RDATA(           S00_AXI_rdata)
        , .S00_AXI_RRESP(           S00_AXI_rresp)
        , .S00_AXI_RVALID(          S00_AXI_rvalid)
        , .S00_AXI_RREADY(          S00_AXI_rready)
    );

    always 
	begin
		aclk        <= 1; #(STEP / 2);
		aclk        <= 0; #(STEP / 2);
	end

    task reset;
        aresetn                 <= 1;

        #(STEP * 10) aresetn <= 0;
        #(STEP * 10) aresetn <= 1;

        #(STEP * 10);
    endtask

    task axi_write(input axi_addr_t write_addr, input axi_data_t write_data);

        $display("\nSTART: axi_write");

        @(posedge aclk)
        S00_AXI_wdata   <= write_data;
        S00_AXI_awaddr  <= write_addr << 2;
        
        @(posedge aclk)
        S00_AXI_awvalid <= 1;
        S00_AXI_wvalid  <= 1;
        S00_AXI_wstrb   <= 4'b1111;

        $display("INFO: axi_write data %d in addr %d", write_data, write_addr);
        
        @(posedge S00_AXI_wready) @(posedge aclk)
        S00_AXI_awvalid <= 0;
        S00_AXI_wvalid  <= 0;
        S00_AXI_bready  <= 1;

        @(posedge S00_AXI_bready) @(posedge aclk)
        S00_AXI_bready   <= 0;
        
        #(STEP * 10);

        $display("END: axi_write");
    
    endtask

    task axi_read(input axi_addr_t read_addr);

        $display("\nSTART: axi_read");

        @(posedge aclk)
        S00_AXI_araddr      <= read_addr << 2;
        S00_AXI_arvalid     <= 1;

        @(posedge S00_AXI_rvalid) @(posedge aclk)
        S00_AXI_rready      <= 1;
        S00_AXI_arvalid     <= 0;
        read_data           <= S00_AXI_rdata; 

        @(posedge aclk)
        S00_AXI_rready      <= 0;

        $display("INFO: axi_read data %d from addr %d", read_data, read_addr);
    
        #(STEP * 10);

        $display("END: axi_read");

    endtask

    initial
    begin
        reset();

        #(STEP * 10);
    
        axi_write(0, 1488);

        #(STEP * 100);

        axi_read(0);
        
        #(STEP * 1000);

        $stop;
    end


endmodule