module IFetch (
    input clock,
    input reset,
    input ecall,
    input continue_button,
    input pc_change,
    input [15:0] target_PC,
    input [2:0] test_number,
    output [15:0] PC
);

  reg [15:0] PC_reg;
  reg [15:0] test_case[7:0];
  reg continue_button_prev;

  initial begin
    test_case[0] = 16'd0;
    test_case[1] = 16'd10;
    test_case[2] = 16'd20;
    test_case[3] = 16'd30;
    test_case[4] = 16'd40;
    test_case[5] = 16'd50;
    test_case[6] = 16'd60;
    test_case[7] = 16'd70;
  end

  assign PC = PC_reg;

  always @(negedge clock) begin
    if (reset) PC_reg <= 0;
    else if (pc_change) PC_reg <= test_case[test_number];
    else if (ecall == 0 || (continue_button_prev && !continue_button && ecall == 1))
      PC_reg <= target_PC;
    continue_button_prev <= continue_button;
  end

endmodule
