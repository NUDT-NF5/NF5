module OperandOrganizer(
    input [`SIMD_DATA_WIDTH - 1:0]  rs1,
    input [`SIMD_DATA_WIDTH - 1:0]  rs2,
    input [3:0]                     mask,
    input                           mask_ena,
    input                           simd_ena,
    input [`FUNCT3_WIDTH - 1 : 0]   funct3,

    output reg [`SIMD_DATA_WIDTH - 1:0] reorgnaized_rs1,
    output reg [`SIMD_DATA_WIDTH - 1:0] reorgnaized_rs2
);

reg      [`SIMD_DATA_WIDTH - 1:0]  rs1_temp;
reg      [`SIMD_DATA_WIDTH - 1:0]  rs2_temp;

always @*
    if(simd_ena && funct3[2])  //horizontal operation
        case(funct3[1:0])
            `SIMD16 : begin
                rs1_temp = {rs1[63:48], rs2[63:48], rs1[31:16], rs2[31:16]};
                rs2_temp = {rs1[47:32], rs2[47:32], rs1[15:0],  rs2[15:0]};
            end
            `SIMD32 : begin
                rs1_temp = {rs1[63:32], rs2[63:32]};
                rs2_temp = {rs1[31:0],  rs2[31:0]};
            end
            default : begin
                rs1_temp = reorgnaized_rs1;
                rs2_temp = reorgnaized_rs2;
            end
        endcase
    else begin
        rs1_temp = rs1;
        rs2_temp = rs2;
    end

always @*
    if(simd_ena && mask_ena)
        case(funct3[1:0])
            `SIMD16 : begin
                reorgnaized_rs1 = {{16{mask[3]}}, {16{mask[2]}}, {16{mask[1]}}, {16{mask[0]}}
                                  & rs1_temp};
                reorgnaized_rs2 = {{16{mask[3]}}, {16{mask[2]}}, {16{mask[1]}}, {16{mask[0]}}
                                  & rs2_temp};
            end
            `SIMD32 : begin
                reorgnaized_rs1 = {{32{mask[1]}}, {32{mask[0]}}} & rs1_temp;
                reorgnaized_rs2 = {{32{mask[1]}}, {32{mask[0]}}} & rs2_temp;
            end
            default : begin
                reorgnaized_rs1 = rs1_temp;
                reorgnaized_rs2 = rs2_temp;
            end
        endcase
    else begin
        reorgnaized_rs1 = rs1_temp;
        reorgnaized_rs2 = rs2_temp;
    end

endmodule