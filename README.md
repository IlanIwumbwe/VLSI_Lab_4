##### Imperial College London, Department of Electrical & Electronic Engineering


#### ELEC70142 Digital VLSI Design

### Lab 4 - Self-test System

##### *Peter Cheung, v1.0 - 30 October 2025*


This laboratory session is a continuation from Lab 3.  In this lab, using knowledge from Labs 1 to 3, you will develop a built-in self-test circuit to detect possible error in the circuit.  You will also inject errors into the circuit to check that the automatic fault detection circuit works.

* Create a new directory for this lab, say, LAB_4 and move to that directory.
* Copy the folder containing the memory block designed in Lab 3 to this folder.
* Launch TSMC's pdk with:
``` bash
pdk TSMC65LP
```

<p align="center"> <img src="diagrams/cct_2.jpg" width="1200" height="200"> </p><BR>

The system above is an extension of the circuit in Lab 3 Task 2 with a built-in self-test circuit. Instead of inspect the output from the simulator, this circuit  compresses the SRAM output sequence to produce an expected 16-bit signature. Deviation from the expectation indicates an error in the circuit.

In Lab 1, you designed a serial signature analyzer that compress sequence of '1's and '0's to a 16-bit signature.  This circuit can be modified into a parallel signature analyzer that produces a unique signature for a 16-bit, instead of 1-bit, input using the circuit shown below.

<p align="center"> <img src="diagrams/signature_16.jpg" width="600" height="250"> </p><BR>

This parallel signature analyzer circuit "merges" the 16-bit output values of the DUT to the LFSR Q outputs, and produces a signature for the entire contents of the SRAM.  

SRAM data output is 32-bit.  One possibility is to XOR neighbouring two bits and feed outputs of the 16 XOR gates to the parallel signature analyzer.  An alternative is to create a 32-bit signature analyzer.

You will also need to modify the FSM to ensure that a test cycle is performed whenever the test input command goes from low to high, and produces the 16-bit signature. This can then be compared with the expected value and produces a GO/NO_GO output.

Check that your self-test circuit works by connecting one of the data output of the SRAM to ground, thus injecting a stuck-at-0 fault into the circuit.

