module ex_stage #(
)(
    input clk,
    input [31:0] PC,
    input [31:0] imm,
    input [3:0] aluSel,
    input [31:0] rd1,
    input [31:0] rd2,
    input we,
    input [4:0] wa,
    input [31:0] wd,
    input loadSel,
    input storeSel,
    input branch,
    output reg [31:0] alu,
    output reg beq,
    output reg blt,
    output reg [3:0] mask
)
wire [31:0] result, a, b;
wire [3:0] mask_wire;

wire beq_wire, blt_wire;
assign beq_wire = rd1 == rd2;
assign blt_wire = rd1 < rd2;

always @(*) begin
    case (aluSel)
        4'b0000: result = a + b;
        4'b0001: result = a - b;
        4'b0010: result = b;
        4'b0011: result = a << b[4:0]; // sll
        4'b0100: result = a >> b[4:0]; // srl
        4'b0101: result = a & b;
        4'b0110: result = a | b;
        4'b0111: result = a ^ b; // xor
        4'b1000: result = a; // forward PC
        4'b1001: result = ($signed(a) <  $signed(b)) ? 32'd1 : 32'd0; // slt
        4'b1010: result = $signed(a) >>> b[4:0]; // sra
        4'b1011: result = (a < b) ? 32'd1 : 32'd0; // sltu
        4'b1100: result = a << b[4:0]; // slli
        4'b1101: result = (a ^ b); // xori 
        4'b1110: result = (a & b); // andi 
        4'b1111: result = (a + b);  // addi 
        default: result = a;
    endcase
    if (loadSel) begin 
        if (instruction[13]) begin // word
            mask_wire = 5'b01111;
        end else if (instruction[12]) begin //half word (1100 or 0011)
            case (imm_out[1:0])
                0: mask_wire = 4'b0011;
                2: mask_wire = 4'b1100;
            endcase
        end else if (!instruction[12]) begin //byte (1000, 0100, 0010, 0001)
            case (imm_out[1:0])
                0: mask_wire = 4'b0001;
                1: mask_wire = 4'b0010;
                2: mask_wire = 4'b0100;
                3: mask_wire = 4'b1000;
            endcase
        end
        if (instruction[14]) begin // unsigned
            sign_ext = 1'b0; // Fill with 0
        end else begin
            sign_ext = 1'b1; // Fill with MSB
        end

    // STORE mask_wire [which bytes to write to]
    end else if (storeSel) begin //store
        sign_ext = 1'b0; // Fill with 0
        if (instruction[13]) begin // word
            mask_wire = 5'b1111;
        end else if (instruction[12]) begin //half word (1100 or 0011)
            case (imm_out[1:0])
                0: mask_wire = 4'b0011;
                2: mask_wire = 4'b1100;
            endcase
        end else if (!instruction[12]) begin //byte (1000, 0100, 0010, 0001)
            case (imm_out[1:0])
                0: mask_wire = 4'b0001;
                1: mask_wire = 4'b0010;
                2: mask_wire = 4'b0100;
                3: mask_wire = 4'b1000;
            endcase
        end
    end
    
end


always @(posedge clk) begin
    alu <= result;
    beq <= beq_wire;
    blt <= blt_wire;
    mask <= mask_wire;
end
endmodule
