module S00_AXI 
#(		
	  parameter integer AXI_DATA_WIDTH	= 32
	, parameter integer AXI_ADDR_WIDTH	= 10
	, parameter integer AXI_REGS_COUNT	= 20
)
(
	  AXI_ACLK
	, AXI_ARESETN
	, AXI_AWADDR
	, AXI_AWVALID
	, AXI_AWREADY
	, AXI_WDATA
	, AXI_WSTRB
	, AXI_WVALID
	, AXI_WREADY
	, AXI_BRESP
	, AXI_BVALID
	, AXI_BREADY
	, AXI_ARADDR
	, AXI_ARVALID
	, AXI_ARREADY
	, AXI_RDATA
	, AXI_RRESP
	, AXI_RVALID
	, AXI_RREADY

	, write_only_registers
	, read_only_registers
);

	localparam integer ADDR_LSB 				= (AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS 		= 4;

	typedef logic   [AXI_DATA_WIDTH - 1 : 0]    axi_data_t;
	typedef logic   [AXI_ADDR_WIDTH - 1 : 0]    axi_addr_t;
	typedef logic   [(AXI_DATA_WIDTH/8)-1 : 0]  axi_strb_t;
	typedef logic   [1 : 0]                     axi_resp_t;

	input		logic  			AXI_ACLK;
	input		logic  			AXI_ARESETN;
	input		axi_addr_t 		AXI_AWADDR;
	input		logic  			AXI_AWVALID;
	output		logic  			AXI_AWREADY;
	input		axi_data_t 		AXI_WDATA;
	input		axi_strb_t 		AXI_WSTRB;
	input		logic  			AXI_WVALID;
	output		logic  			AXI_WREADY;
	output		axi_resp_t 		AXI_BRESP;
	output		logic  			AXI_BVALID;
	input		logic  			AXI_BREADY;
	input		axi_addr_t 		AXI_ARADDR;
	input		logic  			AXI_ARVALID;
	output		logic  			AXI_ARREADY;
	output		axi_data_t 		AXI_RDATA;
	output		axi_resp_t 		AXI_RRESP;
	output		logic  			AXI_RVALID;
	input		logic  			AXI_RREADY;

	input 		axi_data_t		write_only_registers 	[AXI_REGS_COUNT - 1 : 0];
	output		axi_data_t 		read_only_registers		[AXI_REGS_COUNT - 1 : 0];

	axi_addr_t		axi_awaddr;
	logic  			axi_awready;
	logic  			axi_wready;
	axi_resp_t 		axi_bresp;
	logic  			axi_bvalid;
	axi_addr_t		axi_araddr;
	logic  			axi_arready;
	axi_data_t		axi_rdata;
	axi_resp_t 		axi_rresp;
	logic  			axi_rvalid;

	assign AXI_AWREADY		= axi_awready;
	assign AXI_WREADY		= axi_wready;
	assign AXI_BRESP		= axi_bresp;
	assign AXI_BVALID		= axi_bvalid;
	assign AXI_ARREADY		= axi_arready;
	assign AXI_RDATA		= axi_rdata;
	assign AXI_RRESP		= axi_rresp;
	assign AXI_RVALID		= axi_rvalid;

	axi_data_t allRegs [AXI_REGS_COUNT*2 - 1 : 0];
	assign allRegs = {write_only_registers, read_only_registers};
			
	logic	aw_en;
	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			axi_awready	 	<= 1'b0;
			aw_en 			<= 1'b1;
		end 
		else
		begin    
			if(~axi_awready && AXI_AWVALID && AXI_WVALID && aw_en)
			begin
				axi_awready 	<= 1'b1;
				aw_en 			<= 1'b0;
			end
			else if(AXI_BREADY && axi_bvalid)
			begin
				aw_en 			<= 1'b1;
				axi_awready	 	<= 1'b0;
			end
			else           
			begin
				axi_awready <= 1'b0;
			end
		end 
	end       

	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			axi_awaddr <= 0;
		end 
		else
		begin    
			if(~axi_awready && AXI_AWVALID && AXI_WVALID && aw_en)
			begin
				axi_awaddr <= AXI_AWADDR;
			end
		end 
	end       
				
	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			axi_wready <= 1'b0;
		end 
		else
		begin    
			if(~axi_wready && AXI_WVALID && AXI_AWVALID && aw_en)
			begin
				axi_wready <= 1'b1;
			end
			else
			begin
				axi_wready <= 1'b0;
			end
		end 
	end       

	logic	 		writeEnable;
	axi_addr_t		writeAddr;

	assign writeEnable 				= axi_wready && AXI_WVALID && axi_awready && AXI_AWVALID;
	assign writeAddr 				= axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS : ADDR_LSB];
	assign writeAddr_valid 			= axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS : ADDR_LSB] < AXI_REGS_COUNT;

	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			for (integer i = 0; i < AXI_REGS_COUNT; i = i + 1) read_only_registers[i] <= 0;
		end 
		else 
		begin
			if(writeEnable & writeAddr_valid)
			begin
				for (integer byte_index = 0; byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
				begin
					if(AXI_WSTRB[byte_index] == 1) 
					begin
						read_only_registers[writeAddr][(byte_index*8) +: 8] <= AXI_WDATA[(byte_index*8) +: 8];
					end 
				end
			end
		end
	end    
			
	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			axi_bvalid  <= 0;
			axi_bresp   <= 2'b0;
		end 
		else
		begin    
			if(axi_awready && AXI_AWVALID && ~axi_bvalid && axi_wready && AXI_WVALID)
			begin
				axi_bvalid <= 1'b1;
				axi_bresp  <= 2'b0; 	       
			end
			else
			begin
				if(AXI_BREADY && axi_bvalid) 
				begin
					axi_bvalid <= 1'b0; 
				end  
			end
		end
	end   
						
	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			axi_arready <= 1'b0;
			axi_araddr  <= 32'b0;
		end 
		else
		begin    
			if(~axi_arready && AXI_ARVALID)
			begin
				axi_arready <= 1'b1;
				axi_araddr  <= AXI_ARADDR;
			end
			else
			begin
				axi_arready <= 1'b0;
			end
		end 
	end       

	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			axi_rvalid <= 0;
			axi_rresp  <= 0;
		end 
		else
		begin    
			if(axi_arready && AXI_ARVALID && ~axi_rvalid)
			begin
				axi_rvalid <= 1'b1;
				axi_rresp  <= 2'b0; 
			end   
			else if(axi_rvalid && AXI_RREADY)
			begin
				axi_rvalid <= 1'b0;
			end                
		end
	end    

	logic							readEnable;
	logic [AXI_DATA_WIDTH - 1 : 0]	dataOut;
	logic [AXI_ADDR_WIDTH - 1 : 0] 	readAddr;

	assign readEnable 		= axi_arready & AXI_ARVALID & ~axi_rvalid;
	assign readAddr 		= axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
	assign readAddr_valid 	= axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] < AXI_REGS_COUNT*2;

	always_comb 
	begin
		dataOut <= readAddr_valid ? allRegs[readAddr] : 0;
	end

	always_ff @(posedge AXI_ACLK)
	begin
		if(AXI_ARESETN == 1'b0)
		begin
			axi_rdata  <= 0;
		end 
		else
		begin    
			if(readEnable)
			begin
				axi_rdata <= dataOut;     	        
			end   
		end
	end    

endmodule
