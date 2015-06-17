#ifndef __GTPSOCKET_H_
#define __GTPSOCKET_H_
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
 *----------------------------------------------------------------------------*
 *
 * Description:
 *     Header for Socket/Ethernet library for the JLAB Global Trigger Processor
 *     (GTP) module
 *
 *----------------------------------------------------------------------------*/

enum gtpSocket_types
  {
    GTPSOCKET_TYPE_READ16 = 0x01,
    GTPSOCKET_TYPE_WRITE16,
    GTPSOCKET_TYPE_READ32,
    GTPSOCKET_TYPE_WRITE32,
    GTPSOCKET_TYPE_DELAY,
    GTPSOCKET_TYPE_READSCALERS
  };

enum gtpSocket_flags
  {
    GTPSOCKET_FLAGS_NOADRINC = 0x0,
    GTPSOCKET_FLAGS_ADRINC,
    GTPSOCKET_FLAGS_USEDMA
  };

/* Routine Prototypes */
int  gtpSocketInit(char *hostname, int port);
int  gtpSocketClose();
char *gtpSocketGetHostname();
int  gtpSocketGetPort();
int  gtpSocketWrite16(unsigned int addr, unsigned short *val, int cnt, int flags);
int  gtpSocketRead16(unsigned int addr, unsigned short *val, int cnt, int flags);
int  gtpSocketWrite32(unsigned int addr, unsigned int *val, int cnt, int flags);
int  gtpSocketRead32(unsigned int addr, unsigned int *val, int cnt, int flags);
int  gtpSocketReadScalers(unsigned int **val, int *len);
int  gtpSocketDelay(unsigned int ms);

#endif /* __GTPSOCKET_H_ */
