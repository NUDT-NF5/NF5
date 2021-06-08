module ShuffleUnit(
    input  [`SIMD_DATA_WIDTH - 1:0] rs1,
    input  [`SIMD_DATA_WIDTH - 1:0] rs2,

    input                           clk,
    input                           rst_n,

    input  [`DATA_WIDTH - 1:0]      shuffle_ctl,
    input                           shuffle_ctl_en,

    output [`SIMD_DATA_WIDTH - 1:0] shuffle_result
);

reg [11:0] shuffle_ctl_r;

always @(posedge clk or negedge rst_n)
    if(~rst_n)
        shuffle_ctl_r <= 11'b0;
    else if(shuffle_ctl_en)
        shuffle_ctl_r <= shuffle_ctl[11:0];

wire [2 * `SIMD_DATA_WIDTH - 1:0] packed_rs;
wire [3:0] [2:0]                  shuffle_sel;

assign shuffle_sel[0] = shuffle_ctl_r[0+:3];
assign shuffle_sel[1] = shuffle_ctl_r[3+:3];
assign shuffle_sel[2] = shuffle_ctl_r[6+:3];
assign shuffle_sel[3] = shuffle_ctl_r[9+:3];
//assign shuffle_sel[4] = shuffle_ctl_r[12+:3];
//assign shuffle_sel[5] = shuffle_ctl_r[15+:3];
//assign shuffle_sel[6] = shuffle_ctl_r[18+:3];
//assign shuffle_sel[7] = shuffle_ctl_r[21+:3];

assign packed_rs = {rs2, rs1};

assign shuffle_result[15:0] =  shuffle_sel[0][2] ? 
                              (shuffle_sel[0][1] ? (shuffle_sel[0][0] ? rs2[63:48] : rs2[47:32]) :
                                                   (shuffle_sel[0][0] ? rs2[31:16] : rs2[15:0])) :
                              (shuffle_sel[0][1] ? (shuffle_sel[0][0] ? rs1[63:48] : rs1[47:32]) :
                                                   (shuffle_sel[0][0] ? rs1[31:16] : rs1[15:0]));

assign shuffle_result[31:16] = shuffle_sel[1][2] ? 
                              (shuffle_sel[1][1] ? (shuffle_sel[1][0] ? rs2[63:48] : rs2[47:32]) :
                                                   (shuffle_sel[1][0] ? rs2[31:16] : rs2[15:0])) :
                              (shuffle_sel[1][1] ? (shuffle_sel[1][0] ? rs1[63:48] : rs1[47:32]) :
                                                   (shuffle_sel[1][0] ? rs1[31:16] : rs1[15:0]));
assign shuffle_result[47:32] = shuffle_sel[2][2] ? 
                              (shuffle_sel[2][1] ? (shuffle_sel[2][0] ? rs2[63:48] : rs2[47:32]) :
                                                   (shuffle_sel[2][0] ? rs2[31:16] : rs2[15:0])) :
                              (shuffle_sel[2][1] ? (shuffle_sel[2][0] ? rs1[63:48] : rs1[47:32]) :
                                                   (shuffle_sel[2][0] ? rs1[31:16] : rs1[15:0]));
assign shuffle_result[63:48] = shuffle_sel[3][2] ? 
                              (shuffle_sel[3][1] ? (shuffle_sel[3][0] ? rs2[63:48] : rs2[47:32]) :
                                                   (shuffle_sel[3][0] ? rs2[31:16] : rs2[15:0])) :
                              (shuffle_sel[3][1] ? (shuffle_sel[3][0] ? rs1[63:48] : rs1[47:32]) :
                                                   (shuffle_sel[3][0] ? rs1[31:16] : rs1[15:0]));

endmodule