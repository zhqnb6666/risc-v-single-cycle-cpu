module IMem(
input clk,
input wea,
input [13:0] addr,
input [31:0] din,
output [31:0] dout
);
ins_mem udram(.clka(clk),.wea(wea),.addra(addr),.dina(din),.douta(dout));
endmodule