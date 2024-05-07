module RegisterFile(
    input clk,
    input reset,
    input ecall,
    input [31:0]io_input,
    input [4:0] rs1,     // Source register 1
    input [4:0] rs2,     // Source register 2
    input [4:0] rd,      // Destination register
    input [31:0] write_data, // Data to write
    input reg_write,      // Control signal to enable writing
    output reg [31:0] a0_data,// Data read from register a0
    output reg io_out,    //enable io_output
    output [31:0] read_data1, // Data read from rs1
    output [31:0] read_data2,  // Data read from rs2
    output reg [7:0] led_out,
    output reg pc_change
);

    reg [31:0] registers [31:0]; // 32 registers each of 32 bits

    // Initialize all registers to zero
    integer i;
    always @(posedge reset) begin

        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;
    end

    // Read operations happen asynchronously
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // Write operation happens on the positive edge of the clock
    always @(posedge clk) begin
        if (ecall == 1 && registers[17] ==1) begin
            io_out <= 1;
            a0_data <= registers[10];
        end
        else if(ecall == 1 && registers[17] == 5)begin
            registers[10] <= io_input;
            led_out[7] <= 1;
        end
        else if(ecall == 1 && registers[17] == 10)begin//a7=10 means to light up the led[0]
            led_out[0] <= 1;
        end
        else if(ecall == 1 && registers[17] == 11)begin//a7=11 means to change pc counter to the specific test case
            pc_change <= 1;
        end
        else if(reg_write && (rd != 5'd0)) // Writing enabled and not to x0
            registers[rd] <= write_data;
        else begin
            led_out[7] <= 0;
            pc_change <= 0;
        end
    end

endmodule
