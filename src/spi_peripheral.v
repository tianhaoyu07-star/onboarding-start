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

// Now we need to define the synchronizer to avoid metastability (since our clk and SCLK lines are asynchronous)
reg [2:0] sclk_sync;
reg [2:0] copi_sync;
reg [2:0] ncs_sync;




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
        sync_regs <= {sync_regs[SYNC_STAGES-2:0], async_in};    // shift left for every clock tick
        sync_out <= sync_regs[SYNC_STAGES-1];

        rise_edge_tick <= (sync_out != sync_regs[SYNC_STAGES-1]) & (sync_regs[SYNC_STAGES - 1] == T) ? T : F; 
        fall_edge_tick <= (sync_out != sync_regs[SYNC_STAGES-1]) & (sync_regs[SYNC_STAGES - 1] == F) ? T : F; 
  
    end
endmodule