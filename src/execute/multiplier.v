/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:  multiplier module
 */
module multiplier(
    input       [63:0]                a,
    input       [63:0]                b,
    input                             simd_ena,
    input       [1:0]   simd_ctl,      //01 2*32-bit  10 4*16-bit
    input       [1:0]                 sign,
    output      [127:0]               mul64_out
);

wire            [63:0]                mul_32_0;
wire            [63:0]                mul_32_1;
wire            [63:0]                mul_32_2;
wire            [63:0]                mul_32_3;

wire            [31:0]                wallace_layer0_0;
wire            [31:0]                wallace_layer0_1;

wire            [31:0]                carry0;
wire            [31:0]                carry1;

wire            [63:0]                real_a;
wire            [63:0]                real_b;

wire            [137:0]               wallace_out_temp;
wire            [1:0]                 sign32;
wire            [1:0]                 sign16;

assign real_a  = (sign[1] && ~simd_ena && a[63]) ? ~a + 1 : a;
assign real_b  = (sign[0] && ~simd_ena && b[63]) ? ~b + 1 : b;
wire   sign32_help = (simd_ctl == 2'b01) && simd_ena;
wire   sign16_help = (simd_ctl == 2'b10) && simd_ena;
assign sign32  = sign & {sign32_help, sign32_help};
assign sign16  = sign & {sign16_help, sign16_help};
assign convert = (&sign && (a[63] ^ b[63])) || ((sign == 2'b10) && a[63]) || ((sign == 2'b01) && b[63]);

mul32 mul32_0(
    .a(real_a[31:0]),
    .b(real_b[31:0]),
    .simd(simd_ena && simd_ctl[1]),
    .sign32(sign32),
    .sign16(sign16),
    .c(mul_32_0)
);

/*mul32 mul32_1(
    .a(real_a[63:32]),
    .b(real_b[31:0]),
    .simd(1'b0),
    .sign32(2'b0),
    .sign16(sign16),
    .c(mul_32_1)
);

mul32 mul32_2(
    .a(real_a[31:0]),
    .b(real_b[63:32]),
    .simd(1'b0),
    .sign32(2'b0),
    .sign16(sign16),
    .c(mul_32_2)
);*/

mul32 mul32_3(
    .a(real_a[63:32]),
    .b(real_b[63:32]),
    .simd(simd_ena && simd_ctl[1]),
    .sign32(sign32),
    .sign16(sign16),
    .c(mul_32_3)
);

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : layer0_0
        csa adder_layer0_0(
            .op1(mul_32_0[i + 32]),
            .op2(mul_32_1[i]),
            .op3(mul_32_2[i]),
            .s(wallace_layer0_0[i]),
            .co(carry0[i])
        );
    end
endgenerate

genvar j;
generate
    for (j = 0; j < 32; j = j + 1) begin : layer0_1
        csa adder_layer0_1(
            .op1(mul_32_1[j + 32]),
            .op2(mul_32_2[j + 32]),
            .op3(mul_32_3[j]),
            .s(wallace_layer0_1[j]),
            .co(carry1[j])
        );
    end
endgenerate

wire [31 + 32 + 32 - 1:0]   c_temp;

adder_mul #(
    .width(31 + 32 + 32)
)
wallace_out(
    .op1({31'b0, carry1, carry0}),
    .op2({mul_32_3[63:32], wallace_layer0_1, wallace_layer0_0[31:1]}),
    .s(c_temp)
);

assign wallace_out_temp = {c_temp, wallace_layer0_0[0], mul_32_0[31:0]};
assign mul64_out = simd_ena ? {mul_32_3, mul_32_0} : 
                   convert  ? ~wallace_out_temp + 1 :
                              wallace_out_temp;

endmodule

module mul32(
    input       [31:0]  a,
    input       [31:0]  b,
    input               simd,
    input       [1:0]   sign32,
    input       [1:0]   sign16,
    output      [63:0]  c
);

wire            [15:0]  wallace_layer0_0;
wire            [15:0]  carry0;

wire            [15:0]  wallace_layer0_1;
wire            [15:0]  carry1;

wire            [31:0]  mul_16_0;
wire            [31:0]  mul_16_1;
wire            [31:0]  mul_16_2;
wire            [31:0]  mul_16_3;

wire            [31:0]                real_a;
wire            [31:0]                real_b;

wire            [63:0]               wallace_out_temp;

assign real_a  = (sign32[1] && a[31]) ? ~a + 1 : a;
assign real_b  = (sign32[0] && b[31]) ? ~b + 1 : b;
assign convert = (&sign32 && (a[31] ^ b[31])) || ((sign32 == 2'b10) && a[31]) || ((sign32 == 2'b01) && b[31]);

mul_16 mul16_0(
    .a(real_a[15:0]),
    .b(real_b[15:0]),
    .sign16(sign16),
    .c(mul_16_0)
);

mul_16 mul16_1(
    .a(real_a[31:16]),
    .b(real_b[15:0]),
    .sign16(sign16),
    .c(mul_16_1)
);

mul_16 mul16_2(
    .a(real_a[15:0]),
    .b(real_b[31:16]),
    .sign16(sign16),
    .c(mul_16_2)
);

mul_16 mul16_3(
    .a(real_a[31:16]),
    .b(real_b[31:16]),
    .sign16(sign16),
    .c(mul_16_3)
);

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : layer0_0
        csa adder_layer0_0(
            .op1(mul_16_0[i + 16]),
            .op2(mul_16_1[i]),
            .op3(mul_16_2[i]),
            .s(wallace_layer0_0[i]),
            .co(carry0[i])
        );
    end
endgenerate

genvar j;
generate
    for (j = 0; j < 16; j = j + 1) begin : layer0_1
        csa adder_layer0_1(
            .op1(mul_16_1[j + 16]),
            .op2(mul_16_2[j + 16]),
            .op3(mul_16_3[j]),
            .s(wallace_layer0_1[j]),
            .co(carry1[j])
        );
    end
endgenerate

wire [15 + 16 + 16 - 1:0]   c_temp;

adder_mul #(
    .width(15 + 16 + 16)
)
wallace_out(
    .op1({15'b0, carry1, carry0}),
    .op2({mul_16_3[31:16], wallace_layer0_1, wallace_layer0_0[15:1]}),
    .s(c_temp)
);

assign wallace_out_temp = {c_temp, wallace_layer0_0[0], mul_16_0[15:0]};
assign c = simd    ? {mul_16_3, mul_16_0} : 
           convert ? ~wallace_out_temp + 1'b1 : 
                      wallace_out_temp;

endmodule

module mul_16(
    input       [15:0]  a,
    input       [15:0]  b,
    input       [1:0]   sign16,
    output      [31:0]  c
);

wire            [15:0]  real_a;
wire            [15:0]  real_b;
wire            [31:0]  c_temp;

assign real_a  = (sign16[1] && a[15]) ? ~a + 1 : a;
assign real_b  = (sign16[0] && b[15]) ? ~b + 1 : b;
assign convert = (&sign16 && (a[15] ^ b[15])) || ((sign16 == 2'b10) && a[15]) || ((sign16 == 2'b01) && b[15]);

assign c_temp = real_a * real_b;
assign c      = convert ? ~c_temp + 1 : c_temp;

endmodule

module csa(
    input               op1,
    input               op2,
    input               op3,
    output              s,
    output              co
);

assign {co,s} = op1 + op2 + op3;

endmodule

module adder_mul
#(
    parameter           width = 32
)
(
    input       [width - 1:0] op1,
    input       [width - 1:0] op2,
    output      [width - 1:0] s
);

wire                          co;
assign {co,s} = op1 + op2;

endmodule