module DMem(
input clk,
input mem_write,
input [31:0] addr,
input [31:0] din, output[31:0] dout);
data_mem udram(.clka(clk), .wea(mem_write), .addra(addr[13:0]), .dina(din), .douta(dout));
endmodule