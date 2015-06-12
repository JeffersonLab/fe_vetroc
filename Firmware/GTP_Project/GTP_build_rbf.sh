#!/bin/bash
quartus_cpf -c GTP.pof GTP.hexout
nios2-elf-objcopy -I ihex -O binary GTP.hexout GTP.rbf