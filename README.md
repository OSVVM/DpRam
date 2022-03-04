# DpRam Library 
The DpRam is a behavioral model for a DPRAM/BRAM.
It also includes a DpRamManager verification component to
drive the inteface to the DpRam behavioral model. 

## Testbenches are Included 

Testbenches are in the Git repository, so you can 
run a simulation and see a live example 
of how to use the models.

## DpRam Project Structure
   * DpRam
      * src
      * testbench
         
### Building Depencencies
Before building this project, you must build the following libraries in order
   * [OSVVM utility library](https://github.com/osvvm/osvvm) 
   * [OSVVM Common Library](https://github.com/osvvm/OSVVM-Common)   

See the [OSVVM Verification Script Library](https://github.com/osvvm/OSVVM-Scripts) 
for a simple way to build the OSVVM libraries.

### DpRam/src
DpRam behavioral and verification components.
Build these using DpRam/DpRam.pro script.  


### DpRam/testbench
The testbench provides testbenches to verify the DpRam src components.


## Release History
For the release history see, [CHANGELOG.md](CHANGELOG.md)

## Downloading the libraries

The library [OSVVM-Libraries](https://github.com/osvvm/OsvvmLibraries) 
contains all of the OSVVM libraries as submodules.
Download the entire OSVVM model library using git clone with the "--recursive" flag:  
        `$ git clone --recursive https://github.com/osvvm/OsvvmLibraries`

## Participating and Project Organization 

The OSVVM project welcomes your participation with either 
issue reports or pull requests.
For details on [how to participate see](https://opensource.ieee.org/osvvm/OsvvmLibraries/-/blob/master/CONTRIBUTING.md)

You can find the project [Authors here](AUTHORS.md) and
[Contributors here](CONTRIBUTORS.md).

## More Information on OSVVM

**OSVVM Forums and Blog:**     [http://www.osvvm.org/](http://www.osvvm.org/)   
**SynthWorks OSVVM Blog:** [http://www.synthworks.com/blog/osvvm/](http://www.synthworks.com/blog/osvvm/)    
**Gitter:** [https://gitter.im/OSVVM/Lobby](https://gitter.im/OSVVM/Lobby)  
**Documentation:** [Documentation for the OSVVM libraries can be found here](https://github.com/OSVVM/Documentation)

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
