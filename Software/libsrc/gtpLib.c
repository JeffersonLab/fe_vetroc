/*----------------------------------------------------------------------------*
 *  Copyright (c) 2014        Southeastern Universities Research Association, *
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
 *             Benjamin Raydp                                                 *
 *             braydo@jlab.org                   Jefferson Lab, MS-12B3       *
 *             Phone: (757) 269-5660             12000 Jefferson Ave.         *
 *             Fax:   (757) 269-5800             Newport News, VA 23606       *
 *                                                                            *
 *----------------------------------------------------------------------------*
 *
 * Description:
 *     Control and Status library for the JLAB Global Trigger Processor
 *     (GTP) module using an ethernet socket interface - VETROC Hall A version
 *
 *----------------------------------------------------------------------------*/

#ifdef VXWORKS
#include <vxWorks.h>
#include <sysLib.h>
#include <logLib.h>
#include <taskLib.h>
#include <vxLib.h>
#include "vxCompat.h"
#else
#include "jvme.h"
#endif
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "gtpLib.h"

/* Mutex to guard GTP read/writes */
extern pthread_mutex_t   gtpMutex;
#ifndef GTPLOCK
#define GTPLOCK     if(pthread_mutex_lock(&gtpMutex)<0) perror("pthread_mutex_lock");
#endif
#ifndef GTPUNLOCK
#define GTPUNLOCK   if(pthread_mutex_unlock(&gtpMutex)<0) perror("pthread_mutex_unlock");
#endif

/* Global Variables */
volatile Gtp_regs *GTPp;            /* Pointer to GTP Memory Map */
unsigned long gtpBase;               /* Address of GTP Memory Map base */

extern int cmcRead32(unsigned int addr, unsigned int *val);
extern int cmcWrite32(unsigned int addr, unsigned int val);

static unsigned int
gtpReadReg(volatile unsigned int *addr)
{
  unsigned int rval=0;
  cmcRead32((unsigned int)(addr)-gtpBase,&rval);
  return rval;
}

static void 
gtpWriteReg(volatile unsigned int *addr, unsigned int val)
{
  cmcWrite32((unsigned int)(addr)-gtpBase,val);
}


/*
  gtpInit
  - Initialize the Global Trigger Processor module
*/
int
gtpInit(int rFlag, char* gHostname)
{
  unsigned int BoardId=0, version=0;
  int stat=0, iwait=0;
  char ghn[60];

  GTPp = (Gtp_regs *)malloc(sizeof(Gtp_regs));

  gtpBase = (unsigned int)GTPp;

  if(gHostname==NULL)
    {
      /* Connect to GTP via I2C (TI) */
      if(gtpVMEInit(0) == ERROR)
	return ERROR;
  
      if(gtpVMEGetHostname((char**)ghn,1)==ERROR)
	return ERROR;

      stat=ERROR;
      for(iwait=0; iwait<10; iwait++)
	{
	  if(gtpVMEGetCpuStatus()==1)
	    {
	      stat=OK;
	      break;
	    }
	  sleep(10);
	}

      if(stat==ERROR)
	{
	  printf("%s: GTP CPU not up after 10 seconds\n",
		 __FUNCTION__);
	  return ERROR;
	}
    }
  else
    {
      strncpy(ghn,gHostname,60);
    }

  if(gtpSocketInit(ghn,0)==ERROR)
    return ERROR;
  
  /* Check the module ID, to confirm we've got a GTP in there */
  GTPLOCK;
  BoardId = gtpReadReg(&GTPp->Cfg.BoardId);
    
  version = gtpReadReg(&GTPp->Cfg.FirmwareRev);
  GTPUNLOCK;

  if(BoardId != (GTP_BOARDID))
    {
      printf("%s: ERROR: Invalid GTP Board ID (0x%08x)\n",
	     __FUNCTION__,BoardId);
      gtpSocketClose();
      return ERROR;
    }

  if(version == 0xffffffff)
    {
      printf("%s: ERROR: Unable to read GTP version (returned 0x%x)\n",
	     __FUNCTION__,version);
      gtpSocketClose();
      return ERROR;
    }

  printf("%s: GTP (Type %d v%d.%d) initialized at Local Base address 0x%lx\n",
	 __FUNCTION__,
	 (version & GTP_FIRMWAREREV_TYPE_MASK)>>16,
	 (version & GTP_FIRMWAREREV_MAJOR_MASK)>>8,
	 (version & GTP_FIRMWAREREV_MINOR_MASK),
	 gtpBase);

  return OK;
}

int
gtpStatus(int pflag)
{
  Gtp_regs st;
  int i=0, j=0;

  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  st.Cfg.BoardId     = gtpReadReg(&GTPp->Cfg.BoardId);
  st.Cfg.FirmwareRev = gtpReadReg(&GTPp->Cfg.FirmwareRev);
  st.Clk.Ctrl        = gtpReadReg(&GTPp->Clk.Ctrl);
  st.Clk.Status      = gtpReadReg(&GTPp->Clk.Status);
  for(i=0; i<GTP_SRC_SEL_NUM; i++)
    st.Sd.SrcSel[i]  = gtpReadReg(&GTPp->Sd.SrcSel[i]);
  for(i=0; i<15; i++)
    {
      st.Ser[i].Ctrl     = gtpReadReg(&GTPp->Ser[i].Ctrl);
      st.Ser[i].Status   = gtpReadReg(&GTPp->Ser[i].Status);
      st.Ser[i].Status2  = gtpReadReg(&GTPp->Ser[i].Status2);
      st.Ser[i].ErrTile0 = gtpReadReg(&GTPp->Ser[i].ErrTile0);
    }
  st.Trg.Ctrl = gtpReadReg(&GTPp->Trg.Ctrl);
  st.Trg.Status = gtpReadReg(&GTPp->Trg.Status);
  st.Trg.Latency = gtpReadReg(&GTPp->Trg.Latency);
  st.Trg.ClusterThreshold = gtpReadReg(&GTPp->Trg.ClusterThreshold);
  GTPUNLOCK;
  printf("\nSTATUS for GTP at %s:%d\n",
	 gtpSocketGetHostname(),gtpSocketGetPort());
  printf("--------------------------------------------------------------------------------\n");
  printf(" Board Type = %d   Firmware Rev = v%d.%d\n",
	 (st.Cfg.FirmwareRev&GTP_FIRMWAREREV_TYPE_MASK)>>16,
	 (st.Cfg.FirmwareRev&GTP_FIRMWAREREV_MAJOR_MASK)>>8,
	 (st.Cfg.FirmwareRev&GTP_FIRMWAREREV_MINOR_MASK));

  printf("\n");
  printf("                               - Signal Sources - \n\n");
  printf("  Clock: %d %s - %s  ",
	 (st.Clk.Ctrl & GTP_CLK_CTRL_SRC_MASK),
	 gtp_clksrc_name[(st.Clk.Ctrl & GTP_CLK_CTRL_SRC_MASK)],
	 (st.Clk.Status & GTP_CLK_STATUS_GCLK_LOCK)?"LOCKED":"NOT LOCKED");
  
  printf("Trig1: %s   ",
	 gtp_signal_name[st.Sd.SrcSel[GTP_SD_SRC_TRIG]]);

  printf("SyncReset: %s\n",
	 gtp_signal_name[st.Sd.SrcSel[GTP_SD_SRC_SYNC]]);

      printf("\n");
      printf("                         - Payload Input Configuration - \n\n");
      printf("     SubSystem        Channel   Data             Lane Bit Errors    HardErr\n");
      printf("Slot   Name   Enabled   Up    Received  Latency      0      1        0   1\n");
      printf("--------------------------------------------------------------------------------\n");
      for(i=15; i>=0; i--)
	{
	  if(((1<<i) & SS_PORT_MASK)==0) continue;
	  printf(" %2d",vxsPayloadPort2vmeSlot(i+1));
	  printf("    %3s",(st.Ser[i].Ctrl & GTP_SER_CTRL_POWERDN)?"NO":"YES");
	  printf("    %-3s",(st.Ser[i].Status & GTP_SER_STATUS_CHANNELUP)?"YES":" NO");
	  if((st.Ser[i].Status & GTP_SER_STATUS_CHANNELUP)==0) 
	    {
	      printf("\n");
	      continue;
	    }
	  printf("       %3s",(st.Ser[i].Status & GTP_SER_STATUS_RXSRCRDYN)?" NO":"YES");
	  printf("     %5d",(st.Ser[i].Status2 & GTP_SER_STATUS2_LATENCY_MASK));
	  printf("     %5d",(st.Ser[i].ErrTile0 & GTP_SER_ERRTILE_LANE0_BITERRORS));
	  printf("  %5d",(st.Ser[i].ErrTile0 & GTP_SER_ERRTILE_LANE1_BITERRORS)>>16);

	  printf("     %3s",(st.Ser[i].Status & GTP_SER_STATUS_HARDERR0)?"YES":" NO");
	  printf(" %3s",(st.Ser[i].Status & GTP_SER_STATUS_HARDERR0)?"YES":" NO");
	  printf("\n");
	}

  printf("Trigger:\n");
  printf("   Payload Mask: 0x%04X\n", st.Trg.Ctrl);
  printf("   Latency Status: %d\n", st.Trg.Status);
  printf("   Latency: %d\n", st.Trg.Latency);
  printf("   Cluster Threshold: %d\n", st.Trg.ClusterThreshold);

  printf("\n");
  printf("--------------------------------------------------------------------------------\n");
  return OK;
}

int
gtpCheckAddresses()
{
  unsigned int offset=0, expected=0, base=0;
  int i=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  base = (unsigned int) &GTPp->Cfg;

  offset = ((unsigned int) &GTPp->Clk) - base;
  expected = 0x100;
  if(offset != expected)
    printf("%s: ERROR GTPp->Clk not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->Sd) - base;
  expected = 0x200;
  if(offset != expected)
    printf("%s: ERROR GTPp->Sd not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->La) - base;
  expected = 0x400;
  if(offset != expected)
    printf("%s: ERROR GTPp->La not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  for(i=0; i<16; i++)
    {
      offset = ((unsigned int) &GTPp->Ser[i]) - base;
      expected = 0x1000 + i*0x100;
      if(offset != expected)
	printf("%s: ERROR GTPp->Ser[%d] not at offset = 0x%x (@ 0x%x)\n",
	       __FUNCTION__,i,expected,offset);
    }

  offset = ((unsigned int) &GTPp->Trg) - base;
  expected = 0x2000;
  if(offset != expected)
    printf("%s: ERROR GTPp->Trg not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->BCal) - base;
  expected = 0x3000;
  if(offset != expected)
    printf("%s: ERROR GTPp->BCal not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->FCal) - base;
  expected = 0x3100;
  if(offset != expected)
    printf("%s: ERROR GTPp->FCal not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->TagM) - base;
  expected = 0x3200;
  if(offset != expected)
    printf("%s: ERROR GTPp->TagM not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->TagH) - base;
  expected = 0x3300;
  if(offset != expected)
    printf("%s: ERROR GTPp->TagH not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->PS) - base;
  expected = 0x3400;
  if(offset != expected)
    printf("%s: ERROR GTPp->PS not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->ST) - base;
  expected = 0x3500;
  if(offset != expected)
    printf("%s: ERROR GTPp->ST not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  offset = ((unsigned int) &GTPp->TOF) - base;
  expected = 0x3600;
  if(offset != expected)
    printf("%s: ERROR GTPp->TOF not at offset = 0x%x (@ 0x%x)\n",
	   __FUNCTION__,expected,offset);

  for(i=0; i<16; i++)
    {
      offset = ((unsigned int) &GTPp->Trigbits[i]) - base;
      expected = 0x4000 + i*0x100;
      if(offset != expected)
	printf("%s: ERROR GTPp->Trigbits[%d] not at offset = 0x%x (@ 0x%x)\n",
	       __FUNCTION__,i,expected,offset);
    }

  return OK;
}

int
gtpSetClockSource(int clksrc)
{
  unsigned int reg=0;
  int rval=OK;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if((clksrc<0)||(clksrc>2))
    {
      printf("%s: ERROR: Invalid Clock Source (%d).\n",
	     __FUNCTION__,clksrc);
      return ERROR;
    }

  GTPLOCK;
  /* Set Clock Source with RESET asserted */
  gtpWriteReg(&GTPp->Clk.Ctrl, clksrc | GTP_CLK_CTRL_RESET);
  /* Pull down reset */
  gtpWriteReg(&GTPp->Clk.Ctrl, clksrc);
  taskDelay(1);

  /* Check for PLL Lock */
  reg = gtpReadReg(&GTPp->Clk.Status);
  if((reg & GTP_CLK_STATUS_GCLK_LOCK)==0)
    {
      printf("%s: ERROR: PLL Not Locked. Status = 0x%x\n",
	     __FUNCTION__,reg);
      rval=ERROR;
    }
  GTPUNLOCK;

  return rval;
}

int
gtpGetClockSource()
{
  int rval=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = gtpReadReg(&GTPp->Clk.Ctrl) & GTP_CLK_CTRL_SRC_MASK;
  GTPUNLOCK;

  return rval;
}

int
gtpGetClockPLLStatus()
{
  int rval=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = gtpReadReg(&GTPp->Clk.Status) & GTP_CLK_STATUS_LOCK_MASK;
  GTPUNLOCK;

  return rval;
}

int
gtpSetSyncSource(int srsrc)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if((srsrc<0) | (srsrc>GTP_SRC_SEL_NUM))
    {
      printf("%s: ERROR: Invalid Sync Reset Source (%d)\n",
	     __FUNCTION__,srsrc);
      return ERROR;
    }
  
  GTPLOCK;
  gtpWriteReg(&GTPp->Sd.SrcSel[GTP_SD_SRC_SYNC], srsrc);
  GTPUNLOCK;
  
  return OK;
}

int
gtpGetSyncSource()
{
  int rval=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = gtpReadReg(&GTPp->Sd.SrcSel[GTP_SD_SRC_SYNC]);
  GTPUNLOCK;

  return rval;
}

int
gtpSetTrig1Source(int trig1src)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if((trig1src<0) | (trig1src>GTP_SRC_SEL_NUM))
    {
      printf("%s: ERROR: Invalid Trig1 Source (%d)\n",
	     __FUNCTION__,trig1src);
      return ERROR;
    }
  
  GTPLOCK;
  gtpWriteReg(&GTPp->Sd.SrcSel[GTP_SD_SRC_TRIG], trig1src);
  GTPUNLOCK;
  
  return OK;
}

int
gtpGetTrig1Source()
{
  int rval=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = gtpReadReg(&GTPp->Sd.SrcSel[GTP_SD_SRC_TRIG]);
  GTPUNLOCK;

  return rval;
}

int
gtpEnablePayloadPort(int port)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if((port<0) || (port>15))
    {
      printf("%s: ERROR: Invalid payload port (%d)\n",
	     __FUNCTION__,port);
      return ERROR;
    }

  GTPLOCK;
  gtpWriteReg(&GTPp->Ser[port].Ctrl,GTP_SER_CTRL_POWERDN);
  gtpWriteReg(&GTPp->Ser[port].Ctrl,0);
  GTPUNLOCK;


  return OK;
}

int
gtpDisablePayloadPort(int port)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if((port<0) || (port>15))
    {
      printf("%s: ERROR: Invalid payload port (%d)\n",
	     __FUNCTION__,port);
      return ERROR;
    }

  GTPLOCK;
  gtpWriteReg(&GTPp->Ser[port].Ctrl,GTP_SER_CTRL_POWERDN);
  GTPUNLOCK;

  return OK;
}

int
gtpEnableVmeSlot(int vmeslot)
{
  return gtpEnablePayloadPort(vmeSlot2vxsPayloadPort(vmeslot));
}

int
gtpDisableVmeSlot(int vmeslot)
{
  return gtpDisablePayloadPort(vmeSlot2vxsPayloadPort(vmeslot));
}

int
gtpEnablePayloadPortMask(int portmask)
{
  int iport=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  for(iport=0; iport<16; iport++)
    {
      gtpWriteReg(&GTPp->Ser[iport].Ctrl,GTP_SER_CTRL_POWERDN);
      if((1<<iport) & portmask)
	{
	  gtpWriteReg(&GTPp->Ser[iport].Ctrl,0);
	}
    }
  GTPUNLOCK;

  return OK;
}

int
gtpEnableVmeSlotMask(unsigned int vmeslotmask)
{
  return gtpEnablePayloadPortMask(vmeSlotMask2vxsPayloadPortMask(vmeslotmask));
}

int
gtpGetChannelUpMask()
{
  int iport=0;
  unsigned int chupMask=0;
  unsigned int reg=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  for(iport=0; iport<16; iport++)
    {
      reg = gtpReadReg(&GTPp->Ser[iport].Status) & GTP_SER_STATUS_CHANNELUP;
      if(reg)
      chupMask |= (1<<iport);
    }
  GTPUNLOCK;

  return chupMask;
}

int
gtpEnableBitErrorCounters(int port)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if((port<0) || (port>15))
    {
      printf("%s: ERROR: Invalid payload port (%d)\n",
	     __FUNCTION__,port);
      return ERROR;
    }

  GTPLOCK;
  gtpWriteReg(&GTPp->Ser[port].Ctrl,GTP_SER_CTRL_ERR_EN | GTP_SER_CTRL_ERR_RST);
  GTPUNLOCK;

  return OK;
}

int
gtpEnableBitErrorCountersMask(int portmask)
{
  int iport=0;
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  for(iport=0; iport<16; iport++)
    {
      if((1<<iport) & portmask)
	{
	  gtpWriteReg(&GTPp->Ser[iport].Ctrl,GTP_SER_CTRL_ERR_EN | GTP_SER_CTRL_ERR_RST);
	}
    }
  GTPUNLOCK;

  return OK;
}

int
gtpSetTriggerEnableMask(int trigmask)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if(trigmask>GTP_TRG_CTRL_ENABLE_MASK)
    {
      printf("%s: ERROR: Invalid trigger mask (0x%x)\n",
	     __FUNCTION__,trigmask);
      return ERROR;
    }

  GTPLOCK;
  gtpWriteReg(&GTPp->Trg.Ctrl,trigmask);
  GTPUNLOCK;

  return OK;
}

int
gtpGetTriggerEnableMask()
{
  int rval=0;

  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = gtpReadReg(&GTPp->Trg.Ctrl) & GTP_TRG_CTRL_ENABLE_MASK;
  GTPUNLOCK;

  return rval;
}


int
gtpSetTriggerLatency(int latency)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if(latency>GTP_TRG_LATENCY_MASK)
    {
      printf("%s: ERROR: Invalid trigger latency (%d)\n",
	     __FUNCTION__,latency);
      return ERROR;
    }

  GTPLOCK;
  gtpWriteReg(&GTPp->Trg.Latency,Latency);
  GTPUNLOCK;

  return OK;
}

int
gtpGetTriggerLatency()
{
  int rval=0;

  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = gtpReadReg(&GTPp->Trg.Latency) & GTP_TRG_LATENCY_MASK;
  GTPUNLOCK;

  return rval;
}

int
gtpSetTriggerClusterThreshold(int threshold)
{
  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if(latency>GTP_TRG_CLUSTERTHR_MASK)
    {
      printf("%s: ERROR: Invalid trigger cluster threshold (%d)\n",
	     __FUNCTION__,threshold);
      return ERROR;
    }

  GTPLOCK;
  gtpWriteReg(&GTPp->Trg.ClusterThreshold,threshold);
  GTPUNLOCK;

  return OK;
}

int
gtpGetTriggerClusterThreshold()
{
  int rval=0;

  if(GTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = gtpReadReg(&GTPp->Trg.ClusterThreshold) & GTP_TRG_CLUSTERTHR_MASK;
  GTPUNLOCK;

  return rval;
}

const char *gtp_clksrc_name[GTP_CLKSRC_NUM] = 
  {
    "DISABLED",
    "SWB",
    "LOCAL",
    "DISABLED"
  };

const char *gtp_ioport_names[GTP_SRC_NUM] = 
  {
    "TRIG",
    "SYNC",
    "LVDSOUT0",
    "LVDSOUT1",
    "LVDSOUT2",
    "LVDSOUT3",
    "LVDSOUT4",
  };

const char *gtp_signal_name[GTP_SRC_SEL_NUM] = 
  {
    "Constant 0",
    "Constant 1",
    "SWB SyncReset",
    "SWB Trig1",
    "SWB Trig2",
    "FP #1",
    "FP #2",
    "FP #3",
    "FP #4",
    "Pulser Output",
    "EB Busy",
    "Undefined", "Undefined", "Undefined", "Undefined", "Undefined", /* 11-15 */
    "Undefined", "Undefined", "Undefined", "Undefined", "Undefined", /* 16-20 */
    "Undefined", "Undefined", "Undefined", "Undefined", "Undefined", /* 21-25 */
    "Undefined", "Undefined", "Undefined", "Undefined", "Undefined", /* 26-30 */
    "Undefined", 
    "Trigout #0", "Trigout #1", "Trigout #2", "Trigout #3", "Trigout #4", 
    "Trigout #5", "Trigout #6", "Trigout #7", "Trigout #8", "Trigout #9", 
    "Trigout #10", "Trigout #11", "Trigout #12", "Trigout #13", "Trigout #14", 
    "Trigout #15", "Trigout #16", "Trigout #17", "Trigout #18", "Trigout #19", 
    "Trigout #20", "Trigout #21", "Trigout #22", "Trigout #23", "Trigout #24", 
    "Trigout #25", "Trigout #26", "Trigout #27", "Trigout #28", "Trigout #29", 
    "Trigout #30", "Trigout #31"
  };
