#!/bin/csh
# ^-- Adding this line tells the system to use C-Shell instead of Bash

setenv RTL_PATH   "../RTL"

echo $RTL_PATH

# Define names for your files and directories
set FILELIST = "filelist.f"
set LOG_DIR  = "sim_logs"
set LOG_FILE = "${LOG_DIR}/sim.log"

# Create a log directory if it doesn't exist
if ( ! -d $LOG_DIR ) then
    mkdir -p $LOG_DIR
endif

# Define your compiler macros/defines here
set DEFINES = "+define+SIMULATION +define+DEBUG_ON +define+SHM_DUMP"

echo "========================================"
echo " Starting Xcelium Simulation (Csh)... "
echo " Log file: ${LOG_FILE}"
echo "========================================"

# Run the 64-bit simulation
xrun -64 \
     -clean \
     -f ${FILELIST} \
     -l ${LOG_FILE} \
     ${DEFINES} \
     -access +rwc \
     -timescale 1ns/1ps

