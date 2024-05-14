module DMem (
    input clk,
    input mem_write,
    input [31:0] addr,
    input [31:0] din,
    output reg [31:0] dout,
    input [2:0] load_type
);

  localparam lb = 3'b000, lh = 3'b001, lw = 3'b010, lbu = 3'b011, lhu = 3'b100;

  wire [31:0] douta;
  data_mem udram (
      .clka (clk),
      .wea  (mem_write),
      .addra(addr[15:2]), 
      .dina (din),
      .douta(douta)
  );
  always @(*) begin
    case (load_type)
      lb:  dout = {{24{douta[7]}}, douta[7:0]};
      lh:  dout = {{16{douta[15]}}, douta[15:0]};
      lw:  dout = douta;
      lbu: dout = {24'b0, douta[7:0]};
      lhu: dout = {16'b0, douta[15:0]};
    endcase
  end
endmodule
