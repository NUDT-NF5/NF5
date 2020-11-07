/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:  logicm module
 */
module logicm(
    input   [`SIMD_DATA_WIDTH - 1:0]  logic_s1,
    input   [`SIMD_DATA_WIDTH - 1:0]  logic_s2,
    input   [2:0]                     logic_op,  //'b001 : and, 'b010 or, 'b100 xor
    output  [`SIMD_DATA_WIDTH - 1:0]  logic_result
);

assign logic_result = logic_op[0] ? logic_s1 & logic_s2 :
                      logic_op[1] ? logic_s1 | logic_s2 :
                      logic_op[2] ? logic_s1 ^ logic_s2 :
                      0;

endmodule