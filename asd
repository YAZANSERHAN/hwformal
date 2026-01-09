// IMPLEMENT THE AUXILIARY CODE HERE
// Track a single value through the FIFO to verify order
logic [WIDTH-1:0] tracked_value;      // The value we're tracking
logic             tracking;            // Are we currently tracking a value?
logic [PTRW:0]    items_ahead;        // How many items are ahead of our tracked value

always_ff @(posedge clk) begin
  if (!rst) begin
    tracking <= 1'b0;
    tracked_value <= '0;
    items_ahead <= '0;
  end else begin
    // Start tracking when we enqueue and not already tracking
    if (do_enq && !tracking) begin
      tracked_value <= enq_data;
      tracking <= 1'b1;
      items_ahead <= count;  // All current items are ahead of this new one
    end
    
    // Update counter as items are enqueued/dequeued
    if (tracking) begin
      if (do_enq && !do_deq) begin
        // Another item enqueued, doesn't affect items_ahead
      end else if (!do_enq && do_deq) begin
        // Item dequeued, our tracked item moves closer to front
        items_ahead <= items_ahead - 1'b1;
      end
      // if both enq and deq, items_ahead stays same
      
      // Stop tracking after our item is dequeued
      if (do_deq && items_ahead == 0) begin
        tracking <= 1'b0;
      end
    end
  end
end

property P;
  @(posedge clk) disable iff (!rst)
  (tracking && do_deq && (items_ahead == 0)) |-> ##1 (deq_data == tracked_value);
endproperty

A: assert property (P);
