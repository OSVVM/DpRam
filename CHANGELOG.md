# DpRam Behavioral and Verification Component Change Log

| Revision  |  Release Summary | 
------------|----------- 
| 2023.05   | Bug Fix to logging of address during read operation
| 2022.03   | Initial release

## 2022.05 March 2022
- DpRamController_Blocking.vhd
    - Bug Fix: Added LocalAddress to hold address so read operation logs correct address


## 2022.03 March 2022
- New repository with 
    - DpRam_Singleton.vhd - Singleton version of DPRAM
    - DpRam_PT.vhd - Protected Type version of DPRAM
    - DpRamController_Blocking.vhd - DPRAM Controller Verification Component
    - DpRamContext.vhd - Package references for DpRam
    - DpRamComponentPkg.vhd - component declaration for DPRAM and DpRamController

 
## Copyright and License
Copyright (C) 2022 by [SynthWorks Design Inc.](http://www.synthworks.com/)   
Copyright (C) 2022 by [OSVVM contributors](CONTRIBUTOR.md)   

This file is part of OSVVM.

    Licensed under Apache License, Version 2.0 (the "License")
    You may not use this file except in compliance with the License.
    You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
