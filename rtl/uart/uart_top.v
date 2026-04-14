//////////////////////////////////////////////////////////////////////
// Project : RTL → GDS UART (Tapeout)
//
// Module  : Top Module (top)
//
// Description:
// Top-level UART loopback module.
// Connects UART RX → UART TX.
// Demonstrates full receive/transmit functionality.
//
// Notes:
//  - Uses fixed baud rate for RX/TX
//  - Compatible with loopback tests and TinyTapeout
//  - Ready for OpenLane / Sky130 flow
//
// Author: Tejas Dabhankar 
//////////////////////////////////////////////////////////////////////
module uart_top(
    /* Clock input */
    input clk,

    /* UART Signals */
    output tx_active,
    output tx_done,
    output tx_serial,
    input  rx_serial,

    input d0,
    input d1,
    input d2
);

    /* Parameters */
    reg [15:0] Clock_Count;

    /* UART Interface Wires */
    wire [7:0] w_received_byte;       // Adjust PHY_FIFO_WIDTH if needed
    wire w_data_dv;

    /* Example config data (replace as per your design) */
    reg [7:0] r_config_data;
    wire rd_phy_fifo_en;
    wire [7:0] rd_phy_fifo_data;

    /* Clock divider selection */
    always @(*) begin
        case ({d2,d1,d0})
            3'b000: r_Clock_Count = 5208;
            3'b001: r_Clock_Count = 2604;
            3'b010: r_Clock_Count = 1302;
            3'b011: r_Clock_Count = 868;
            3'b100: r_Clock_Count = 434;
            default: r_Clock_Count = 5208;
        endcase
    end

    /* UART Transmitter Instance */
    uart_tx uarttx (
        .i_Clock(clk),
        .Clock_Count(r_Clock_Count),
        .i_Tx_DV(w_data_dv),
        .i_Tx_Byte(w_received_byte),
        .o_Tx_Active(tx_active),
        .o_Tx_Serial(tx_serial),
        .o_Tx_Done(tx_done)
    );

    /* UART Receiver Instance */
    uart_rx uartrx (
        .i_Clock(clk),
        .Clock_Count(r_Clock_Count),
        .i_Rx_Serial(rx_serial),
        .uart_config_data(r_config_data),
        .o_Rx_DV(w_data_dv),
        .o_Rx_Byte(w_received_byte)
    );

endmodule
