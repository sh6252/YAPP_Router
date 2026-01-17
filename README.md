# YAPP Router – UVM Verification Environment
This repository contains a complete UVM 1.2–based verification environment for the YAPP Router design.
The project includes multiple UVCs, a modular testbench, a reference model, a scoreboard, register-level testing via HBUS, and comprehensive stimulus generation.

## Overview
The YAPP Router routes packets from a single input channel to one of three output channels based on the packet header.
This verification environment implements:
- A complete YAPP Input Port UVC
- Three Output Channel UVCs (one per output port)
- An HBUS register interface UVC
- Clock & Reset UVC
- Router Module UVC with reference model + scoreboard
- Integration of multiple UVCs via configuration and TLM
- Functional checks, error checks, protocol checks, and packet routing validation

### Project Structure
```
├── yapp/                 # YAPP Input Port UVC
│   ├── yapp_packet.sv
│   ├── yapp_tx_driver.sv
│   ├── yapp_tx_monitor.sv
│   ├── yapp_tx_seqs.sv
│   ├── yapp_env.sv
│   └── yapp_if.sv
│
├── channel/              # Output Channel UVCs (0/1/2)
│
├── hbus/                 # HBUS Host UVC (register programming)
│
├── clock_reset/          # Clock & Reset UVC
│
├── router_rtl/           # DUT RTL implementation
│
├── environment/               # Router module UVC (scoreboard + RFM)
│   ├── router_reference.sv
│   ├── router_scoreboard.sv
│   ├── router_module_env.sv
│   └── packet_compare.sv
│
├── tb/                   # Top testbench + tests + run files
│   ├── router_tb.sv
│   ├── router_test_lib.sv
│   ├── tb_top.sv
│   ├── hw_top.sv
│   └── run.f
├── COPTRIGHT.TXT
└── README.md
```

## Included UVCs
🟦 YAPP UVC

Generates constrained-random packets

Drives packets into the DUT

Monitors packets and sends them via TLM

Supports error injection (parity errors, illegal addresses)

🟩 Output Channel UVCs

One UVC per channel (0, 1, 2)

Monitors outgoing packets

Provides simple response sequences

🟧 HBUS UVC

Programs and reads router registers:

router_en

maxpktsize

Status counters (oversized, parity errors, addr counters)

🟫 Clock & Reset UVC

Handles consistent timing for all components.

🟪 Router Module UVC

High-level environment including:

Reference Model (golden behavior)

Scoreboard (packet comparison)

Centralized analysis ports

## What Is Verified
### ✔ YAPP Protocol

Packet size

Header fields

Parity generation/checking

Illegal address handling

FIFO suspend behavior
### ✔ Output Routing
Correct output channel selection

Timing behavior

No packet loss except valid drops
### ✔ Register Functionality
Correct programming via HBUS

Counter updates

Router enable/disable behavior
### ✔ Scoreboard Checks
Matching every input packet to the correct output

Detecting drops due to:

- Parity errors
- Oversized packets
- Invalid destination address

## How to Run
### Basic run:
xrun -f run.f +UVM_TESTNAME=base_test
### Run with verbosity:
xrun -f run.f +UVM_TESTNAME=simple_test +UVM_VERBOSITY=UVM_FULL
### Repeat exact seed:
+SVSEED=<seed>
### Available Tests:
- base_test: Builds the testbench and verifies UVC connectivity.
- short_packet_test: Demonstrates type_override with small packets.
- set_config_test: Uses UVM Configuration Database techniques.
- exhaustive_seq_test: Runs the full sequence library on all UVCs.
- simple_test: Full system-level verification:
            [] Clock + reset
            [] YAPP packets
            [] HBUS register programming
            [] Channel response
- router_module_test

## Top-level test using:
Reference model

Scoreboard

Coverage

Drop detection
## Future Improvements
Add functional coverage

Add assertion-based protocol checking

Create more system-level randomized tests

Auto-generate PDF verification reports

Integrate CI pipeline for regressions
