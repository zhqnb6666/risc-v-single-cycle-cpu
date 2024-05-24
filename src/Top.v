module top (
  input clk,
  input reset,
  input [15:0] imm_input,
  input [2:0] test_number,
  input confirm_button,
  output [15:0] imm_input_led,
  output [7:0] led_output, // LED output
  output [6:0] segment_output,
  output [7:0] digit_select_output, // Digit select output for the 4 digits
  input start_uart,//start Uart communicate at high active level
  input rx,//receive data by uart
  output tx//send data by uart
);
//led[0] light when ecall a0 = 10
//led[1] light when need choose test case
//led[7] light when need input
  
//23mhz clock
wire clock;  
//10mhz clock
wire uart_clk;
// Fetch Wires //
// Fetch Wires //
  wire delay;
	wire [15:0]target_PC;
	wire [15:0]PC;
  wire [15:0] PC_prev;
// Decode Wires
	
	//Inputs
	wire [31:0] instruction;
	//From Execute/ALU
	wire [15:0] JALR_target;
	wire branch;

	// Outputs to Execute/ALU
	wire branch_op;
	wire signed [31:0] imm32;
	wire [1:0] operation1_sel;
	wire operation2_sel;
	//wire [5:0] ALU_Control;
	
	wire [4:0] read_sel2;
  wire ecall;

// Reg File Wires //
	
	//INPUTS
	wire reg_write;
	wire [31:0] write_data;
	wire [4:0] read_sel1;
	wire [4:0] write_sel;
  wire [31:0] a0_data;
	
	//OUTPUTS
	wire [31:0] read_data1;
	wire [31:0] read_data2;

// ALU Wires //
	//wire branch_op;
	wire [5:0]ALU_Control;
	wire [31:0]operand_A; //Mux output
	wire [31:0]operand_B; //Mux output
	wire [31:0]ALU_result;
	//wire branch;

// Memory Wires //

	// Data Port
	wire mem_write;
  wire[2:0] load_type;
	wire [31:0]d_read_data;

// Writeback wires //
wire mem_to_reg;

//Segment Display Wires
wire [6:0] segment_output_wire;
wire [7:0] digit_select_wire;
assign segment_output = ~segment_output_wire;
assign digit_select_output = ~digit_select_wire;
	
//Muxes
	assign write_data = (mem_to_reg)? d_read_data:ALU_result;
	
	assign operand_A = (operation1_sel == 2'b00) ? read_data1:
							 (operation1_sel == 2'b01) ? PC:
							 (operation1_sel == 2'b10) ? (PC_prev + 16'd4):
							 (0);
							 
	assign operand_B = (operation2_sel) ? imm32:read_data2;


//IMM_input to LED
assign imm_input_led = imm_input;
							
//JALR passthrough

	assign JALR_target = imm32 + read_data1;
	
cpu_clk cpu_clk_inst (
  .clk_in1(clk),
  .clk_out1(clock),
  .clk_out2(uart_clk)
);


wire io_out_en;
//UART output clock(I don't know why it is needed)
wire upg_clk_o;
//UART write enable
wire upg_wen;
//UART output address
wire[14:0] upg_addr;
//UART output data
wire[31:0] upg_data;
//UART done signal
wire upg_done;
//CPU work on normal mode when kickOff is 1, work on uart mode when kickOff is 0
wire kickOff; 
wire true_clk; 
assign kickOff = reset | ~start_uart | (~reset & upg_done);
assign true_clk = kickOff? clock: uart_clk;
uart_bmpg_0 uart_bmpg(
  .upg_clk_i(uart_clk),
  .upg_rst_i(kickOff? 1'b1: 1'b0),
  .upg_rx_i(rx),
  .upg_clk_o(upg_clk_o),
  .upg_wen_o(upg_wen),
  .upg_adr_o(upg_addr),
  .upg_dat_o(upg_data),
  .upg_done_o(upg_done),
  .upg_tx_o(tx)
);

//When the CPU is running in uart mode, the IFetch modules should be stopped(reset) to avoid dirty read?
IFetch fetch_inst (

  .clock(true_clk),
  .reset(kickOff? reset: 1'b1),
  .ecall(ecall),
  .continue_button(confirm_button),
  .target_PC(target_PC),
  .PC(PC),
  .PC_prev(PC_prev),
  .delay(delay)
);


Controller control_unit (

  // Inputs from Fetch
  .PC(PC),
  .instruction(kickOff? instruction: 32'b0),

  // Inputs from Execute/ALU
  .JALR_target(JALR_target),
  .branch(branch),
  .delay(delay),
  // Outputs to Fetch
  .target_PC(target_PC),

  // Outputs to Reg File
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .reg_write(reg_write),

  // Outputs to Execute/ALU
  .branch_op(branch_op),
  .imm32(imm32),
  .operation1_sel(operation1_sel), 
  .operation2_sel(operation2_sel), 
  .ALU_Control(ALU_Control),

  // Outputs to Memory
  .mem_write(mem_write),
  .load_type(load_type),

  // Outputs to Writeback
  .mem_to_reg(mem_to_reg),
  .ecall(ecall)

);


RegisterFile regFile_inst (
  .clk(true_clk),
  .reset(reset),
  .ecall(ecall),
  .io_input({16'h0, imm_input}),
  .io_out(io_out_en),
  .a0_data(a0_data),
  .reg_write(reg_write),
  .write_data(write_data), 
  .test_case({29'h0, test_number}),
  .rs1(read_sel1),
  .rs2(read_sel2),
  .rd(write_sel),
  .led_out(led_output),
  .read_data1(read_data1), 
  .read_data2(read_data2)
);


ALU alu_inst(
  .branch_op(branch_op),
  .ALU_Control(ALU_Control),
  .operand_A(operand_A),
  .operand_B(operand_B), 
  .ALU_result(ALU_result),
  .branch(branch)
);


IMem Imem_inst (
  .clk(true_clk),
  .wea(kickOff? 1'b0: upg_wen & ~upg_addr[14]),
  .addr(kickOff? PC[15:2]: upg_addr[13:0]),
  .din(kickOff? 32'h0: upg_data),
  .dout(instruction)
);

DMem Dmem_inst (
  .clk(true_clk),
  .mem_write(kickOff? mem_write: upg_wen & upg_addr[14]),
  .addr(kickOff? ALU_result: {upg_addr[13:0], 2'b0}),
  .load_type(kickOff? load_type: 3'b111),
  .din(kickOff? read_data2: upg_data),
  .dout(d_read_data)
);

SegmentDisplay seg_inst (
  .clk(true_clk),
  .rst(reset),
  .value(a0_data),
  .io_out_en(io_out_en),
  .seg_out(segment_output_wire),
  .digit_select(digit_select_wire)
);

endmodule
