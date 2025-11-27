`include "multiplication.sv"
`include "globals.sv"
`include "main_module.sv"
import global_types::*;
module main_module_tb2;
    // Inputs
    logic [31:0] sys_a, prev_a1,prev_a2;
    logic [31:0] sys_b, prev_b1, prev_b2;
    logic [2:0] sys_rnd, prev_rnd1, prev_rnd2;
    logic sys_clk, sys_rst;
    // Outputs
    logic [0:7] sys_status;
    logic [31:0] sys_z;
    string rounding_mode[6] = {"IEEE_near","IEEE_zero","IEEE_pinf","IEEE_ninf","near_up","away_zero"};
    boundary_cond conditions[12] = {pos_qnan,neg_qnan,pos_snan,neg_snan,pos_inf,neg_inf,pos_zero,neg_zero,pos_denorm,neg_denorm,pos_norm,neg_norm};
  // Instantiate the (DUT)
    fp_mult_top dut (
	.clk(sys_clk),
        .a(sys_a),
        .b(sys_b),
        .rnd(sys_rnd),
        .status(sys_status),
        .z(sys_z),
	.rst(sys_rst)
    );
// Bind additional functionality or assertions to main_module
  bind fp_mult_top my_dut_assertions dutbound (clk,a,b,rnd,status,z);


//Give our clock the desired period and run it forever
initial begin
	sys_rst = 1'b0;
	sys_clk = 1'b1;
	forever #8ns sys_clk = ~sys_clk;
end


    initial begin
        // Initialize input
        sys_rnd = 3'b000;
	for(int i = 0; i < 12; i++) begin
		sys_a <= conditions[i];
		//$display("a = \t [bin] %b",a);
		for(int j = 0; j < 12; j++) begin
			sys_b <= conditions[j];
		        #16ns;
			end
		end
	end
    initial begin
	#16ns
	forever begin
	prev_a1 = sys_a;
	prev_b1 = sys_b;
	prev_rnd1 = sys_rnd;	
	#32ns;
	//If output differs from expected, print everything in order to debug
	if(multiplication(rounding_mode[prev_rnd1],prev_a1,prev_b1) != sys_z) begin
				$display("found mistake");
				$display("a = %b",prev_a1);
				$display("b = %b",prev_b1);
				$display("mode = %s",rounding_mode[prev_rnd1]);
				$display("z = %b",sys_z);
				$display("r = %b",multiplication(rounding_mode[prev_rnd1],prev_a1,prev_b1));
			end
	end
end
initial begin
	#32ns
	forever begin
	prev_a2 = sys_a;
	prev_b2 = sys_b;
	prev_rnd2 = sys_rnd;
	#32ns;
	//If output differs from expected, print everything in order to debug
	if(multiplication(rounding_mode[prev_rnd2],prev_a2,prev_b2) != sys_z) begin
				$display("found mistake");
				$display("a = %b",prev_a2);
				$display("b = %b",prev_b2);
				$display("mode = %s",rounding_mode[prev_rnd2]);
				$display("z = %b",sys_z);
				$display("r = %b",multiplication(rounding_mode[prev_rnd2],prev_a2,prev_b2));
			end
	end
end
endmodule
