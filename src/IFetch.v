module IFetch (
    input clock,
    input reset,
    input ecall,
    input continue_button,
    input [15:0] target_PC,
    output [15:0] PC
);

  reg [15:0] PC_reg;
  reg [15:0] test_case[7:0];
  reg continue_button_prev;

  assign PC = PC_reg;

  always @(negedge clock) begin
    if (reset) PC_reg <= 0;
    else if (ecall == 0 || (continue_button_prev && !continue_button && ecall == 1))
      PC_reg <= target_PC;
    else PC_reg <= PC_reg;
    continue_button_prev <= continue_button;
  end

endmodule
