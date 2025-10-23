module if_stage #( 
) (
    input clk,
    input rst,
    input RST_PC,
    input [31:0] PC_in,
    output reg [31:0] PC_out
);

always @(posedge clk) begin
    if (rst) begin
        PC_out <= RESET_PC;
    else begin
        PC_out <= PC_in;
end

endmodule