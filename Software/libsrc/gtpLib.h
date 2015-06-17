/* gtpLib.h */

#ifndef GTPLIB_H
#define GTPLIB_H

#include "gtpVMELib.h"
#include "gtpSocket.h"

#define GTP_ADDR		0xF8010000

#define GTP_SER_VXS0		0
#define GTP_SER_VXS1		1
#define GTP_SER_VXS2		2
#define GTP_SER_VXS3		3
#define GTP_SER_VXS4		4
#define GTP_SER_VXS5		5
#define GTP_SER_VXS6		6
#define GTP_SER_VXS7		7
#define GTP_SER_VXS8		8
#define GTP_SER_VXS9		9
#define GTP_SER_VXS10	10
#define GTP_SER_VXS11	11
#define GTP_SER_VXS12	12
#define GTP_SER_VXS13	13
#define GTP_SER_VXS14	14
#define GTP_SER_VXS15	15

#define GTP_SER_CTRL_POWERDN    (1<<0)
#define GTP_SER_CTRL_ERR_RST   (1<<10)
#define GTP_SER_CTRL_ERR_EN    (1<<11)

#define GTP_SER_STATUS_HARDERR0   (1<<0)
#define GTP_SER_STATUS_HARDERR1   (1<<1)
#define GTP_SER_STATUS_LANEUP0    (1<<4)
#define GTP_SER_STATUS_LANEUP1    (1<<5)
#define GTP_SER_STATUS_CHANNELUP  (1<<12)
#define GTP_SER_STATUS_TXLOCK     (1<<13)
#define GTP_SER_STATUS_RXSRCRDYN  (1<<14)

#define GTP_SER_ERRTILE_LANE0_BITERRORS  0x0000FFFF
#define GTP_SER_ERRTILE_LANE1_BITERRORS  0xFFFF0000

#define GTP_SER_STATUS2_LATENCY_MASK 0x00000FFF
#define GTP_SER_STATUS2_CRCPASS      (1<<16);

// Serdes Peripheral: VXS serdes controls and monitors
typedef struct
{
/* 0x0000-0x0003 */	unsigned int Ctrl;
/* 0x0004-0x000F */	unsigned int Reserved0[(0x0010-0x0004)/4];
/* 0x0010-0x0013 */	unsigned int Status;
/* 0x0014-0x0017 */	unsigned int Reserved1[(0x0018-0x0014)/4];
/* 0x0018-0x001B */	unsigned int ErrTile0;
/* 0x001C-0x001F */	unsigned int Status2;
/* 0x0020-0x0023 */	unsigned int LaCtrl;
/* 0x0024-0x0027 */	unsigned int LaStatus;
/* 0x0028-0x002F */	unsigned int Reserved2[(0x0030-0x0028)/4];
/* 0x0030-0x0037 */	unsigned int LaData[2];
/* 0x0038-0x004F */	unsigned int Reserved3[(0x0050-0x0038)/4];
/* 0x0050-0x0053 */	unsigned int CompareMode;
/* 0x0054-0x006F */	unsigned int Reserved4[(0x0070-0x0054)/4];
/* 0x0070-0x0073 */	unsigned int CompareThreshold;
/* 0x0074-0x008F */	unsigned int Reserved5[(0x0090-0x0074)/4];
/* 0x0090-0x0097 */	unsigned int MaskEn[2];
/* 0x0098-0x00AF */	unsigned int Reserved6[(0x00B0-0x0098)/4];
/* 0x00B0-0x00B7 */	unsigned int MaskVal[2];
/* 0x00B8-0x00FF */	unsigned int Reserved7[(0x0100-0x00B8)/4];
} GtpSerdes_regs;

// Serdes Peripheral: QSFP serdes controls and monitors
typedef struct
{
/* 0x0000-0x0003 */	unsigned int Ctrl;
/* 0x0004-0x000F */	unsigned int Reserved0[(0x0010-0x0004)/4];
/* 0x0010-0x0013 */	unsigned int Status;
/* 0x0014-0x0017 */	unsigned int Reserved1[(0x0018-0x0014)/4];
/* 0x0018-0x001B */	unsigned int ErrTile0;
/* 0x001C-0x001F */	unsigned int ErrTile1;
/* 0x0020-0x0023 */	unsigned int LaCtrl;
/* 0x0024-0x0027 */	unsigned int LaStatus;
/* 0x0028-0x002F */	unsigned int Reserved2[(0x0030-0x0028)/4];
/* 0x0030-0x003B */	unsigned int LaData[3];
/* 0x003C-0x004F */	unsigned int Reserved3[(0x0050-0x003C)/4];
/* 0x0050-0x0053 */	unsigned int CompareMode;
/* 0x0054-0x006F */	unsigned int Reserved4[(0x0070-0x0054)/4];
/* 0x0070-0x0073 */	unsigned int CompareThreshold;
/* 0x0074-0x008F */	unsigned int Reserved5[(0x0090-0x0074)/4];
/* 0x0090-0x009B */	unsigned int MaskEn[3];
/* 0x009C-0x00AF */	unsigned int Reserved6[(0x00B0-0x009C)/4];
/* 0x00B0-0x00BB */	unsigned int MaskVal[3];
/* 0x00BC-0x00FF */	unsigned int Reserved7[(0x0100-0x00BC)/4];
} GtpQsfpSerdes_regs;

// GXB Reconfig Peripheral: Serdes debug interface
typedef struct
{
/* 0x0000-0x0003 */	unsigned int Status;
/* 0x0004-0x0007 */	unsigned int Ctrl;
/* 0x0008-0x000B */	unsigned int Ctrl2;
/* 0x000C-0x000F */	unsigned int TxRxIn;
/* 0x0010-0x0013 */	unsigned int TxRxOut;
/* 0x0014-0x00FF */	unsigned int Reserved0[(0x0100-0x0014)/4];
} GtpGxbCfg_regs;

#define GTP_CLK_CTRL_P0			0x00000001
#define GTP_CLK_CTRL_INT		0x00000002
#define GTP_CLK_CTRL_SRC_MASK           0x00000003
#define GTP_CLK_CTRL_RESET		0x80000000
#define GTP_CLKSRC_NUM                  4

#define GTP_CLK_STATUS_GCLK_LOCK      (1<<0)
#define GTP_CLK_STATUS_L_LOCK         (1<<1)
#define GTP_CLK_STATUS_R_LOCK         (1<<2)
#define GTP_CLK_STATUS_LOCK_MASK  0x00000003

// Configuration Peripheral: Gtp configuration interface
typedef struct
{
/* 0x0000-0x0003 */	unsigned int BoardId;
/* 0x0004-0x0007 */	unsigned int FirmwareRev;
/* 0x0008-0x000B */	unsigned int CpuStatus;
/* 0x000C-0x001B */	unsigned int Hostname[4];
/* 0x001C-0x00FF */	unsigned int Reserved0[(0x0100-0x001C)/4];
} GtpCfg_regs;

// Clock Peripheral: Clock configuration interface
typedef struct
{
/* 0x0000-0x0003 */	unsigned int Ctrl;
/* 0x0004-0x0007 */	unsigned int Status;
/* 0x0008-0x00FF */	unsigned int Reserved0[(0x0100-0x0008)/4];
} GtpClk_regs;

#define GTP_TRG_LATENCY_MASK        0x00000FFF
#define GTP_TRG_CTRL_ENABLE_MASK    0x000000FF
#define GTP_TRG_CLUSTERTHR_MASK     0x00000007

// Trigger Peripheral
typedef struct
{
/* 0x0000-0x0003 */	unsigned int Ctrl;
/* 0x0004-0x0007 */	unsigned int Status;
/* 0x0008-0x000B */	unsigned int Latency;
/* 0x000C-0x000F */	unsigned int ClusterThreshold;
/* 0x0010-0x03FF */	unsigned int Reserved0[(0x0400-0x0010)/4];
} GtpTrigger_regs;

// GtpSd_regs->SrcSel[] IDs
#define GTP_SD_SRC_TRIG					0
#define GTP_SD_SRC_SYNC					1
#define GTP_SD_SRC_LVDSOUT0			2
#define GTP_SD_SRC_LVDSOUT1			3
#define GTP_SD_SRC_LVDSOUT2			4
#define GTP_SD_SRC_LVDSOUT3			5
#define GTP_SD_SRC_LVDSOUT4			6

// GtpSd_regs->SrcSel[] values
#define GTP_SD_SRC_SEL_0				0
#define GTP_SD_SRC_SEL_1				1
#define GTP_SD_SRC_SEL_SYNC			2
#define GTP_SD_SRC_SEL_TRIG1			3
#define GTP_SD_SRC_SEL_TRIG2			4
#define GTP_SD_SRC_SEL_LVDSIN(n)		(5+n)
#define GTP_SD_SRC_SEL_PULSER			9
#define GTP_SD_SRC_SEL_BUSY			10
#define GTP_SD_SRC_SEL_TRIGGER(n)	(32+n)

// GtpSd_regs->Scalers[] IDs
#define GTP_SD_SCALER_50MHZ			0
#define GTP_SD_SCALER_GCLK				1
#define GTP_SD_SCALER_SYNC				2
#define GTP_SD_SCALER_TRIG1			3
#define GTP_SD_SCALER_TRIG2			4
#define GTP_SD_SCALER_BUSY				5
#define GTP_SD_SCALER_BUSYCYCLES		6
#define GTP_SD_SCALER_FPIN(n)			(7+n)
#define GTP_SD_SCALER_FPOUT(n)		(11+n)

// SD Peripheral
typedef struct
{
/* 0x0000-0x0003 */	unsigned int ScalerLatch;
/* 0x0004-0x003F */	unsigned int Scalers[15];
/* 0x0040-0x00FF */	unsigned int Reserved0[(0x0100-0x0040)/4];
/* 0x0100-0x0103 */	unsigned int PulserPeriod;
/* 0x0104-0x0107 */	unsigned int PulserLowCycles;
/* 0x0108-0x010B */	unsigned int PulserNPulses;
/* 0x010C-0x010F */	unsigned int PulserDone;
/* 0x0110-0x0113 */	unsigned int PulserStart;
/* 0x0114-0x011F */	unsigned int Reserved1[(0x0120-0x0114)/4];
/* 0x0120-0x0137 */	unsigned int SrcSel[6];
/* 0x0138-0x01FF */	unsigned int Reserved2[(0x0200-0x0138)/4];
} GtpSd_regs;

// TiGtp Peripheral
typedef struct
{
/* 0x0000-0x0003 */	unsigned int LinkCtrl;
/* 0x0004-0x0007 */	unsigned int LinkStatus;
/* 0x0008-0x000B */	unsigned int LinkReset;
/* 0x000C-0x000F */	unsigned int Reserved0[(0x0010-0x000C)/4];
/* 0x0010-0x0013 */	unsigned int FifoCtrl;
/* 0x0014-0x0017 */	unsigned int FifoDataStatus;
/* 0x0018-0x001B */	unsigned int FifoData;
/* 0x001C-0x001F */	unsigned int FifoLenStatus;
/* 0x0020-0x0023 */	unsigned int FifoLen;
/* 0x0024-0x0027 */	unsigned int BlockLength;
/* 0x0028-0x00FF */	unsigned int Reserved2[(0x0100-0x0028)/4];
} GtpTi_regs;

// GTP memory structure
typedef struct
{
/* 0x0000-0x00FF */	GtpCfg_regs				Cfg;
/* 0x0100-0x01FF */	GtpClk_regs				Clk;
/* 0x0200-0x03FF */	GtpSd_regs				Sd;
/* 0x0400-0x04FF */	unsigned int			Reserved0[(0x0500-0x0400)/4];
/* 0x0500-0x05FF */	GtpGxbCfg_regs			GxbCfgOdd;
/* 0x0600-0x06FF */	GtpGxbCfg_regs			GxbCfgEven;
/* 0x0700-0x0FFF */	unsigned int			Reserved1[(0x1000-0x0700)/4];
/* 0x1000-0x1FFF */	GtpSerdes_regs			Ser[16];
/* 0x2000-0x23FF */	GtpTrigger_regs		Trg;
/* 0x2400-0x24FF */	GtpQsfpSerdes_regs	QsfpSer;
/* 0x2500-0x25FF */	GtpTi_regs				TiGtp;
/* 0x2500-0xFFFF */	unsigned int			Reserved2[(0x10000-0x2500)/4];
} Gtp_regs;

/* Routine prototypes */
int  gtpInit(int rFlag, char* gHostname);
int  gtpStatus(int pflag);
int  gtpCheckAddresses();

int  gtpSetClockSource(int clksrc);
int  gtpGetClockSource();
int  gtpGetClockPLLStatus();
int  gtpSetSyncSource(int srsrc);
int  gtpGetSyncSource();
int  gtpSetTrig1Source(int trig1src);
int  gtpGetTrig1Source();

int  gtpEnablePayloadPort(int port);
int  gtpDisablePayloadPort(int port);
int  gtpEnableVmeSlot(int vmeslot);
int  gtpDisableVmeSlot(int vmeslot);
int  gtpEnablePayloadPortMask(int portmask);
int  gtpEnableVmeSlotMask(unsigned int vmeslotmask);

int  gtpGetChannelUpMask();
int  gtpEnableBitErrorCounters(int port);
int  gtpEnableBitErrorCountersMask(int portmask);

int  gtpSetTriggerEnableMask(int trigmask);
int  gtpGetTriggerEnableMask();
int  gtpSetTriggerLatency(int latency);
int  gtpGetTriggerLatency();
int  gtpSetTriggerClusterThreshold(int thr);
int  gtpGetTriggerClusterThreshold();

extern const char *gtp_clksrc_name[GTP_CLKSRC_NUM];
extern const char *gtp_ioport_names[GTP_SRC_NUM];
extern const char *gtp_signal_name[GTP_SRC_SEL_NUM];

#endif
