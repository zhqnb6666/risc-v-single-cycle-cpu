
module Controller  (
  // Inputs from IFetch
  input [15:0] PC,
  input [31:0] instruction,

  // Inputs from ALU
  input [15:0] JALR_target,
  input branch,

  // Outputs to Fetch
  output [15:0] target_PC,

  // Outputs to RegisterFile
  output [4:0] read_sel1,
  output [4:0] read_sel2,
  output [4:0] write_sel,
  output reg reg_write,

  // Outputs to Execute/ALU
  output reg branch_op, // Tells ALU if this is a branch instruction
  output [31:0] imm32,
  output reg [1:0] operation1_sel,
  output reg operation2_sel,
  output reg [5:0] ALU_Control,

  // Outputs to Memory
  output reg mem_write,

  // Outputs to Writeback
  output reg mem_to_reg,
  output reg ecall

);

localparam [6:0]R_TYPE  = 7'b0110011,
                I_TYPE  = 7'b0010011,
                STORE   = 7'b0100011,
                LOAD    = 7'b0000011,
                BRANCH  = 7'b1100011,
                JALR    = 7'b1100111,
                JAL     = 7'b1101111,
                AUIPC   = 7'b0010111,
                LUI     = 7'b0110111,
				ECALL   = 7'b1110011;

wire [6:0] opcode;
wire [6:0] funct7;
wire [2:0] funct3;
wire [1:0] extend_sel;
wire [15:0] branch_target;
wire [15:0] JAL_target;


// Read registers
assign read_sel2  = instruction[24:20];
assign read_sel1  = instruction[19:15];

/* Instruction decoding */
assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

/* Write register */
assign write_sel = instruction[11:7];


imm_generator imm_gen(
  .instruction(instruction),
  .imm32(imm32)
);

//target PC calculations 					 
assign target_PC = ((opcode == BRANCH && branch == 1 ) || opcode == JAL)? PC + imm32:  //branch and jal instructions
						 (opcode == JALR)? JALR_target:				 //jalr instruction 
						 PC + 4; //default 
						 
//signal calculations for most wires 
  always @(*) begin 
	ecall = 0;
    case (opcode) 
	   R_TYPE: begin // R-type
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b00;
		  operation2_sel = 0;
		  mem_to_reg = 0;
		 reg_write = 1;
		  if (funct3 == 3'b000) begin 
		    if (funct7 == 7'b0000000) begin 
			   ALU_Control = 6'b000000; //add
			 end else begin 
			   ALU_Control = 6'b001000; //sub
			 end 
		  end else if (funct3 == 3'b010) begin 
		    ALU_Control = 6'b000010; //slt
		  end else if (funct3 == 3'b100) begin 
		    ALU_Control = 6'b000100; //xor
		  end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b000111; //and
		  end else if (funct3 == 3'b001) begin
		    ALU_Control = 6'b000001; //sll
		  end else if (funct3 == 3'b011) begin
		    ALU_Control = 6'b000010; //sltu
		  end else if (funct3 == 3'b110) begin
		    ALU_Control = 6'b000110; //or
		  end else if (funct3 == 3'b101) begin
		    if (funct7 == 7'b0000000) begin
			   ALU_Control = 6'b000101; //srl
			 end else begin 
			   ALU_Control = 6'b001101; //sra
			 end 
		  end 
      end 		  
		I_TYPE: begin //I-type
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b00;
		  operation2_sel = 1;
		  mem_to_reg = 0;
		 reg_write = 1;
		  if (funct3 == 3'b000) begin
		    ALU_Control = 6'b000000; //addi 
		  end else if (funct3 == 3'b001) begin
			 ALU_Control = 6'b000001; //slli
		  end else if (funct3 == 3'b010) begin
			 ALU_Control = 6'b000011; //slti
		  end else if (funct3 == 3'b011) begin
			 ALU_Control = 6'b000011; //sltiu
		  end else if (funct3 == 3'b100) begin 
			 ALU_Control = 6'b000100; //xori
		  end else if (funct3 == 3'b101) begin 
		    if (funct7 == 7'b0000000) begin 
			   ALU_Control = 6'b000101; //srli
			 end else begin 
			   ALU_Control = 6'b001101; //srai
			 end
		  end else if (funct3 == 3'b110) begin
		    ALU_Control = 6'b000110; //ori
		  end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b000111; //andi
		  end
		end
      LOAD: begin //Load
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b00;
		  operation2_sel = 1;
		  mem_to_reg = 1;
		 reg_write = 1;
		  ALU_Control = 6'b000000;
		end 
      STORE: begin //Store
		  branch_op = 0;
		  mem_write = 1;
		  operation1_sel = 2'b00;
		  operation2_sel = 1;
		  mem_to_reg = 0;
		 reg_write = 0;
		  ALU_Control = 6'b000000;
		end
		BRANCH: begin //Branch 
		  branch_op = 1;
		  mem_write = 0;
		  operation1_sel = 2'b00;
		  operation2_sel = 0;
		  mem_to_reg = 0;
		 reg_write = 0;
		 
		  if (funct3 == 3'b000) begin 
		    ALU_Control = 6'b010000; //beq
		  end else if (funct3 == 3'b001) begin 
		    ALU_Control = 6'b010001; //bne
        end else if (funct3 == 3'b100) begin 
		    ALU_Control = 6'b000010; //blt
        end else if (funct3 == 3'b101) begin 
		    ALU_Control = 6'b010101; //bge
        end else if (funct3 == 3'b110) begin 
		    ALU_Control = 6'b010110; //bltu
        end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b010111; //bgeu
        end 
		end
		JALR: begin //Jalr
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b10; // PC + 4
		  operation2_sel = 0;
		  mem_to_reg = 0;
		 reg_write = 1;
		  ALU_Control = 6'b111111;
		end
		JAL: begin //Jal
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b10;  // PC + 4 
		  operation2_sel = 0;
		  mem_to_reg = 0;
		 reg_write = 1;
		  ALU_Control = 6'b011111;
		end
		AUIPC: begin //Auipc//
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b01; // PC
		  operation2_sel = 1;
		  mem_to_reg = 0;
		 reg_write = 1;
		  ALU_Control = 6'b000000;
		end
		LUI: begin //Lui
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b11; // hard code zero  
		  operation2_sel = 1;
		  mem_to_reg = 0;
		 reg_write = 1;
		  ALU_Control = 6'b000000;
		end
		ECALL: begin //Ecall
		  branch_op = 0;
		  mem_write = 0;
		  operation1_sel = 2'b00;
		  operation2_sel = 0;
		  mem_to_reg = 0;
		  reg_write = 0;
		  ecall = 1;
		  ALU_Control = 6'b000000;
		end
    endcase 
  end	 



endmodule
