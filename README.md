# AXI UVM Verification Testbench

![AXI Testbench Architecture](https://github.com/Karan-nevage/AXI-UVC/blob/main/Images/AXI_TB_ARCHITECTURE.png)
*Note: Replace the above URL with the actual image link of your architecture diagram.*

## Project Overview
This repository contains a UVM (Universal Verification Methodology)-based testbench for verifying an AXI (Advanced eXtensible Interface) protocol design. The testbench is designed to validate the functionality of an AXI master and slave interface, ensuring compliance with the AMBA AXI4 specification. It includes modular components for drivers, monitors, responders, sequencers, coverage, and a scoreboard, making it scalable for various test scenarios. The project utilizes Synopsys VCS for simulation and Synopsys Verdi for tracing, debugging, and waveform analysis.

## Features
- **Modular UVM Architecture**: Separate master and slave agents with drivers, monitors, and responders.
- **Transaction Generation**: Supports multiple test sequences (e.g., write/read, burst length/size, WRAP transactions).
- **Coverage Collection**: Functional coverage for address, write/read control, and burst parameters.
- **Scoreboard Verification**: Optional byte-level or transaction-level comparison based on configuration.
- **Flexible Configuration**: Conditional compilation for overlapping/non-overlapping transactions and comparison modes.
- **Synopsys Tool Integration**: Optimized for Synopsys VCS simulation and Verdi for debugging and coverage analysis.

## Specifications and Resources
- **AXI4 Specification**: Download the AMBA AXI and ACE Protocol Specification from [here](http://www.gstitt.ece.ufl.edu/courses/fall15/eel4720_5721/labs/refs/AXI4_specification.pdf).
- **UVM Package**: Source code for UVM 1.2 can be downloaded from [here](https://accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz).

## Signal Descriptions
The testbench utilizes various AXI signals to facilitate communication between the master and slave. Below is a tabular overview of key signals and their purposes:


| Signal          | Width       | Description                                      |
|-----------------|-------------|--------------------------------------------------|
| `aclk`          | 1 bit       | Clock signal for synchronizing AXI transactions  |
| `aresetn`       | 1 bit       | Active-low reset signal                          |
| `awaddr`        | `ADDR_WIDTH`| Write address for the transaction                |
| `awlen`         | 4 bits      | Burst length (number of data transfers minus 1)  |
| `awsize`        | 3 bits      | Size of each data transfer in bytes              |
| `awburst`       | 2 bits      | Burst type (FIXED, INCR, WRAP)                   |
| `awid`          | 4 bits      | Write transaction ID                             |
| `awvalid`       | 1 bit       | Write address valid signal                       |
| `awready`       | 1 bit       | Write address ready signal from slave            |
| `wdata`         | 32 bits     | Write data                                       |
| `wstrb`         | 4 bits      | Write strobes for byte lane control              |
| `wvalid`        | 1 bit       | Write data valid signal                          |
| `wready`        | 1 bit       | Write data ready signal from slave               |
| `wlast`         | 1 bit       | Indicates the last transfer in a write burst     |
| `bvalid`        | 1 bit       | Write response valid signal                      |
| `bready`        | 1 bit       | Write response ready signal                      |
| `bid`           | 4 bits      | Write response ID                                |
| `bresp`         | 2 bits      | Write response status (OKAY, ERROR, etc.)        |
| `araddr`        | `ADDR_WIDTH`| Read address for the transaction                 |
| `arlen`         | 4 bits      | Burst length for read transactions               |
| `arsize`        | 3 bits      | Size of each read data transfer                  |
| `arburst`       | 2 bits      | Burst type for read transactions                 |
| `arid`          | 4 bits      | Read transaction ID                              |
| `arvalid`       | 1 bit       | Read address valid signal                        |
| `arready`       | 1 bit       | Read address ready signal from slave             |
| `rdata`         | 32 bits     | Read data                                        |
| `rvalid`        | 1 bit       | Read data valid signal                           |
| `rready`        | 1 bit       | Read data ready signal from master               |
| `rlast`         | 1 bit       | Indicates the last transfer in a read burst      |
| `rid`           | 4 bits      | Read data ID                                     |
| `rresp`         | 2 bits      | Read response status (OKAY, ERROR, etc.)         |

## Directory Structure
- `top/`: Top level files for the projecct such as top module, envoirment.
- `common/`: Shared configuration, interface, transaction, monitor, and coverage files.
- `master/`: Master agent components (driver, sequencer, coverage).
- `slave/`: Slave agent components (responder).
- `sim/`: Simulation scripts and file lists (e.g., `run.sh` for VCS).
- `src/`: UVM package library files.



### Steps to Run Simulation

1. **Open Terminal**
   - Launch a terminal on your system.

2. **Change Directory to Sim Folder**
   - Navigate to the `sim` folder using the `cd` command:
     ```bash
     cd sim
     ```

3. **Switch to tcsh Shell**
   - Use the `tcsh` command to switch to the tcsh shell:
     ```bash
     tcsh
     ```

4. **Source Synopsys Tool Files**
   - Source the Synopsys environment setup file (e.g., `synopsys.env` or similar):
     ```bash
     source /path/to/synopsys.env
     ```
   - Replace `/path/to/synopsys.env` with the actual path to your Synopsys setup file.

5. **Check and Update run.sh Permissions**
   - Verify if `run.sh` is executable using:
     ```bash
     ls -ltr
     ```
   - If it’s not executable (e.g., no `x` in permissions like `-rw-r--r--`), update permissions with:
     ```bash
     chmod +x run.sh
     ```
   - Recheck with `ls -ltr` to confirm the `x` permission (e.g., `-rwxr-xr-x`).

6. **Run the Simulation Script**
   - Execute the `run.sh` script:
     ```bash
     ./run.sh
     ```
   - This will compile and simulate the testbench using VCS, generating a log file and simulation database.

7. **View Simulation Log**
   - Check the log file generated in the `sim` folder (e.g., `simv.log`) or view the output directly in the terminal.
   - The log provides details on compilation, simulation progress, and any errors.

### Post-Simulation Analysis

- **Open Waveform with Verdi**
  - Launch Verdi to view the waveform using the FSDB file:
    ```bash
    verdi -ssf axi_wave.fsdb &
    ```
  - This opens the waveform database for debugging and signal tracing.

- **View Coverage with Verdi**
  - Analyze coverage data with:
    ```bash
    verdi -cov -covdir simv.vdb &
    ```
  - This opens the coverage database (`simv.vdb`) for functional coverage analysis.

## Troubleshooting
- **Permission Denied**: Ensure `run.sh` has executable permissions.
- **Command Not Found**: Verify Synopsys tools are sourced correctly.
- **Waveform/Coverage Issues**: Check that `axi_wave.fsdb` and `simv.vdb` are generated by the simulation.



# AXI UVM Verification Testbench - Details and Contribution

## Author
- **Name**: Karankumar Nevage
- **Email**: karanpr9423@gmail.com
- **LinkedIn**: [https://www.linkedin.com/in/karankumar-nevage/](https://www.linkedin.com/in/karankumar-nevage/)

## Contributing
Feel free to fork this repository, submit issues, or create pull requests for enhancements. Contributions to add new test sequences or improve coverage are welcome.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Project Status
- **Last Updated**: September 06, 2025, 12:38 AM IST
- **Current Version**: 1.0
