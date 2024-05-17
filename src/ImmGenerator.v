module imm_generator(
    input [31:0] instruction,
    output reg [31:0] imm32
);

    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];

    // Opcode values for different instruction types
    localparam I_TYPE = 7'b0010011,
               S_TYPE = 7'b0100011,
               SB_TYPE = 7'b1100011,
               U_TYPE = 7'b0110111,
               UP_TYPE = 7'b0010111,
               J_TYPE = 7'b1101111,
               JR_TYPE = 7'b1100111,
               L_TYPE = 7'b0000011;

    always @(*) begin
        case (opcode)
            I_TYPE: begin
                // Immediate for I-Type (sign extension)
                imm32 = {{20{instruction[31]}}, instruction[31:20]};
            end
            S_TYPE: begin
                // Immediate for S-Type (sign extension)
                imm32 = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            SB_TYPE: begin
                // Immediate for SB-Type (sign extension and shift left 1 bit)
                imm32 = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            U_TYPE: begin
                // Immediate for U-Type (zero extension and shift left 12 bits)
                imm32 = {instruction[31:12], 12'b0};
            end
            UP_TYPE: begin
                // Immediate for U-Type (zero extension and shift left 12 bits)
                imm32 = {instruction[31:12], 12'b0};
            end
            J_TYPE: begin
                // Immediate for UJ-Type (sign extension and shift left 1 bit)
                imm32 = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            JR_TYPE: begin
                // Immediate for JR-Type (sign extension)
                imm32 = {{20{instruction[31]}}, instruction[31:20]};
            end
            L_TYPE: begin
                // Immediate for L-Type (sign extension)
                imm32 = {{20{instruction[31]}}, instruction[31:20]};
            end

            default: imm32 = 32'b0; // Default case for safety
        endcase
    end
endmodule
