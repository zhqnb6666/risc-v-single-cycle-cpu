module RegisterFile (
    input             clk,
    input             reset,
    input             ecall,
    input      [31:0] io_input,
    input      [ 4:0] rs1,         // Source register 1
    input      [ 4:0] rs2,         // Source register 2
    input      [ 4:0] rd,          // Destination register
    input      [31:0] write_data,  // Data to write
    input             reg_write,   // Control signal to enable writing
    input      [ 31:0] test_case,
    output reg [31:0] a0_data,     // Data read from register a0
    output reg        io_out,      //enable io_output
    output     [31:0] read_data1,  // Data read from rs1
    output     [31:0] read_data2,  // Data read from rs2
    output reg [ 7:0] led_out
);

  reg [31:0] registers[31:0];  // 32 registers each of 32 bits
  wire [31:0] a0;  //a0 register
  wire [31:0] a7;  //a7 register


  // Read operations happen asynchronously
  assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
  assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];
  assign a0 = registers[10];
  assign a7 = registers[17];


  // Write operation happens on the positive edge of the clock
  integer i;
  always @(posedge clk or negedge reset) begin
    if (reset) begin
      for (i = 4; i < 32; i = i + 1) begin
        registers[i] <= 32'd0;
      end
      registers[3] <= 32'h1000; //global pointer
      registers[2] <= 32'h7fff; //stack pointer
      led_out <= 8'b00000000;
      io_out <= 0;
    end else if (ecall == 32'd1) begin
      case (a7)
        32'd1: begin
          io_out  <= 32'd1;
          a0_data <= a0;
        end
        32'd5: begin
          registers[10] <= io_input;
          led_out[7] <= 32'd1;
        end
        32'd10: begin
          led_out[0] <= 32'd1;
        end
        32'd11: begin
          registers[10] <= test_case;
          led_out[1]<= 32'd1;
        end
        default: begin
        end
      endcase
    end else if (reg_write && rd != 5'd0) begin
      registers[rd] <= write_data;
    end else begin
      led_out[7] <= 0;
      led_out[1] <= 0;
      led_out[0] <= 0;
    end
  end

  // always @(negedge clk) begin
  //   if (reg_write && rd != 0) begin
  //     registers[rd] <= write_data;
  //   end
  // end


endmodule
