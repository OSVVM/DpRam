--
--  File Name:         DpRamComponentPkg.vhd
--  Design Unit Name:  DpRamComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Package for AXI4 Components
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    02/2022   2022.02    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2022 by SynthWorks Design Inc.
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      https://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--

library ieee ;
  use ieee.std_logic_1164.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;


package DpRamComponentPkg is

  ------------------------------------------------------------
  component DPRam is
  ------------------------------------------------------------
    generic ( 
      ADDR_WIDTH   : integer ;
      DATA_WIDTH   : integer ; 
      REGA_OUT     : boolean := FALSE ; 
      REGB_OUT     : boolean := FALSE ;
      MEMORY_NAME  : string  := ""
    ) ;
    port (
      ClkA        : In  std_logic ;
      WriteA      : In  std_logic ;
      AddrA       : In  std_logic_vector(ADDR_WIDTH-1 downto 0) ;
      DataInA     : In  std_logic_vector(DATA_WIDTH-1 downto 0) ;
      DataOutA    : Out std_logic_vector(DATA_WIDTH-1 downto 0) ;
    
      ClkB        : In  std_logic ;
      WriteB      : In  std_logic ;
      AddrB       : In  std_logic_vector(ADDR_WIDTH-1 downto 0) ;
      DataInB     : In  std_logic_vector(DATA_WIDTH-1 downto 0) ;
      DataOutB    : Out std_logic_vector(DATA_WIDTH-1 downto 0) 
    ) ; 
  end component DPRam ;



  ------------------------------------------------------------
  component DpRamController is
  ------------------------------------------------------------
  generic (
    MODEL_ID_NAME    : string := "" ;
    tperiod_Clk      : time   := 10 ns ;
    
    DEFAULT_DELAY    : time   := 1 ns ; 

    tpd_Clk_Address  : time   := DEFAULT_DELAY ;
    tpd_Clk_Write    : time   := DEFAULT_DELAY ;
    tpd_Clk_oData    : time   := DEFAULT_DELAY 
  ) ;
  port (
    -- Globals
    Clk         : In   std_logic ;
    nReset      : In   std_logic ;

    -- AXI Manager Functional Interface
    Address     : Out  std_logic_vector ;
    Write       : Out std_logic ;
    oData       : Out std_logic_vector ;
    iData       : In  std_logic_vector ;

    -- Testbench Transaction Interface
    TransRec    : InOut AddressBusRecType 
  ) ;
  end component DpRamController ;

end package DpRamComponentPkg ;

