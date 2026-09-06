module sram_matrix_array #(
    parameter int DATA_WIDTH = 8,   // Data width per memory word
    parameter int NUM_ROWS   = 16,  // Number of physical rows (Wordlines)
    parameter int NUM_COLS   = 4    // Number of physical columns per row
) (
    input  logic                                            i_clk,
    input  logic                                            i_cen,   // Active-low Chip Enable
    input  logic                                            i_wen,   // Active-low Write Enable
    input  logic [$clog2(NUM_ROWS)-1:0]                     i_row_addr,
    input  logic [$clog2(NUM_COLS)-1:0]                     i_col_addr,
    input  logic [DATA_WIDTH-1:0]                           i_din,
    output logic [DATA_WIDTH-1:0]                           o_dout
);

    // Physical 2D Matrix Array of SRAM Storage Words: [ROW][COL]
    logic [DATA_WIDTH-1:0] mem_matrix [NUM_ROWS-1:0][NUM_COLS-1:0];

    // Output Data Registers
    logic [DATA_WIDTH-1:0] r_dout;

    // -------------------------------------------------------------
    // 3. SYNCHRONOUS MEMORY ACCESS (Row x Column)
    // -------------------------------------------------------------
    always_ff @(posedge i_clk) begin
        if (!i_cen) begin
            // Synchronous Write Operation
            if (!i_wen) begin
                mem_matrix[i_row_addr][i_col_addr] <= i_din;
            end
            // Synchronous Read Operation
            r_dout <= mem_matrix[i_row_addr][i_col_addr];
        end
    end

    assign o_dout = r_dout;

endmodule
