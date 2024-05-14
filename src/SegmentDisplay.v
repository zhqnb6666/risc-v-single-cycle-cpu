module SegmentDisplay (
    input clk,
    input rst,
    input io_out_en,
    input [31:0] value,
    output reg [6:0] seg_out,
    output reg [7:0] digit_select
);
  wire [6:0] seg[7:0];
  DigitToSegment digit0 (
      value[3:0],
      seg[0]
  );
  DigitToSegment digit1 (
      value[7:4],
      seg[1]
  );
  DigitToSegment digit2 (
      value[11:8],
      seg[2]
  );
  DigitToSegment digit3 (
      value[15:12],
      seg[3]
  );
  DigitToSegment digit4 (
      value[19:16],
      seg[4]
  );
  DigitToSegment digit5 (
      value[23:20],
      seg[5]
  );
  DigitToSegment digit6 (
      value[27:24],
      seg[6]
  );
  DigitToSegment digit7 (
      value[31:28],
      seg[7]
  );
  reg [16:0] counter;
  reg [2:0]counter_select;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 0;
      counter_select <= 0;
    end else if (counter == 10_000) begin
      counter <= 0;
      counter_select <= counter_select + 1;
    end else begin
      counter <= counter + 1;
    end
  end

  always @(counter_select) begin
    if(io_out_en)
    case (counter_select)
       3'b000:  begin
        seg_out <= seg[0];
        digit_select <= 8'b00000001;
        end
        3'b001:  begin
        seg_out <= seg[1];
        digit_select <= 8'b00000010;
        end
        3'b010:  begin
        seg_out <= seg[2];
        digit_select <= 8'b00000100;
        end
        3'b011:  begin
        seg_out <= seg[3];
        digit_select <= 8'b00001000;
        end
        3'b100:  begin
        seg_out <= seg[4];
        digit_select <= 8'b00010000;
        end
        3'b101:  begin
        seg_out <= seg[5];
        digit_select <= 8'b00100000;
        end
        3'b110:  begin
        seg_out <= seg[6];
        digit_select <= 8'b01000000;
        end
        3'b111:  begin
        seg_out <= seg[7];
        digit_select <= 8'b10000000;
        end
        default: begin
        seg_out <= 7'b0000000;
        digit_select <= 8'b00000000;
        end
    endcase
    else begin
      seg_out <= 7'b0000000;
      digit_select <= 8'b00000000;
    end
  end
endmodule