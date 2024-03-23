--
--  File Name:         DpRamController.vhd
--  Design Unit Name:  DpRamController
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      DpRam manager verification component
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    03/2024   2024.03    Updated SafeResize to use ModelID
--    05/2023   2023.05    Added LocalAddress to hold address so read operation log correct address
--    03/2022   2022.03    Initial revision
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
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

entity DpRamController is
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

  -- DpRam Functional Interface
  Address     : Out  std_logic_vector ;
  Write       : Out std_logic ;
  oData       : Out std_logic_vector ;
  iData       : In  std_logic_vector ;

  -- Testbench Transaction Interface
  TransRec    : InOut AddressBusRecType 
) ;

  -- Derive ModelInstance label from path_name
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, to_lower(PathTail(DpRamController'PATH_NAME))) ;

end entity DpRamController ;
architecture SimpleBlocking of DpRamController is
  signal ModelID : AlertLogIDType ;

begin

  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ;
  begin
    -- Alerts
    ID        := NewID(MODEL_INSTANCE_NAME) ;
    ModelID   <= ID ;
    wait ;
  end process Initialize ;


  ------------------------------------------------------------
  --  Transaction Handler
  --    Decodes Transactions and Handlers DUT Interface
  ------------------------------------------------------------
  TransactionHandler : process
    alias Operation : AddressBusOperationType is TransRec.Operation ;
    variable ExpectedData : iData'subtype ; 
    variable LocalAddress : Address'subtype ; 

    variable NumFifoElements   : integer ; -- number of fifo elements
  begin
    -- Initialize Outputs
    Address     <= (Address'range  => 'X') ; 
    Write       <= 'X' ; 
    oData       <= (oData'range => 'X') ; 
    
    wait for 0 ns ; -- Allow ModelID to become valid
    TransRec.WriteBurstFifo <= NewID("WriteBurstFifo",         ModelID, Search => PRIVATE_NAME) ;
    TransRec.ReadBurstFifo  <= NewID("ReadBurstFifo",          ModelID, Search => PRIVATE_NAME) ;


    loop
      WaitForTransaction(
         Clk      => Clk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;
      
--** see alias      Operation := TransRec.Operation ; 
      
      case Operation is
        -- Execute Standard Directive Transactions
        when WAIT_FOR_TRANSACTION =>
          wait for 0 ns ; 

        when WAIT_FOR_CLOCK =>
          WaitForClock(Clk, TransRec.IntToModel) ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelID) ;

        -- Model Transaction Dispatch
        when WRITE_OP =>
          LocalAddress := SafeResize(ModelID, TransRec.Address, Address'length);
          Address <= LocalAddress after tpd_Clk_Address ;
          oData   <= SafeResize(ModelID, TransRec.DataToModel, oData'length)  after tpd_Clk_oData ;
          Write   <= '1' after tpd_Clk_Write ; 
          WaitForClock(Clk) ; 
          
          -- Write Operation Accepted at this clock edge
          Log( ModelID,
            "Write Operation, Address: " & to_hxstring(LocalAddress) &
            "  Data: " & to_hxstring(oData) &
            "  Operation# " & to_string (TransRec.Rdy),
            INFO,
            TransRec.StatusMsgOn
          ) ;
          Address <= not LocalAddress after tpd_Clk_Address ;
          oData   <= not oData    after tpd_Clk_oData ;
          Write   <= '0' after tpd_Clk_Write ; 
          
        when READ_OP | READ_CHECK =>
          LocalAddress := SafeResize(ModelID, TransRec.Address, Address'length);
          Address <= LocalAddress after tpd_Clk_Address ;
          Write   <= '0' after tpd_Clk_Write ; 
          WaitForClock(Clk) ; 
          
          Address <= not LocalAddress after tpd_Clk_Address ;
          WaitForClock(Clk) ; 

--! TODO: Add settings for read taking another clock          
--          if ... then 
--            WaitForClock(Clk) ; 
--          end if ; 
          
          TransRec.DataFromModel <= SafeResize(ModelID, iData, TransRec.DataFromModel'length) ;

          if IsReadCheck(Operation) then
            ExpectedData  := SafeResize(ModelID, TransRec.DataToModel, ExpectedData'length) ;
            AffirmIfEqual(ModelID,
              iData, ExpectedData,
              "Read Operation, Address: " & to_hxstring(LocalAddress) &
              "  Operation# " & to_string (TransRec.Rdy) & 
              "  Data: ", 
              TransRec.StatusMsgOn or IsLogEnabled(ModelID, INFO)
            ) ;
          else
            Log( ModelID,
              "Read Operation, Address: " & to_hxstring(LocalAddress) &
              "  Data: " & to_hxstring(iData) &
              "  Operation# " & to_string (TransRec.Rdy),
              INFO,
              TransRec.StatusMsgOn
            ) ;
          end if ; 
          
        when WRITE_AND_READ =>
          LocalAddress := SafeResize(ModelID, TransRec.Address, Address'length);
          Address <= LocalAddress after tpd_Clk_Address ;
          oData   <= SafeResize(ModelID, TransRec.DataToModel, oData'length)  after tpd_Clk_oData ;
          Write   <= '1' after tpd_Clk_Write ; 
          
          WaitForClock(Clk) ; 
          Log( ModelID,
            "Write Operation, Address: " & to_hxstring(LocalAddress) &
            "  Data: " & to_hxstring(oData) &
            "  Operation# " & to_string (TransRec.Rdy),
            INFO,
            TransRec.StatusMsgOn
          ) ;
          Address <= not LocalAddress after tpd_Clk_Address ;
          oData   <= not oData    after tpd_Clk_oData ;
          Write   <= '0' after tpd_Clk_Write ; 
        
          WaitForClock(Clk) ; 
--! TODO: Add settings for read taking another clock          
--          if ... then 
--            WaitForClock(Clk) ; 
--          end if ; 
          
          TransRec.DataFromModel <= SafeResize(ModelID, iData, TransRec.DataFromModel'length) ;
          
          if IsReadCheck(Operation) then
            ExpectedData  := SafeResize(ModelID, TransRec.DataToModel, ExpectedData'length) ;
            AffirmIfEqual(ModelID,
              iData, ExpectedData,
              "Read Operation, Address: " & to_hxstring(LocalAddress) &
              "  Operation# " & to_string (TransRec.Rdy) & 
              "  Data: ", 
              TransRec.StatusMsgOn or IsLogEnabled(ModelID, INFO)
            ) ;
          else
            Log( ModelID,
              "Read Operation, Address: " & to_hxstring(LocalAddress) &
              "  Data: " & to_hxstring(iData) &
              "  Operation# " & to_string (TransRec.Rdy),
              INFO,
              TransRec.StatusMsgOn
            ) ;
          end if ; 
          
        when WRITE_BURST =>
            log(ModelID, 
              "Initiating write burst operation in DpRamController", 
              INFO,
              TransRec.StatusMsgOn);

            -- Get number of FIFO elements
            NumFifoElements := TransRec.DataWidth ;
            log(ModelID, 
              "Number of FIFO elements = " & to_string(NumFifoElements), 
              INFO,
              TransRec.StatusMsgOn) ;
            
            -- Get Starting address
            LocalAddress := SafeResize(ModelID, TransRec.Address, Address'length);
            log(ModelID, 
              "Start address = " & to_hxstring(LocalAddress), 
              INFO,
              TransRec.StatusMsgOn) ;

            -- Do write burst
            for WriteLoop in 1 to NumFifoElements loop
              -- write operation starts by presenting address, data, and write indicator
              Address <= LocalAddress after tpd_Clk_Address ;
              oData   <= Pop(TransRec.WriteBurstFifo)  after tpd_Clk_oData ;
              Write   <= '1' after tpd_Clk_Write ; 
              
              WaitForClock(Clk) ; 
              
              -- Write Operation Accepted at this clock edge
              Log( ModelID,
                "Write Operation, Address: " & to_hxstring(LocalAddress) &
                "  Data: " & to_hxstring(oData) &
                "  Operation# " & to_string (TransRec.Rdy),
                INFO,
                TransRec.StatusMsgOn);

              -- Increment LocalAddress
              LocalAddress := LocalAddress + 1;
          end loop;
          Address <= not LocalAddress after tpd_Clk_Address ;
          oData   <= not oData    after tpd_Clk_oData ;  
          Write   <= '0' after tpd_Clk_Write ;

        when READ_BURST =>
          log(ModelID, 
            "Initiating read burst operation in DpRamController", 
            INFO,
            TransRec.StatusMsgOn);

          -- Get number of FIFO elements
          NumFifoElements := TransRec.DataWidth ;
          log(ModelID, 
            "Number of FIFO elements = " & to_string(NumFifoElements), 
            INFO,
            TransRec.StatusMsgOn) ;
          
          -- Get Starting address
          LocalAddress := SafeResize(ModelID, TransRec.Address, Address'length);
          log(ModelID, 
            "Start address = " & to_hxstring(LocalAddress), 
            INFO,
            TransRec.StatusMsgOn) ;

          -- Do read burst:
          -- read operation starts by presenting address
          Address <= LocalAddress after tpd_Clk_Address ;
          Write   <= '0' after tpd_Clk_Write ; 
          WaitForClock(Clk) ; 
          
          for ReadLoop in 1 to NumFifoElements loop
            -- read Operation Accepted at this clock edge
            
            -- Increment LocalAddress and present next address
            LocalAddress := LocalAddress + 1;
            Address <= LocalAddress after tpd_Clk_Address ;
            Write   <= '0' after tpd_Clk_Write ; 
            WaitForClock(Clk) ; 

            -- read operations copmleted at this clock edge and data available @iData
            Push(TransRec.ReadBurstFifo, SafeResize(ModelID, iData, TransRec.DataFromModel'length));

            Log( ModelID,
              "Read Operation, Address: " & to_hxstring(LocalAddress - 1) & -- "... - 1" since read is from previous loop
              "  Data: " & to_hxstring(iData) &
              "  Operation# " & to_string (TransRec.Rdy),
              INFO,
              TransRec.StatusMsgOn
            ) ;
          end loop;

        when MULTIPLE_DRIVER_DETECT =>
          Alert(ModelID, "Multiple Drivers on Transaction Record." & 
                         "  Transaction # " & to_string(TransRec.Rdy), FAILURE) ;

        when others =>
          Alert(ModelID, "Unimplemented Transaction: " & to_string(Operation), FAILURE) ;

      end case ;
    end loop ;
  end process TransactionHandler ;


end architecture SimpleBlocking ;
