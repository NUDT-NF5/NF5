/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: shift   module
 */
module shift(
    input signed  [31:0] shift_s1,
    input         [4:0]  shift_s2,
    input         [2:0]  shift_type, //'b001 SLL, 'b010 SRL, 'b100 SRA
    output signed [31:0] shift_result
);

assign shift_result = shift_type[0] ? (shift_s1 << shift_s2) :
                      shift_type[1] ? (shift_s1 >> shift_s2) :
                      shift_type[2] ? (shift_s1 >>> shift_s2) :
                      0;

endmodule