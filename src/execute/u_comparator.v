/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: u_comparator  module
 */
module u_comparator(
    input   [31:0] s1,
    input   [31:0] s2,
    output  [2:0]  result
);

assign result = (s1 >  s2) ? 3'b100 :
                (s1 == s2) ? 3'b010 :
                (s1 <  s2) ? 3'b001 :
                3'b0;

endmodule