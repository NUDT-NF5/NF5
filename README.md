# NF5
   This is a simple RISC-V core contributed by five designers from National University of Defense Technology.
## Table of contents
+ [Quick instructions](#quick) 
+ [What's in the NF5 repository](#what)
+ [How should I use the NF5](#how)
  + [Using NC-verilog simulation](#NCverilog)
  + [Synthesizing the core](#DesignCompiler)
  + [Mapping the NF5 down to FPGA](#fpga)
+ [Debug with GDB](#debug)
+ [Contributors](#contributors)
## <a name="quick"></a>Quick Instructions

### Checkout the code

    $git clone https://github.com/Suedongchu/NF5
    $cd NF5/SystemNCexampleProject
    $git submodule updata --init

### Open NC-verilog simulation window

    $make sim_gui

## <a name="what"></a>What's in the NF5 repository

There are five main directories in NF5：
- **doc**
 The ***doc*** directory includes design documents of top module and each submodules

- **src**
The ***src*** directory includes source codes of each modules
  
    Unit name|Description
    ---------|-----------
    **IF**|Fetch unit
    **ID**|Decode unit
    **EX**|Execute unit
    **MEM**|Memory access unit
    **WB**|Write back unit
    **Stage**|Stage reg between every two units
    **Cache**|I-Cache and D-Cache units
    **Control**|Control unit, inclued CSR unit
    **Debug**|Degbug unit

- **tb**
The ***tb*** directory includes testbench to be added to NC-verilog tools, which can put different instructions in NF5 core.

- **result**
The ***result*** directory includes the result of current test, saved as *.log, which show whether the test has passed or failed. 

- **report**
The ***report*** directory includes the 

- **isa_test**
The ***isa_test*** directory includes the functional test and compliance test called by `make` command.

## <a name="how"></a>How should I use the NF5

If you want to run a simulation, you must open a terminal in current directory, then use **`make sim`** or **`make sim_gui`** to run different simulation or use **`make clean`** to clean all result. 

### <a name="NCverilog"></a>Using NC-verilog simulation

- #### ***Run testcase in isa_test*** 
  
  Using command listed as follows to simulate NF5 with NC-Verilog: 

  1. ***`make sim`***
  
      Then you will find some tips in terminal:
      ``1  Test_name : functional-test   Test_Addr_start : 0x0000 ``
      ``2  Test_name : functional-test   Test_Addr_start : 0x8000 ``
      ``PLease input the [Number] to chose the Test Name and Address : ``

      You should input number 1 or 2 in terminal. If you enter 1, you will run founctional test and the initial test address will be 0x0000_0000. If you enter 2, the test will still be functional, but the address will be 0x8000_0000.

  2. ***Enter Test Name and Address (1 or 2)***
     
      Then you will find: 

       ``Please input the Number of [TVM model and Target Environment Name] to select :``

      You should enter a number listed in terminal before each TVM model name.
  3. ***Enter TVM model Number***
    
      Then you will find:

      ``Please select the Way to Test:``
      ``1  Test way : all ``
      ``2  Test way : single `` 
      
      You should decide to run all test in the chosen TVM module or run single in it.

      Test way|Description
      --------|----------
      **All**|Run all test in current TVM module, which can test that whether the core can run the standard test provided by  RISC-V Foundation
      **Single** | Run single test in current TVM module, which can be used to debug the core. After running this, you can use  command `make sim_gui` in the new terminal to see the waveform of core running current test, which may have some bugs.

  4. ***Enter Test Way (All)***
    
      You will find the whole report in:
      `NF5/SystemNCexampleProject/isa_test/report/`

  5. ***Get Report***

     After  ehter 1 to run all test in the testcase, the `All_Testcase_Report.txt` will be opened automatically, and you will find the whole report of all testcases. The report will tell you which test has ***PASSED*** and which has ***FAILED***. 
  
- #### ***Run testcase in isa_test to debug*** 
  If you find failed testcase in final report, you should go into this link to debug as follow steps.

  1. ***make sim***

      The terminal will show Test Name and Address, choose this as before.

  2. ***Enter Test Name and Address***

      The terminal will show TVM model Number, choose this as before.

  3. ***Enter TVM model Number***

      The terminal will show Test Way, please choose `single` (enter `2` in terminal).

  4. ***Enter Test Way (Single)***

      The terminal will show Test case Name, if you find some testcases failed in the report, you should choose the name you want to debug, and go into next step.

  5. ***Enter Test case Number***

      The choosen test will run after this.

  6. ***make sim_gui***

      The new NC-Verilog window will be opended, and you can find waveforms of every signal in the simvision window. If you want to know how to use NC-Verilog, you can see https://www.cadence.com/content/cadence-www/global/en_US/home.html. 

- #### ***Edit yourself testbench with assert*** ###
  If you want to debug NF5 with single testcase, you may need add some asserts in testbench. You will find this in next steps:

    1. ***Find self testbench***

        The testbench provided for self test can be found in `isa_test/TbAll_self_assert.txt`

    2. ***Add assert***

        You can add yourself assert in `TbAll_self_assert.txt`. You should not modify any code existed in this testbench.

    3.  ***Run single test***

        After adding assert, you can run single test according to the steps listed as before.
        
  ### <a name="DesignCompiler"></a>Synthesizing the core
  - (to be done)
  ### <a name="fpga"></a>Mapping the NF5 down to FPGA
  - (to be done)
  ### <a name="debug"></a>Debug with GDB
  - (to be done)
  ### <a name="contributors"></a>Contributors
  - (to be done)
