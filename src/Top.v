module top (
  input clk,
  input reset,
  input [7:0] imm_input,
  input [2:0] test_number,
  input confirm_button,
  output [7:0] led_output, // LED output
  output [6:0] segment_outputl, // Segment output for the 4 segmemt on the left
  output [6:0] segment_outputr, // Segment output for the 4 segmemt on the right
  output [7:0] digit_select_output // Digit select output for the 4 digits
);

  
//23mhz clock
wire clock;  

// Fetch Wires //
	wire [15:0]target_PC;
	wire [15:0]PC;

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
  wire pc_change;

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
	wire [31:0]d_read_data;

// Writeback wires //
	wire mem_to_reg;

//Segment Display Wires
wire [6:0] segment_output;
assign segment_outputl = segment_output;
assign segment_outputr = segment_output;
	
//Muxes
	assign write_data = (mem_to_reg)? d_read_data:ALU_result;
	
	assign operand_A = (operation1_sel == 2'b00) ? read_data1:
							 (operation1_sel == 2'b01) ? PC:
							 (operation1_sel == 2'b10) ? (PC + 16'd4):
							 (0);
							 
	assign operand_B = (operation2_sel) ? imm32:read_data2;
							 

	
	
//JALR passthrough

	assign JALR_target = imm32 + read_data1;
	
cpu_clk cpu_clk_inst (
  .clk_in1(clk),
  .clk_out1(clock)
);

IFetch fetch_inst (
  .clock(clock),
  .reset(reset),
  .pc_change(pc_change),
  .ecall(ecall),
  .continue_button(confirm_button),
  .test_number(test_number),
  .target_PC(target_PC),
  .PC(PC)
);


Controller control_unit (

  // Inputs from Fetch
  .PC(PC),
  .instruction(instruction),

  // Inputs from Execute/ALU
  .JALR_target(JALR_target),
  .branch(branch),

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

  // Outputs to Writeback
  .mem_to_reg(mem_to_reg),
  .ecall(ecall)

);


RegisterFile regFile_inst (
  .clk(clock),
  .reset(reset),
  .ecall(ecall),
  .io_input({24'h0, imm_input}),
  .io_out(io_out_en),
  .a0_data(a0_data),
  .reg_write(reg_write),
  .write_data(write_data), 
  .rs1(read_sel1),
  .rs2(read_sel2),
  .rd(write_sel),
  .led_out(led_output),
  .read_data1(read_data1), 
  .read_data2(read_data2),
  .pc_change(pc_change)
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
  .clk(clock),
  .addr(PC[15:2]),
  .dout(instruction)
);

DMem Dmem_inst (
  .clk(clock),
  .mem_write(mem_write),
  .addr(ALU_result),
  .din(read_data2),
  .dout(d_read_data)
);

SegmentDisplay seg_inst (
  .clk(clock),
  .rst(reset),
  .io_out_en(io_out_en),
  .value(a0_data),
  .seg_out(segment_output),
  .digit_select(digit_select_output)
);

endmodule
