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
 *     Socket/Ethernet library for the JLAB Global Trigger Processor
 *     (GTP) module
 *
 *----------------------------------------------------------------------------*/

#include <sys/types.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "jvme.h"
#include "gtpSocket.h"

#define GTPSOCKET_LISTEN_PORT			6102
#define MAX_MSG_SIZE				10000
#define GTPSOCKET_HDR_ID			0x12345678
#define CMD_RSP(cmd)				(cmd | 0x80000000)

typedef struct
{
  int cnt;
  int addr;
  int flags;
} Cmd_Read16;

typedef struct
{
  int cnt;
  short vals[1];
} Cmd_Read16_Rsp;

typedef struct
{
  int cnt;
  int addr;
  int flags;
  short vals[1];
} Cmd_Write16;

typedef struct
{
  int cnt;
  int addr;
  int flags;
} Cmd_Read32;

typedef struct
{
  int cnt;
  int vals[1];
} Cmd_Read32_Rsp;

typedef struct
{
  int cnt;
  int addr;
  int flags;
  int vals[1];
} Cmd_Write32;

typedef struct
{
  int ms;
} Cmd_Delay;

typedef struct
{
  int cnt;
  unsigned int vals[1];
} Cmd_ReadScalers_Rsp;

/*************** Main message structure **************/
typedef struct
{
  int len;
  int type;
  
  union
  {
    Cmd_Read16				m_Cmd_Read16;
    Cmd_Read16_Rsp			m_Cmd_Read16_Rsp;
    Cmd_Write16				m_Cmd_Write16;
    Cmd_Read32				m_Cmd_Read32;
    Cmd_Read32_Rsp			m_Cmd_Read32_Rsp;
    Cmd_Write32				m_Cmd_Write32;
    Cmd_Delay				m_Cmd_Delay;
    Cmd_ReadScalers_Rsp 		m_Cmd_ReadScalers_Rsp;
    unsigned char			m_raw[MAX_MSG_SIZE];
  } msg;
} CrateMsgStruct;


static int sFd;     /* socket file descriptor */
static int swap=0;  /* Whether or not data must be swapped */
static char gtp_hostname[40]; 
static int  gtp_port=0;
struct sockaddr_in serverSockAddr;    /*  socket addr of server */
static CrateMsgStruct Msg; /* Current Message to be sent or received */

/* Static prototypes */
static int gtpSocketSendRaw(void *buffer, int length);
static int gtpSocketRecvRaw(void *buffer, int length);
static int gtpSocketCheckConnection(const char *fcn_name);

int cmcRead32(unsigned int addr, unsigned int *val) 
{
  if(addr>0xffff) return ERROR;
  return gtpSocketRead32(addr,val,1,0);
}
int cmcWrite32(unsigned int addr, unsigned int val)
{
  if(addr>0xffff) return ERROR;
  return gtpSocketWrite32(addr,&val,1,0);
}

int
gtpSocketInit(char *hostname, int port)
{
  struct addrinfo hints;
  struct addrinfo *result, *rp;
  int s;
  char sPort[6];
  int check_swap = GTPSOCKET_HDR_ID;

  if(port==0)
    port = GTPSOCKET_LISTEN_PORT;

  sprintf(sPort,"%d",port);

  /* Obtain address(es) matching host/port */
  
  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;    /* Allow IPv4 or IPv6 */
  hints.ai_socktype = SOCK_STREAM; /* Datagram socket */
  hints.ai_flags = 0;
  hints.ai_protocol = 0;          /* Any protocol */
  
  s = getaddrinfo(hostname, sPort, &hints, &result);
  if (s != 0) 
    {
      printf("%s: ERROR: getaddrinfo: %s\n",
	     __FUNCTION__,gai_strerror(s));
      return ERROR;;
    }
  
  /*
   *   getaddrinfo() returns a list of address structures.
   *   Try each address until we successfully connect(2).
   *   If socket(2) (or connect(2)) fails, we (close the socket
   *   and) try the next address. 
   */

  for (rp = result; rp != NULL; rp = rp->ai_next) 
    {
      sFd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
      if (sFd == -1)
	continue;
      
      if (connect(sFd, rp->ai_addr, rp->ai_addrlen) != -1)
	break;                  /* Success */
      
      close(sFd);

      printf("%s: ERROR: Failed to connect to GTP Server at %s:%d\n",
	     __FUNCTION__,hostname,port);
      freeaddrinfo(result);
      return ERROR;
    }
  freeaddrinfo(result);

  strncpy(gtp_hostname,hostname,40);
  gtp_port = port;

  /* Send endian test word to GTP server */
  gtpSocketSendRaw(&check_swap, 4);

  if(gtpSocketRecvRaw(&check_swap, 4) != 4)
    {
      printf("%s: ERROR: Endian Test failed\n",
	     __FUNCTION__);
      close(sFd);
      return ERROR;
    }
  
  if(check_swap == GTPSOCKET_HDR_ID)
    swap = 0;
  else if (check_swap == LSWAP(GTPSOCKET_HDR_ID))
    swap = 1;
  else
    {
      printf("%s: ERROR: Endian Test failed\n",
	     __FUNCTION__);
      close(sFd);
      return ERROR;
    }

  printf("%s: Connected to %s:%d\n",
	 __FUNCTION__,gtp_hostname, gtp_port);

  return OK;
}

int
gtpSocketClose()
{
  printf("%s: Closing socket connection\n",
	 __FUNCTION__);
  return close(sFd);
}

char *
gtpSocketGetHostname()
{
  return gtp_hostname;
}

int
gtpSocketGetPort()
{
  return gtp_port;
}

static int
gtpSocketRcvRsp(int type)
{
  int stat;

  stat = gtpSocketRecvRaw(&Msg, 8);
  if(stat == 8)
    {
      if(swap)
	{
	  Msg.len  = LSWAP(Msg.len);
	  Msg.type = LSWAP(Msg.type);
	}
      if((Msg.len <= MAX_MSG_SIZE) && (Msg.len >= 0) && (Msg.type == (int)CMD_RSP(type)))
	{
	  if(!Msg.len)
	    return OK;
	  
	  stat = gtpSocketRecvRaw(&Msg.msg, Msg.len);
	  if(stat == Msg.len)
	    return OK;
	  else
	    printf("%s: ERROR: Unexpected GTP server message length (%d)\n",
		   __FUNCTION__,stat);
	    
	}
    }
  else
    {
      printf("%s: ERROR: Unexpected GTP server response size (%d)\n",
	     __FUNCTION__,stat);
    }

  gtpSocketClose();
  return ERROR;
}

int
gtpSocketWrite16(unsigned int addr, unsigned short *val, int cnt, int flags)
{
  int i;
  if(gtpSocketCheckConnection(__FUNCTION__)==ERROR)
    return ERROR;

  Msg.len = 12+2*cnt;
  Msg.type = GTPSOCKET_TYPE_WRITE16;
  Msg.msg.m_Cmd_Write16.cnt = cnt;
  Msg.msg.m_Cmd_Write16.addr = addr;
  Msg.msg.m_Cmd_Write16.flags = flags;
  for(i = 0; i < cnt; i++)
    Msg.msg.m_Cmd_Write16.vals[i] = val[i];
  gtpSocketSendRaw(&Msg, Msg.len+8);

  return OK;
}

int 
gtpSocketRead16(unsigned int addr, unsigned short *val, int cnt, int flags)
{
  int i;
  if(gtpSocketCheckConnection(__FUNCTION__)==ERROR)
    return ERROR;

  Msg.len = 12;
  Msg.type = GTPSOCKET_TYPE_READ16;
  Msg.msg.m_Cmd_Read16.cnt = cnt;
  Msg.msg.m_Cmd_Read16.addr = addr;
  Msg.msg.m_Cmd_Read16.flags = flags;
  gtpSocketSendRaw(&Msg, Msg.len+8);

  if(gtpSocketRcvRsp(Msg.type)==OK)
    {
      if(swap)
	{
	  Msg.msg.m_Cmd_Read16_Rsp.cnt = LSWAP(Msg.msg.m_Cmd_Read16_Rsp.cnt);
	  for(i = 0; i < Msg.msg.m_Cmd_Read16_Rsp.cnt; i++)
	    val[i] = SSWAP(Msg.msg.m_Cmd_Read16_Rsp.vals[i]);
	}
      else
	{
	  for(i = 0; i < Msg.msg.m_Cmd_Read16_Rsp.cnt; i++)
	    val[i] = Msg.msg.m_Cmd_Read16_Rsp.vals[i];
	}
      return OK;
    }
  else
    {
      printf("%s: ERROR reading from GTP address 0x%x\n",
	     __FUNCTION__,addr);
    }
  return ERROR;
}

int 
gtpSocketWrite32(unsigned int addr, unsigned int *val, int cnt, int flags)
{
  int i;
  if(gtpSocketCheckConnection(__FUNCTION__)==ERROR)
    return ERROR;

  Msg.len = 12+4*cnt;
  Msg.type = GTPSOCKET_TYPE_WRITE32;
  Msg.msg.m_Cmd_Write32.cnt = cnt;
  Msg.msg.m_Cmd_Write32.addr = addr;
  Msg.msg.m_Cmd_Write32.flags = flags;
  for(i = 0; i < cnt; i++)
    Msg.msg.m_Cmd_Write32.vals[i] = val[i];
  gtpSocketSendRaw(&Msg, Msg.len+8);

  return OK;
}

int
gtpSocketRead32(unsigned int addr, unsigned int *val, int cnt, int flags)
{
  int i;
  if(gtpSocketCheckConnection(__FUNCTION__)==ERROR)
    {
      printf("Check returned error\n");
      return ERROR;
    }

  Msg.len = 12;
  Msg.type = GTPSOCKET_TYPE_READ32;
  Msg.msg.m_Cmd_Read16.cnt = cnt;
  Msg.msg.m_Cmd_Read16.addr = addr;
  Msg.msg.m_Cmd_Read16.flags = flags;
  gtpSocketSendRaw(&Msg, Msg.len+8);

  if(gtpSocketRcvRsp(Msg.type)==OK)
    {
      if(swap)
	{
	  Msg.msg.m_Cmd_Read32_Rsp.cnt = LSWAP(Msg.msg.m_Cmd_Read32_Rsp.cnt);
	  for(i = 0; i < Msg.msg.m_Cmd_Read32_Rsp.cnt; i++)
	    val[i] = LSWAP(Msg.msg.m_Cmd_Read32_Rsp.vals[i]);
	}
      else
	{
	  for(i = 0; i < Msg.msg.m_Cmd_Read32_Rsp.cnt; i++)
	    val[i] = Msg.msg.m_Cmd_Read32_Rsp.vals[i];
	}
      return OK;
    }
  else
    {
      printf("%s: ERROR reading from GTP address 0x%x\n",
	     __FUNCTION__,addr);
    }

  return ERROR;
}

int
gtpSocketReadScalers(unsigned int **val, int *len)
{
  int i=0;

  if(gtpSocketCheckConnection(__FUNCTION__)==ERROR)
    return ERROR;

  Msg.len = 0;
  Msg.type = GTPSOCKET_TYPE_READSCALERS;
  gtpSocketSendRaw(&Msg, Msg.len+8);

  if(gtpSocketRcvRsp(Msg.type)==OK)
    {
      if(swap)
	Msg.msg.m_Cmd_Read32_Rsp.cnt = LSWAP(Msg.msg.m_Cmd_Read32_Rsp.cnt);

      *val = malloc(sizeof(unsigned int)*Msg.msg.m_Cmd_Read32_Rsp.cnt);
      if(!(*val))
	return ERROR;

      if(swap)
	{
	  for(i = 0; i < Msg.msg.m_Cmd_Read32_Rsp.cnt; i++)
	    (*val)[i] = LSWAP(Msg.msg.m_Cmd_Read32_Rsp.vals[i]);
	}
      else
	{
	  for(i = 0; i < Msg.msg.m_Cmd_Read32_Rsp.cnt; i++)
	    (*val)[i] = Msg.msg.m_Cmd_Read32_Rsp.vals[i];
	}
      return OK;
    }
  else
    {
      printf("%s: ERROR reading from GTP scalers\n",__FUNCTION__);
    }

  return ERROR;
}

int
gtpSocketDelay(unsigned int ms)
{
  if(gtpSocketCheckConnection(__FUNCTION__)==ERROR)
    return ERROR;

  Msg.len = 4;
  Msg.type = GTPSOCKET_TYPE_DELAY;
  Msg.msg.m_Cmd_Delay.ms = ms;
  gtpSocketSendRaw(&Msg, Msg.len+8);

  return OK;
}


static int
gtpSocketSendRaw(void *buffer, int length)
{
  return write(sFd, buffer, length);
}

static int
gtpSocketRecvRaw(void *buffer, int length)
{
  return recv(sFd, buffer, length, 0);
}

static int 
gtpSocketCheckConnection(const char *fcn_name)
{
  if(!sFd)
    {
      printf("%s: ERROR: No Connection to GTP at %s:%d\n", 
	     fcn_name, gtp_hostname,gtp_port);
      return gtpSocketInit(gtp_hostname,gtp_port);
    }
  return OK;
}
