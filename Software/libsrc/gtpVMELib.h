/*----------------------------------------------------------------------------*
 *  Copyright (c) 2012        Southeastern Universities Research Association, *
 *                            Thomas Jefferson National Accelerator Facility  *
 *                                                                            *
 *    This software was developed under a United States Government license    *
 *    described in the NOTICE file included as part of this distribution.     *
 *                                                                            *
 *    Authors: Bryan Moffit                                                   *
 *             moffit@jlab.org                   Jefferson Lab, MS-12B3       *
 *             Phone: (757) 269-5660             12000 Jefferson Ave.         *
 *             Fax:   (757) 269-5800             Newport News, VA 23606       *
 *                                                                            *
 *----------------------------------------------------------------------------*
 *
 * Description:
 *     Status library for the JLAB Global Trigger Processor
 *     (GTP) module using an i2c interface from the JLAB Trigger
 *     Interface (TI) module.
 *
 *----------------------------------------------------------------------------*/
#ifndef GTPVMELIB_H
#define GTPVMELIB_H

/* JLab GTP Register definitions (defined within TI register space) */
struct GTPStruct
{
  /* 0x0000 */          unsigned int blankGTP0[(0x3C00-0x0000)/4];
  /* 0x3C00 */ volatile unsigned int BoardId[2];         /* Device 1,  Address 0x0-0x1 */
  /* 0x3C08 */ volatile unsigned int FirmwareRev[2];                /* Address 0x2-0x3 */
  /* 0x3C10 */ volatile unsigned int CpuStatus[2];                  /* Address 0x4-0x5 */
  /* 0x3C18 */ volatile unsigned int Hostname[8];                   /* Address 0x6-0xD */
  /* 0x3C38 */          unsigned int blankGTP2[(0x10000-0x3C38)/4]; /* Address 0xE */
};

/* Board ID = GTP */
#ifndef GTPLIB_H
#define GTP_BOARDID    0x47545020

#define GTP_FIRMWAREREV_TYPE_MASK  0xFFFF0000
#define GTP_FIRMWAREREV_MAJOR_MASK 0x0000FF00
#define GTP_FIRMWAREREV_MINOR_MASK 0x000000FF

#define GTP_TYPE_HALL_D   1
#define GTP_TYPE_HPS      2
#define GTP_TYPE_VETROC   3

/* Define CpuStatus bits */
#define GTP_CPUSTATUS_BOOTED  0x1

#define GTP_INIT_IGNORE_FIRMWARE_VERSION (1<<0)
#define GTP_STATUS_SHOWREGS (1<<0)
#endif

/* GTP Function Prototypes */
int  gtpVMEInit(int rFlag);
int  gtpVMEStatus(int pFlag);
int  gtpVMEGetHostname(char **rval, int pFlag);
int  gtpVMEGetCpuStatus();
unsigned int getVMEGetFirmwareVersion();
#endif /* GTPVMELIB_H */
