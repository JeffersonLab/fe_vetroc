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
#include "gtpVMELib.h"
#include "tiLib.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

/* Mutex to guard GTP read/writes */
pthread_mutex_t   gtpMutex = PTHREAD_MUTEX_INITIALIZER;
#define GTPLOCK     if(pthread_mutex_lock(&gtpMutex)<0) perror("pthread_mutex_lock");
#define GTPUNLOCK   if(pthread_mutex_unlock(&gtpMutex)<0) perror("pthread_mutex_unlock");

/* This is the GTP base relative to the TI base VME address */
#define GTPBASE 0x30000 

/* Global Variables */
volatile struct GTPStruct  *vGTPp=NULL;    /* pointer to GTP memory map */

/* External TI Local Pointer */
extern volatile struct TI_A24RegStruct *TIp;

/*
  gtpInit
  - Initialize the Global Trigger Processor module
*/
int
gtpVMEInit(int rFlag)
{
  unsigned long tiBase=0, gtpBase=0;
  unsigned int tmp1, tmp2, BoardId=0, version=0;

  if(TIp==NULL)
    {
      printf("%s: ERROR: TI not initialized\n",__FUNCTION__);
      return ERROR;
    }

  /* Verify that the ctp registers are in the correct space for the TI I2C */
  tiBase = (unsigned long)TIp;
  gtpBase = (unsigned long)&(TIp->SWA[0]);
  
  if( (gtpBase-tiBase) != GTPBASE)
    {
      printf("%s: ERROR: GTP memory structure not in correct VME Space!\n",
	     __FUNCTION__);
      printf("   current base = 0x%lx   expected base = 0x%lx\n",
	     gtpBase-tiBase, (unsigned long)GTPBASE);
      return ERROR;
    }

  vGTPp = (struct GTPStruct *)(&TIp->SWA[0]);

  /* Check the module ID, to confirm we've got a GTP in there */
  GTPLOCK;
  tmp1 = vmeRead32(&vGTPp->BoardId[1])&0xFFFF;
  tmp2 = vmeRead32(&vGTPp->BoardId[0])&0xFFFF;
  BoardId = SSWAP(tmp1)<<16|SSWAP(tmp2);
    
  tmp1 = vmeRead32(&vGTPp->FirmwareRev[1])&0xFFFF;
  tmp2 = vmeRead32(&vGTPp->FirmwareRev[0])&0xFFFF;
  version = SSWAP(tmp1)<<16|SSWAP(tmp2);
  GTPUNLOCK;

  if(BoardId != (GTP_BOARDID))
    {
      printf("%s: ERROR: Invalid GTP Board ID (0x%08x)\n",
	     __FUNCTION__,BoardId);
      return ERROR;
    }

  if(version == 0xffffffff)
    {
      printf("%s: ERROR: Unable to read GTP version (returned 0x%x)\n",
	     __FUNCTION__,version);
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
gtpVMEStatus(int pFlag)
{
  struct GTPStruct st;
  int i=0, showregs=0;
  unsigned long gtpBase=0, tiBase=0;
  unsigned int version=0, hn[4];

  if(vGTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  if(pFlag & GTP_STATUS_SHOWREGS)
    showregs=1;


  tiBase = (unsigned long)TIp;
  gtpBase = (unsigned long)&(TIp->SWA[0]);

  GTPLOCK;
  for(i=0; i<2; i++)
    {
      st.BoardId[i]     = vmeRead32(&vGTPp->BoardId[i]) & 0xFFFF;
      st.FirmwareRev[i] = vmeRead32(&vGTPp->FirmwareRev[i]) & 0xFFFF;
      st.CpuStatus[i]   = vmeRead32(&vGTPp->CpuStatus[i]) & 0xFFFF;
    }
  for(i=0; i<8; i++)
    {
      st.Hostname[i]    = vmeRead32(&vGTPp->Hostname[i]) & 0xFFFF;
    }
  GTPUNLOCK;

  version = ((st.BoardId[1] & 0xFFFF)<<16) | (st.BoardId[0] & 0xFFFF);
  for(i=0; i<4; i++)
    {
      hn[i] = (st.Hostname[2*i]) | ((st.Hostname[2*(i+1)])<<16);
    }

  /* Now printout what we've got */
  printf("STATUS for GTP at TI (Local) base address 0x%08lx (0x%08lx) \n",gtpBase-tiBase,gtpBase);
  printf("--------------------------------------------------------------------------------\n");
  printf("   Type = %d  Firmware Version %d.%d\n",
	 (version & GTP_FIRMWAREREV_TYPE_MASK)>>16,
	 (version & GTP_FIRMWAREREV_MAJOR_MASK)>>8,
	 (version & GTP_FIRMWAREREV_MINOR_MASK));
  if(showregs)
    {
      printf(" Raw Registers\n");
      printf("  BoardId[0]     (0x%04x) = 0x%04x\t", 
	     (unsigned int)(&vGTPp->BoardId[0] - gtpBase), st.BoardId[0]);
      printf("  BoardId[1]     (0x%04x) = 0x%04x\n", 
	     (unsigned int)(&vGTPp->BoardId[1] - gtpBase), st.BoardId[1]);

      printf("  FirmwareRev[0] (0x%04x) = 0x%04x\t", 
	     (unsigned int)(&vGTPp->FirmwareRev[0] - gtpBase), st.FirmwareRev[0]);
      printf("  FirmwareRev[1] (0x%04x) = 0x%04x\n", 
	     (unsigned int)(&vGTPp->FirmwareRev[1] - gtpBase), st.FirmwareRev[1]);

      printf("  CpuStatus[0]   (0x%04x) = 0x%04x\t", 
	     (unsigned int)(&vGTPp->CpuStatus[0] - gtpBase), st.CpuStatus[0]);
      printf("  CpuStatus[1]   (0x%04x) = 0x%04x\n", 
	     (unsigned int)(&vGTPp->CpuStatus[1] - gtpBase), st.CpuStatus[1]);

      for(i=0; i<8; i=i+2)
	{
	  printf("  Hostname[%d]    (0x%04x) = 0x%04x\t", i,
		 (unsigned int)(&vGTPp->Hostname[i] - gtpBase), st.Hostname[i]);
	  printf("  Hostname[%d]    (0x%04x) = 0x%04x\n", i+1,
		 (unsigned int)(&vGTPp->Hostname[i+1] - gtpBase), st.Hostname[i+1]);
	}
      
      for(i=0; i<4; i=i+2)
	{
	  printf("  hn[%d]                   = 0x%08x\t", i,hn[i]);
	  printf("  hn[%d]                   = 0x%08x\n", i+1,hn[i+1]);
	}

    }
  
  return OK;
}

int
gtpVMEGetHostname(char **rval, int pFlag)
{
  int slen=0, done=0;
  int i=0, ibyte=0;
  unsigned int read1, read2, hn[4];
  char hostname[60], byte_c[2];
  unsigned int shift=0, mask=0, byte=0;

  if(vGTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  memset((char*)hostname,0,sizeof(hostname));

  GTPLOCK;
  for(i=0; i<4; i++)
    {
      read1 = vmeRead32(&vGTPp->Hostname[2*i])&0xFFFF;
      read2 = vmeRead32(&vGTPp->Hostname[(2*i+1)])&0xFFFF;
      read1 = SSWAP(read1);
      read2 = SSWAP(read2);
      hn[i] =  (read1) |  (read2<<16);
    }
  GTPUNLOCK;

  strcpy(hostname,"");
  for(i=0; i<4; i++)
    {
      if(done)
	break;
      for(ibyte=0; ibyte<4; ibyte++)
	{
	  shift = (ibyte*8);
	  mask  = (0xFF)<<shift;
	  byte  = (hn[i] & mask)>>shift;
	  if(byte==0x0) 
	    {
	      done=1;
	      break;
	    }
	  sprintf(byte_c,"%c",byte);
	  strcat(hostname,byte_c);
	}
    }

  if(pFlag)
    printf("%s: Hostname = >%s<\n",
	   __FUNCTION__,hostname);

  strcpy((char *)rval,hostname);
  slen = (int)strlen(hostname);

  return slen;
}

int
gtpVMEGetCpuStatus()
{
  int rval=0;
  if(vGTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }

  GTPLOCK;
  rval = vmeRead32(&vGTPp->CpuStatus[0]);
  rval = SSWAP(rval) & GTP_CPUSTATUS_BOOTED;
  GTPUNLOCK;

  return rval;
}

unsigned int
getVMEGetFirmwareVersion()
{
  unsigned int rval=0;
  if(vGTPp==NULL)
    {
      printf("%s: ERROR: GTP not initialized\n",__FUNCTION__);
      return ERROR;
    }
  
  GTPLOCK;
  rval = (vmeRead32(&vGTPp->FirmwareRev[0]) & 0xFFFF) |
    (vmeRead32(&vGTPp->FirmwareRev[1]) & 0xFFFF)<<16;
  GTPUNLOCK;

  return rval;
}
