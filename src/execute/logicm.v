module logicm(
    input   [31:0]  logic_s1,
    input   [31:0]  logic_s2,
    input   [2:0]   logic_op,  //'b001 : and, 'b010 or, 'b100 xor
    output  [31:0]  logic_result
);

assign logic_result = logic_op[0] ? logic_s1 & logic_s2 :
                      logic_op[1] ? logic_s1 | logic_s2 :
                      logic_op[2] ? logic_s1 ^ logic_s2 :
                      0;

endmodule