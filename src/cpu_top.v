module cpu #(
    parameter CLK_FREQ = 50_000_000,
    parameter RST_PC = 32'h0000_0001,
    parameter BAUD = 115200
) (
    input clk, 
    input rst,
    input instruction,
    input serial_in,
    input serial_out
);

reg [31:0] PC_in_IF;
reg [31:0] PC_out_IF;

if_stage if_stage (
    .clk(clk), // inputs
    .rst(rst),
    .RST_PC(RST_PC),
    .PC_in(PC_in_IF),
    .PC_out(PC_out_IF) // output
);

id_stage id_stage (
    .clk(clk), //inputs
    .PC(PC_out_IF),
    .instruction(instruction),
    .immOut(immOut), // outputs
    .aluSel(aluSel),
    .rd1(rd1),
    .rd2(rd2),
    .we(we),
    .wa(wa),
    .wd(wd)
);

ex_stage ex_stage (
    .clk(clk), //inputs
    .PC(PC_out_IF),
    .imm(immOut),
    .aluSel(aluSel),
    .rd1(rd1),
    .rd2(rd2),
    .we(we),
    .wa(wa),
    .wd(wd)
);

mem_stage mem_stage (

);

wb_stage wb_stage (

);