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
module uart_top
  (
   input       i_clock,
   input       i_reset,

   input       i_rx_serial,
   output      o_tx_active,
   output      o_tx_serial,
   output      o_tx_done,
   output      o_rx_verify,

   input       i_conf_d0,
   input       i_conf_d1,
   input       i_conf_d2
   );

   wire [7:0] o_rx_byte;
   wire         o_rx_dv;

   reg [12:0] clks_per_bit;

    always @(*) begin
        case({i_conf_d2, i_conf_d1, i_conf_d0})
            3'b000: clks_per_bit = 13'd5208; // 9600 baud   (50M / 9600)
            3'b001: clks_per_bit = 13'd2604; // 19200 baud  (50M / 19200)
            3'b010: clks_per_bit = 13'd1302; // 38400 baud  (50M / 38400)
            3'b011: clks_per_bit = 13'd868;  // 57600 baud  (50M / 57600)
            3'b100: clks_per_bit = 13'd434;  // 115200 baud (50M / 115200)
            3'b101: clks_per_bit = 13'd217;  // 230400 baud
            3'b110: clks_per_bit = 13'd108;  // 460800 baud
            3'b111: clks_per_bit = 13'd54;   // 921600 baud
            default: clks_per_bit = 13'd434; // Default to 115200
        endcase
    end

   uart_tx uart_tx_inst
   (
     .i_Clock(i_clock),
     .i_Reset(i_reset),
     .i_Tx_DV(o_rx_dv),
     .i_Tx_Byte(o_rx_byte),
     .o_Tx_Active(o_tx_active),
     .o_Tx_Serial(o_tx_serial),
     .o_Tx_Done(o_tx_done),
     .clks_per_bit(clks_per_bit)
   );

   uart_rx uart_rx_inst
   (
     .i_Clock(i_clock),
     .i_Reset(i_reset),
     .i_Rx_Serial(i_rx_serial),
     .o_Rx_DV(o_rx_dv),
     .o_Rx_Byte(o_rx_byte),
     .clks_per_bit(clks_per_bit),
     .o_Rx_Verify(o_rx_verify)
   );

endmodule
