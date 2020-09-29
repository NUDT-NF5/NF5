/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2020-02-27 09:33:48
 * @Describe:divider  module
 */
module divider #(
    parameter DLEN = 33,
    parameter RLEN = 33
)
(
    input                clk,
    input                rst_n, 
    input   [DLEN - 1:0] div_s1,//dividend 
    input   [RLEN - 1:0] div_s2,//divisor 
    input                div_start, 
    output reg [DLEN - 1:0] div_quotient,
    output reg [RLEN - 1:0] div_remainder,
    output               div_ready
);
    
    reg     [DLEN - 1:0] reg_q; 
    reg     [RLEN - 1:0] reg_r; 
    reg     [RLEN - 1:0] reg_b; 
    reg     [5:0]        count; 
    //reg                  busy2,
    reg                  r_sign; 
    reg     [3:0]        state;
    reg                  state2;

    wire    [RLEN:0]     sub_add;
    wire    [RLEN - 1:0] unsigned_s1;
    wire    [DLEN - 1:0] unsigned_s2;
    wire    [RLEN - 1:0] unsigned_quotient;
    wire    [DLEN - 1:0] unsigned_remainder;

    parameter   IDLE = 4'b0001;
    parameter   CALC = 4'b0010;
    parameter   ADJSIGN = 4'b0100;
    parameter   NOOP = 4'b1000;

always @(posedge clk or negedge rst_n)
    if(~rst_n)
        state <= IDLE;
    else 
        case (state)
            IDLE :
                if(div_start)
                    case(|div_s2)
                        1'b1 : 
                            state <= CALC;
                        default:
                            state <= ADJSIGN;
                    endcase
            CALC : 
                if(count == DLEN - 1) 
                    state <= ADJSIGN;
            ADJSIGN :
                state <= NOOP;
            default :
                state <= IDLE;
        endcase

always @(posedge clk or negedge rst_n)
    if(~rst_n)
        state2 <= 0;
    else
        state2 <= state[2];

always @(posedge clk or negedge rst_n)
    if(~rst_n)begin
        count <= 5'b0;//reset count 
        r_sign <= 0;
        reg_r <= 0;
        reg_q <= 0;
        reg_b <= 0;
        div_quotient <= 0;
        div_remainder <= 0;
    end 
    else
        case (state)
            CALC : begin
                reg_r  <= sub_add[RLEN - 1:0];// partial remainder 
                r_sign <= sub_add[RLEN];//if minus,add next 
                reg_q  <= {reg_q[DLEN - 2:0], ~sub_add[RLEN]};//1-bit g 
                count  <= count + 5'b1;
                /*if(count == DLEN - 1)
                    div_busy <= 0;*/                      //finish 
            end
            ADJSIGN : begin
                case((div_s1[DLEN - 1] ^ div_s2[RLEN - 1]) && div_s2)
                    1'b1 : 
                        div_quotient <= ~unsigned_quotient + 1'b1;
                    default :
                        div_quotient <= unsigned_quotient;
                endcase
                case(div_s1[DLEN - 1] && div_s2)
                    1'b1 : 
                        div_remainder <= ~unsigned_remainder + 1'b1;
                    default :
                        div_remainder <= unsigned_remainder;
                endcase
            end
            default :
                if(div_start)begin
                    case(|div_s2)
                        1'b1: begin
                            reg_r  <= 0; 
                            r_sign <= 0;     
                            reg_q  <= unsigned_s1;
                            reg_b  <= unsigned_s2;
                            count  <= 5'b0;
                            div_quotient <= 0;
                            div_remainder <= 0;
                            //div_busy   <= 1'b1;
                        end
                        default: begin
                            reg_r  <= div_s1; 
                            r_sign <= 0;     
                            reg_q  <= ~0;
                            reg_b  <= 0;
                            count  <= 5'b0;
                            div_quotient <= 0;
                            div_remainder <= 0;
                        end
                    endcase
                end
                else begin
                    reg_r  <= 0; 
                    r_sign <= 0;     
                    reg_q  <= 0;
                    reg_b  <= 0;
                    count  <= 5'b0;
                    div_quotient <= 0;
                    div_remainder <= 0;
                end
        endcase

assign sub_add = r_sign ? {reg_r,unsigned_quotient[DLEN - 1]} + {1'b0,reg_b}:
                          {reg_r,unsigned_quotient[DLEN - 1]} - {1'b0,reg_b}; 
assign unsigned_remainder = r_sign ? reg_r + reg_b : reg_r;// adjust remainder 
assign unsigned_quotient  = reg_q; 
assign unsigned_s1 = div_s1[DLEN - 1] ? ~div_s1 + 1'b1 : div_s1;
assign unsigned_s2 = div_s2[DLEN - 1] ? ~div_s2 + 1'b1 : div_s2;
assign div_ready = state2 && state[3];

endmodule