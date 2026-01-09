module reqgnt(
    input logic clk,
    input logic rst,
    input logic req,
    input logic gnt
);

// Instructions:
// 1. Implement "property P;" below.
// 2. Use auxiliary code.
// 3. Do not change the name of the property (keep it "P").
// 4. Do not change the label of the assert (keep it "A").

// IMPLEMENT THE AUXILIARY CODE HERE
logic signed [4:0] cnt;
logic [8:0] req_history;

always_ff @(posedge clk) begin
    if (rst) begin
        cnt <= 5'b0;
        req_history <= 9'b0;
    end else begin
        if (req && !gnt) cnt <= cnt + 1;
        if (!req && gnt) cnt <= cnt - 1;
        req_history <= {req_history[7:0], req};
    end
end


property P;
    @(posedge clk) disable iff (rst)
		(req |-> ##[2:8] gnt)
		&&
		(cnt >= 0)
		&&
		(gnt |-> (req_history[2] || req_history[3] || req_history[4] || 
              req_history[5] || req_history[6] || req_history[7] || 
              req_history[8]));
endproperty

A: assert property (P);

endmodule
