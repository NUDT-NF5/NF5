/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: shift   module
 */
module shift(
    input signed  [`SIMD_DATA_WIDTH - 1:0] shift_s1,
    input         [4:0]                    shift_s2,
    input         [2:0]                    shift_type, //'b001 SLL, 'b010 SRL, 'b100 SRA
    input                                  simd_ena,
    input         [1:0]                    simd_ctl,   //'b01 simd32, 'b10 simd16
    output signed [`SIMD_DATA_WIDTH - 1:0] shift_result
);

assign shift_result = (simd_ena && simd_ctl[0]) ?
                      (shift_type[0] ? {(shift_s1[63:32] << shift_s2), (shift_s1[31:0] << shift_s2)} :
                      shift_type[1] ? {(shift_s1[63:32] >> shift_s2), (shift_s1[31:0] >> shift_s2)} :
                      shift_type[2] ? {($signed(shift_s1[63:32]) >>> shift_s2), ($signed(shift_s1[31:0]) >>> shift_s2)} :
                      0):
                      (simd_ena && simd_ctl[1]) ?
                      (shift_type[0] ? {(shift_s1[63:48] << shift_s2), (shift_s1[47:32] << shift_s2), 
                                       (shift_s1[31:16] << shift_s2), (shift_s1[15:0] << shift_s2)} :
                      shift_type[1] ? {(shift_s1[63:48] >> shift_s2), (shift_s1[47:32] >> shift_s2), 
                                       (shift_s1[31:16] >> shift_s2), (shift_s1[15:0] >> shift_s2)} :
                      shift_type[2] ? {($signed(shift_s1[63:48]) >>> shift_s2), ($signed(shift_s1[47:32]) >>> shift_s2), 
                                       ($signed(shift_s1[31:16]) >>> shift_s2), ($signed(shift_s1[15:0]) >>> shift_s2)} :
                      0):
                      (shift_type[0] ? (shift_s1 << shift_s2) :
                      shift_type[1] ? (shift_s1 >> shift_s2) :
                      shift_type[2] ? (shift_s1 >>> shift_s2) :
                      0);

endmodule