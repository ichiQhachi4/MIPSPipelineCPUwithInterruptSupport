`include "./ctrl_encode_define.v"


module Ext(Immediate16, ExtOp, Immediate32);
    input [15:0] Immediate16;
    input [1:0] ExtOp;
    output [31:0] Immediate32;
    reg [31:0] Immediate32;


    always @(*) begin
      case (ExtOp)
        `ZERO_EXT: Immediate32 <= {16'd0, Immediate16};
        `SIGN_EXT: Immediate32 <= {{16{Immediate16[15]}}, Immediate16};
        `LUI_EXT:  Immediate32 <= {Immediate16, 16'd0};

        default: Immediate32 <= 32'd0;
      endcase
    end
endmodule // Extension
