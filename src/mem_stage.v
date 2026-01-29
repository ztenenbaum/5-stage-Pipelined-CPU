module mem_stage #( 
) (
    input clk,
    input rst,
    input store,
    input [31:0] alu,
    input [3:0] mask,
    output reg [31:0] mem_out
);

wire [31:0] mem_wire;

//TODO initalize data memory

/*
pseudo code:
if rst: clear memory
if store: mem[address] = data_in
else data_out = mem[address]
*/

always @(posedge clk) begin
    mem_out <= mem_wire
end

endmodule