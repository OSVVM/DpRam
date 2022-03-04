--
--  File Name:		DpRam_Singleton.vhd
--  Block Name:		DpRam_Singleton
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
--  Contributor(s):            
--     Jim Lewis      email:  jim@synthworks.com   
--
--  Description
--      Package defines a protected type, MemoryPType, and methods  
--      for efficiently implementing memory data structures
--    
--  Developed for: 
--        SynthWorks Design Inc. 
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    12/2021   2021.12    Initial for PT
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2021 by SynthWorks Design Inc.  
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

library IEEE ;
  use ieee.std_logic_1164.all ;
library OSVVM ; 
  context OSVVM.OsvvmContext ;

entity DpRam is
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
end entity DPRam ;

architecture Singleton of DpRam is
  constant INST_NAME : string :=
    IfElse(MEMORY_NAME /= "", MEMORY_NAME, to_lower(PathTail(DpRam'PATH_NAME))) ;
    
  constant Mem : MemoryIdType := NewID(
    Name      => INST_NAME, 
    AddrWidth => ADDR_WIDTH,  
    DataWidth => DATA_WIDTH, 
    Search    => NAME
  ) ;
  
  signal iDataOutA, iDataOutB : std_logic_vector(DATA_WIDTH-1 downto 0) ;
begin
  
  MemProcA : process (ClkA) 
  begin
    if rising_edge(ClkA) then	  
      iDataOutA <= MemRead(Mem, AddrA) ; 
      if WriteA = '1' then 
        MemWrite(Mem, AddrA, DataInA) ; 
      end if ;
    end if ;
  end process MemProcA ;
  
  RegAOutGen : if REGA_OUT generate 
    RegAProc : process(ClkA)
    begin
      if rising_edge(ClkA) then	  
        DataOutA <= iDataOutA ; 
      end if ;
    end process RegAProc ; 
  else generate 
    DataOutA <= iDataOutA ; 
  end generate ; 

  MemProcB : process (ClkB) 
  begin	
    if rising_edge(ClkB) then	  
      iDataOutB <= MemRead(Mem, AddrB) ; 
      if WriteB = '1' then 
        MemWrite(Mem, AddrB, DataInB) ; 
      end if ;
    end if ;
  end process MemProcB ;
  
  RegBOutGen : if REGB_OUT generate 
    RegBProc : process(ClkB)
    begin
      if rising_edge(ClkB) then	  
        DataOutB <= iDataOutB ; 
      end if ;
    end process RegBProc ; 
  else generate 
    DataOutB <= iDataOutB ; 
  end generate ; 

end Singleton ;
