/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:adder32  module
 */
module adder_simd(
    input       [63:0]              a,
    input       [63:0]              b,
    input                           ci,
    input                           simd_ena,
    input       [`SIMD_WIDTH - 1:0] simd_ctl,    //'b01 2*32-bit  'b10 4*16-bit
    //input               saturation,
    output      [63:0]              s
);

wire [3:0]   c_temp;
wire [3:0]   mask;
wire [3:0]   carry;
wire [63:0]  s_temp;

assign mask = (simd_ctl[0] && simd_ena) ? 4'b1011 :
              (simd_ctl[1] && simd_ena) ? 4'b0001 :
                                          4'b1111 ;

assign carry = {c_temp[2:0], ci};

genvar i;
generate
    for(i = 0; i < 4; i = i + 1) begin: adder16
        adder_add #(
            .WIDTH(16)
        )
        adder16
        (
            .a(a[i*16+:16]),
            .b(b[i*16+:16]),
            .ci(carry[i] && mask[i]),
            .s(s[i*16+:16]),
            .c(c_temp[i])
        );
    end
endgenerate

endmodule

module adder_add #(
    parameter   WIDTH = 16
)
(
    input   [WIDTH - 1:0] a,
    input   [WIDTH - 1:0] b,
    input                 ci,
    output  [WIDTH - 1:0] s,
    output                c
);

assign {c, s} = a + b + ci;
endmodule