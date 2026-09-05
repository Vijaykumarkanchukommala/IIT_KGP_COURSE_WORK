module sram_tristate_bus #(
    parameter int NUM_BANKS = 4,       // Number of input sources
    parameter int DATA_WIDTH = 8                // DATA_WIDTHidth of each source/o_bus_output
)(
    input  logic [DATA_WIDTH-1:0] i_data[NUM_BANKS-1:0],
    input  logic [NUM_BANKS -1:0] i_enable,
    output wire  [DATA_WIDTH-1:0] o_bus_output
);

    genvar i;

    generate
        for (i = 0; i < NUM_BANKS; i++) begin : GEN_TRISTATE
            assign o_bus_output = i_enable[i] ? i_data[i] : 'bz;
        end
    endgenerate

endmodule
