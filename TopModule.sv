module TopModule 
#(
      parameter integer   AXI_DATA_WIDTH	  = 32
    , parameter integer   AXI_ADDR_WIDTH	  = 8
)
(
    clk
  , areset_n

  , S00_AXI_AWADDR
  , S00_AXI_AWVALID
  , S00_AXI_AWREADY
  , S00_AXI_WDATA
  , S00_AXI_WSTRB
  , S00_AXI_WVALID
  , S00_AXI_WREADY
  , S00_AXI_BRESP
  , S00_AXI_BVALID
  , S00_AXI_BREADY
  , S00_AXI_ARADDR
  , S00_AXI_ARVALID
  , S00_AXI_ARREADY
  , S00_AXI_RDATA
  , S00_AXI_RRESP
  , S00_AXI_RVALID
  , S00_AXI_RREADY

);

  localparam integer   AXI_REGS_COUNT   = 20;

  typedef logic   [AXI_DATA_WIDTH - 1 : 0]    axi_data_t;
  typedef logic   [AXI_ADDR_WIDTH - 1 : 0]    axi_addr_t;
  typedef logic   [(AXI_DATA_WIDTH/8)-1 : 0]  axi_strb_t;
  typedef logic   [1 : 0]                     axi_resp_t;

  input     logic         clk;
  input     logic         areset_n;

  input     axi_addr_t    S00_AXI_AWADDR;
  input     logic         S00_AXI_AWVALID;
  output    logic         S00_AXI_AWREADY;
  input     axi_data_t    S00_AXI_WDATA;
  input     axi_strb_t    S00_AXI_WSTRB;
  input     logic         S00_AXI_WVALID;
  output    logic         S00_AXI_WREADY;
  output    axi_resp_t    S00_AXI_BRESP;
  output    logic         S00_AXI_BVALID;
  input     logic         S00_AXI_BREADY;
  input     axi_addr_t    S00_AXI_ARADDR;
  input     logic         S00_AXI_ARVALID;
  output    logic         S00_AXI_ARREADY;
  output    axi_data_t    S00_AXI_RDATA;
  output    axi_resp_t    S00_AXI_RRESP;
  output    logic         S00_AXI_RVALID;
  input     logic         S00_AXI_RREADY;

  axi_data_t  write_only_registers  [AXI_REGS_COUNT - 1 : 0];
  axi_data_t  read_only_registers   [AXI_REGS_COUNT - 1 : 0];

  always_ff @(posedge clk or negedge areset_n) 
  begin
    if(!areset_n) for (integer i = 0; i < AXI_REGS_COUNT; i = i + 1) write_only_registers[i] <= 0;
  end

  S00_AXI 
  #( 
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
    , .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    , .AXI_REGS_COUNT(AXI_REGS_COUNT)
  ) 
  axi_slave 
  (
      .AXI_ACLK(        clk)
    , .AXI_ARESETN(     areset_n)
    , .AXI_AWADDR(      S00_AXI_AWADDR)
    , .AXI_AWVALID(     S00_AXI_AWVALID)
    , .AXI_AWREADY(     S00_AXI_AWREADY)
    , .AXI_WDATA(       S00_AXI_WDATA)
    , .AXI_WSTRB(       S00_AXI_WSTRB)
    , .AXI_WVALID(      S00_AXI_WVALID)
    , .AXI_WREADY(      S00_AXI_WREADY)
    , .AXI_BRESP(       S00_AXI_BRESP)
    , .AXI_BVALID(      S00_AXI_BVALID)
    , .AXI_BREADY(      S00_AXI_BREADY)
    , .AXI_ARADDR(      S00_AXI_ARADDR)
    , .AXI_ARVALID(     S00_AXI_ARVALID)
    , .AXI_ARREADY(     S00_AXI_ARREADY)
    , .AXI_RDATA(       S00_AXI_RDATA)
    , .AXI_RRESP(       S00_AXI_RRESP)
    , .AXI_RVALID(      S00_AXI_RVALID)
    , .AXI_RREADY(      S00_AXI_RREADY)

    , .write_only_registers(    write_only_registers)
    , .read_only_registers(     read_only_registers)
  );

endmodule