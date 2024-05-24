module IFetch (
    input clock,
    input reset,
    input ecall,
    input continue_button,
    input [15:0] target_PC,
    input delay,
    output reg [15:0] PC_prev,
    output [15:0] PC
);

  reg [15:0] PC_reg;
  reg [15:0] test_case[7:0];
  reg continue_button_prev;
  reg delay_prev;

  assign PC = PC_reg;

  always @(negedge clock) begin
    if (reset) begin
      PC_reg <= 0;
      delay_prev <= 0;
      continue_button_prev <= 0;
    end
    else if (!delay_prev && delay)begin
      PC_reg <= PC_reg;
      delay_prev <= delay;
    end
    else if (delay_prev && delay)begin
      PC_reg <= target_PC;
      delay_prev <= 0;
    end
    else if (ecall == 0 || (continue_button_prev && !continue_button && ecall == 1))
      PC_reg <= target_PC;
    continue_button_prev <= continue_button;
    PC_prev <= PC_reg;
  end

endmodule
