module id_stage #(
) (
    input clk,
    input [31:0] PC,
    input [31:0] instruction,
    output reg [3:0] aluSel,
    output [31:0] rd1,
    output [31:0] rd2,
    output reg we,
    output reg [4:0] wa,
    output [31:0] wd,
    output loadSel,
    output storeSel
);

reg [2:0] immSel;
reg [3:0] aluSel;
wire [6:0] opp;
wire [6:0] func7;
wire [2:0] func3;

wire [4:0] ra1, ra2, wa; 
wire [31:0] wd, rd1, rd2;
reg we, loadSel, storeSel;

wire [6:0] opp  = instruction[6:0];
wire [6:0] func7= instruction[31:25];
wire [2:0] func3= instruction[14:12];
wire [4:0] ra1 = instruction[19:15];
wire [4:0] ra2 = instruction[24:20];

reg_file rf (
    .clk(clk),
    .we(we),
    .ra1(ra1),
    .ra2(ra2),
    .wa(wa),
    .wd(wd),
    .rd1(rd1),
    .rd2(rd2)
);

always @(posedge clk) begin
    

    localparam I_type = 3'b000;
    localparam IStar_type = 3'b101;
    localparam S_type = 3'b001;
    localparam B_type = 3'b010; //not supported
    localparam U_type = 3'b011;
    localparam J_type = 3'b100; //not supported
    localparam Other = 3'b111;

    //CONTROL LOGIC

    case (opp) 
        7'b0110011: begin // R
            loadSel = 1'b0;
            storeSel = 1'b0;
            immSel = 3'b000;
            we = 1;
            wa = instruction[11:7];
            if (func7 == 7'b0000000) begin
                case (func3)
                    3'b000: aluSel = 4'b0000;
                    3'b001: aluSel = 4'b0011; // sll
                    3'b010: aluSel = 4'b1001; // slt
                    3'b011: aluSel = 4'b1011; // sltu
                    3'b100: aluSel = 4'b0111; // xor
                    3'b101: aluSel = 4'b0100; // srl
                    3'b110: aluSel = 4'b0110; // or
                    3'b111: aluSel = 4'b0101; // and
                    default: ;
                endcase
            end else if (func7 == 7'b0100000) begin
                case (func3)
                    3'b000: aluSel = 4'b0001; // sub
                    3'b101: aluSel = 4'b1010; // sra
                    default: aluSel = 4'b0000;
                endcase
            end
        end

        7'b0010011: begin // I
            loadSel = 1'b0;
            storeSel = 1'b0;
            immSel = 3'b000;
            we = 1;
            wa = instruction[11:7];
            case (func3)
                3'b000: aluSel = 4'b1111; // addi
                3'b001: begin
                    aluSel = 4'b1100; // slli
                    immSel = IStar_type; // 3'b101
                end
                3'b010: aluSel = 4'b1001; // slti
                3'b011: aluSel = 4'b1011; // sltiu
                3'b100: aluSel = 4'b1101; // xori
                3'b101: begin
                    if (func7 == 7'b0000000) begin
                    aluSel = 4'b0100; // srli
                        immSel = IStar_type;
                    end else begin
                        aluSel = 4'b1010; // srai
                        immSel = IStar_type;
                    end
                end
                3'b110: aluSel = 4'b0110; // ori
                3'b111: aluSel = 4'b1110; // andi
                default: ;
            endcase
        end

        7'b0100011: begin // S
            loadSel = 1'b0;
            storeSel = 1'b1;
            we = 0;
            immSel = 3'b001;
            aluSel = 4'b0000;
        end

        7'b0010111: begin // AUIPC
            loadSel = 1'b0;
            storeSel = 1'b0;
            we = 0;
            immSel = 3'b011; 
            aluSel = 4'b0000;
        end

        7'b0110111: begin // LUI
            loadSel = 1'b0;
            storeSel = 1'b0;
            we = 0;
            immSel = 3'b011;
            aluSel = 4'b0000;
        end

        7'b0000011: begin // LOADS
            loadSel = 1'b1;
            storeSel = 1'b0;
            we = 1;
            wa = instruction[11:7];
            immSel = 3'b000;
            aluSel = 4'b0000;
        end
    endcase

    case (immSel)
        I_type: imm_out = { {20{instruction[31]}}, instruction[31:20] };
        IStar_type: imm_out = { 27'b0, instruction[24:20] };
        S_type: imm_out = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
        B_type: imm_out = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
        U_type: imm_out = { instruction[31:12], 12'b0 };
        J_type: imm_out = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0 };
        Other: imm_out = { 27'b0, instruction[19:15] };
        default: imm_out = 32'b0;
    endcase
end

endmodule



        


