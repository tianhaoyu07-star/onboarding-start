module spi_peripheral (
    input wire clk, // this would be the internal clock
    input wire rst_n,

    input wire SCLK, // master's clock during SPI transmission
    input wire COPI,
    input wire nCS, 

    // we gotta specify the outputs now:
    // These will acts as inputs into the pwm_peripheral module
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
    

);

// Here, create synchronizers for each of the SPI input signals
wire sclk_synced, sclk_rise, sclk_fall;
wire copi_synced, copi_rise, copi_fall;
wire ncs_synced,  ncs_rise,  ncs_fall;

synchronizer #(.SYNC_STAGES(2)) sclk_sync_inst (
    .async_in       (SCLK),
    .clk            (clk),
    .sync_out       (sclk_synced),
    .rise_edge_tick (sclk_rise),
    .fall_edge_tick (sclk_fall)
);

synchronizer #(.SYNC_STAGES(2)) copi_sync_inst (
    .async_in       (COPI),
    .clk            (clk),
    .sync_out       (copi_synced),
    .rise_edge_tick (copi_rise),
    .fall_edge_tick (copi_fall)
);

    //synch for chip select just in case
synchronizer #(.SYNC_STAGES(2)) ncs_sync_inst (
    .async_in       (nCS),
    .clk            (clk),
    .sync_out       (ncs_synced),
    .rise_edge_tick (ncs_rise),
    .fall_edge_tick (ncs_fall)
);

endmodule


module synchronizer #(parameter SYNC_STAGES = 2)(
    input async_in,
    input clk,
    output reg sync_out, // this is our synchronized output
    output reg rise_edge_tick,
    output reg fall_edge_tick
);
    // text simplifications to make the following logic a bit more readable
        localparam T = 1'b1;
        localparam F = 1'b0;
    
    // start of actual synchronizers (3 flip flops in chain)
    reg [SYNC_STAGES-1:0] sync_regs = {SYNC_STAGES{1'b0}};  // init with all zeros

    always @(posedge clk) begin
        sync_regs <= {sync_regs[SYNC_STAGES-2:0], async_in};    // shift left for every clock tick, basically moving through the regs

        sync_out <= sync_regs[SYNC_STAGES-1];

        rise_edge_tick <= (sync_out != sync_regs[SYNC_STAGES-1]) & (sync_regs[SYNC_STAGES - 1] == T) ? T : F; // this is to check for if the edge just rose (from 0 to 1)
        fall_edge_tick <= (sync_out != sync_regs[SYNC_STAGES-1]) & (sync_regs[SYNC_STAGES - 1] == F) ? T : F;  // this checks the converse, falling edge (1->0)
  
    end
endmodule