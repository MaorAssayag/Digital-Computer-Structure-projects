// ====================================================================
//	File Name: WeightsBank.v
//	Description: Register file for the weights. include_file_5/8/16.v is an assign file
//              genreated from python code. The value from WeightsPrecsion5/8/16.txt
//              Each register stores 3 Weights lines.
//
// Parameters : WeightPrecision = 5/8/16
//              Amba_Addr_Depth = 12/13/14
//              WeightRowWidth = WeightPrecision * 3 = 15/24/48
//
//	Date: 28/11/2018
//	Designers: Maor Assayag, Refael Shetrit
// using Mentor Graphics HDL Designer(TM) 2012.1 (Build 6)
// ====================================================================
module WeightsBank (clock, reset, control, address, WriteData, ReadData);
   
  // PARAMETERS
  parameter Amba_Addr_Depth = 12;
  parameter WeightPrecision = 5; 
  parameter WeightRowWidth = 15;
  localparam WRITE = 2'b01;
  localparam READ  = 2'b10;
  
  // DEFINE INPUTS VARS
  input wire clock;
  input wire reset;
  input wire [1:0] control;
  input wire [(Amba_Addr_Depth):0]  address;
  input wire [(WeightRowWidth - 1):0]   WriteData;
  
  // DEFINE OUTPUTS VARS
  output wire [(WeightRowWidth - 1):0]  ReadData;
  
  // LOCAL vars
  reg [(WeightRowWidth - 1):0] RegisterBank [(2**Amba_Addr_Depth)- 1:0];
  reg signed [WeightRowWidth - 1:0] out_val;
  reg en_read;

  // BODY - Read and write from register file
  // control = 01 -> Write at least 3 wieghts to the register
  // control = 10 -> Read 1 data address of wights for the CPU
  always @(posedge clock) begin : WeightsBankOperation
    if (reset) 
      begin   
      out_val <= {(WeightRowWidth){1'b0}};
      en_read <= 1'b0;
      case (WeightPrecision) // intialize RegisterBank  
        5'b00101 : begin `include "../rtl/include_file_5.v" end
        5'b01000 : begin `include "../rtl/include_file_8.v" end
        5'b10000 : begin `include "../rtl/include_file_16.v" end
        default  : begin `include "../rtl/include_file_5.v" end
      endcase 
    end
    else 
      begin 
      en_read <= control[1];   
      case (control)
        WRITE : RegisterBank[address] <= WriteData; // Write weight data
        READ  : out_val <= RegisterBank[address];   // Read weight data
        default : out_val <= {WeightRowWidth{1'bz}};
      endcase
    end
  end
  // Output data if not writing. If we are writing, do not drive output pins. This is denoted
  // by assigning 'z' to the output pins.
  assign ReadData = (en_read) ?  out_val : {(WeightRowWidth){1'bz}};

endmodule
