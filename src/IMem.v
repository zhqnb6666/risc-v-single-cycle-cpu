module IMem(
input clk,
input [13:0] addr,
output [31:0] dout
);
ins_mem udram(.clka(clk),.addra(addr),.douta(dout));
endmodule