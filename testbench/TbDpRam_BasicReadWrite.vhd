--
--  File Name:         TbDpRam_BasicReadWrite.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
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

architecture BasicReadWrite of TestCtrl is

  signal Sync1, TestDone : integer_barrier := 1 ;
  signal TbID : AlertLogIDType ; 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbDpRam_BasicReadWrite") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    TbID <= NewID("Testbench") ;

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen(OSVVM_RESULTS_DIR & "TbDpRam_BasicReadWrite.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AlertIfDiff("./results/TbDpRam_BasicReadWrite.txt", "../DpRam/testbench/validated_results/TbDpRam_BasicReadWrite.txt", "") ; 

    EndOfTestReports ; 
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- Manager1Proc
  --   Generate transactions for DpRamManager
  ------------------------------------------------------------
  Manager1Proc : process
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ; 
    variable Manager1Id : AlertLogIDType ;
  begin
    wait until nReset = '1' ;  
    -- First Alignment to clock
    WaitForClock(Manager1Rec, 1) ; 
    Manager1Id := NewID("Manager1", TbID) ; 

    for i in 1 to 10 loop 
      Write(Manager1Rec, X"01_0000" + i, X"1000" + i ) ;
    end loop ;
    
    WaitForClock(Manager1Rec, 4) ; 
    
    for i in 1 to 5 loop 
      Read(Manager1Rec, X"02_0000" + i, Data) ;
      AffirmIfEqual(Manager1Id, Data, X"2000" + i, "Read Data") ;
    end loop ;
    for i in 6 to 10 loop 
      ReadCheck(Manager1Rec, X"02_0000" + i, X"2000" + i) ;
    end loop ;
	
    WaitForClock(Manager1Rec, 6) ; 
    -- EXTRA: 
    -- Burst write and read
    
    -- First, add values to the write fifo
    for i in 1 to 10 loop
      Push(Manager1Rec.WriteBurstFifo, X"3000" + i);
    end loop;
    
    -- then write them to the dpram
    WriteBurst(Manager1Rec, X"03_0001", 10); -- 03_0001 since i starts from 1 in for loop

    WaitForClock(Manager1Rec, 8) ; -- synchronize with other dpramcontroller

    -- Then, we can check if the value were written correctly
	
    ReadBurst(Manager1Rec, X"04_0001", 10);
    
    -- and finally check the received values
    for i in 1 to 10 loop
    	CheckExpected(Manager1Rec.ReadBurstFifo, X"4000" + i);
    end loop;
	
    WaitForBarrier(TestDone) ;
    wait ;
  end process Manager1Proc ;
  
  ------------------------------------------------------------
  -- Manager2Proc
  --   Generate transactions for DpRamManager
  ------------------------------------------------------------
  Manager2Proc : process
    variable Data : std_logic_vector(DATA_WIDTH-1 downto 0) ; 
    variable Manager2Id : AlertLogIDType ;
  begin
    wait until nReset = '1' ;  
    -- First Alignment to clock
    WaitForClock(Manager2Rec, 1) ; 
    Manager2Id := NewID("Manager2", TbID) ; 

    for i in 1 to 10 loop 
      Write(Manager2Rec, X"02_0000" + i, X"2000" + i ) ;
    end loop ;
    
    WaitForClock(Manager2Rec, 4) ; 
    
    for i in 1 to 5 loop 
      Read(Manager2Rec, X"01_0000" + i, Data) ;
      AffirmIfEqual(Manager2Id, Data, X"1000" + i, "Read Data") ; 
    end loop ;
    for i in 6 to 10 loop 
      ReadCheck(Manager2Rec, X"01_0000" + i, X"1000" + i) ;
    end loop ;

    WaitForClock(Manager2Rec, 6) ; 

    for i in 1 to 10 loop
      Push(Manager2Rec.WriteBurstFifo, X"4000" + i);
    end loop;
    
    WriteBurst(Manager2Rec, X"04_0001", 10); 

    WaitForClock(Manager2Rec, 8) ; 

    ReadBurst(Manager2Rec, X"03_0001", 10);
    
    -- and finally check the received values
    for i in 1 to 10 loop
    	CheckExpected(Manager2Rec.ReadBurstFifo, X"3000" + i);
    end loop;

    WaitForBarrier(TestDone) ;

    wait ;
  end process Manager2Proc ;


end BasicReadWrite ;

Configuration TbDpRam_BasicReadWrite of TbDpRam is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(BasicReadWrite) ; 
    end for ; 
  end for ; 
end TbDpRam_BasicReadWrite ; 