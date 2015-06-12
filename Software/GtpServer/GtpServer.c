#include <sys/mman.h>
#include <sys/signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "CrateMsgTypes.h"
#include "gtp.h"

#define LED_AMBER		0x1
#define LED_RED		0x2

void sig_handler(int signo);
void GtpClearLed(int led);
void GtpSetLed(int led);

int fdGtpMem;
int *pGtp;
Gtp_regs *pGtpPerStructPtr;
GtpScalers gGtpScalers;
ServerCBFunctions gCrateServerCBFcn;
pthread_mutex_t mutexRegisterAccess;

void Gtp_Lock(int lock)
{
	if(lock)
		pthread_mutex_lock(&mutexRegisterAccess);
	else
		pthread_mutex_unlock(&mutexRegisterAccess);
}

int Gtp_Read32(Cmd_Read32 *pCmd_Read32, Cmd_Read32_Rsp *pCmd_Read32_Rsp)
{
	int *pRd = (int *)(pGtp + (pCmd_Read32->addr>>2));
	int *pWr = pCmd_Read32_Rsp->vals;
	int c = pCmd_Read32->cnt;
	int size = 4+4*c;

	GtpSetLed(LED_RED);
	
	pCmd_Read32_Rsp->cnt = c;	
	
	if(pGtp)
	{
		if(pCmd_Read32->flags & CRATE_MSG_FLAGS_ADRINC)
			while(c--) *pWr++ = *pRd++;
		else
			while(c--) *pWr++ = *pRd;
	}

	GtpClearLed(LED_RED);

	return size;
}

int Gtp_Write32(Cmd_Write32 *pCmd_Write32)
{
	int *pRd = pCmd_Write32->vals;
	int *pWr = (int *)(pGtp + (pCmd_Write32->addr>>2));
	int c = pCmd_Write32->cnt;

	GtpSetLed(LED_RED);
	
	if(pGtp)
	{
		if(pCmd_Write32->flags & CRATE_MSG_FLAGS_ADRINC)
			while(c--) *pWr++ = *pRd++;
		else
			while(c--) *pWr = *pRd++;
	}

	GtpClearLed(LED_RED);

	return 0;
}

int Gtp_ReadScalers(Cmd_ReadScalers_Rsp *pCmd_ReadScalers_Rsp)
{
	int len = sizeof(GtpScalers);
	
	GtpSetLed(LED_RED);
	
	pCmd_ReadScalers_Rsp->cnt = len>>2;
	
	Gtp_Lock(1);
	memcpy(pCmd_ReadScalers_Rsp->vals, &gGtpScalers, len);
	Gtp_Lock(0);
	
	GtpClearLed(LED_RED);
	
	return len+4;
}

int Gtp_Delay(Cmd_Delay *pCmd_Delay)
{
	GtpSetLed(LED_RED);

	usleep(1000*pCmd_Delay->ms);
	
	GtpClearLed(LED_RED);
	
	return 0;
}

void GtpPollScalers(void)
{
	int i;
	
	if(!pGtp)
		return;

	Gtp_Lock(1);
	
	// Disable scalers for readout
	pGtpPerStructPtr->Sd.ScalerLatch = 1;

	gGtpScalers.SysClk50 = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_50MHZ];
	gGtpScalers.GClk = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_GCLK];
	gGtpScalers.Sync = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_SYNC];
	gGtpScalers.Trig1 = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_TRIG1];
	gGtpScalers.Trig2 = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_TRIG2];
	gGtpScalers.Busy = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_BUSY];
	gGtpScalers.BusyCycles = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_BUSYCYCLES];
	
	for(i = 0; i < 4; i++)
	{
		gGtpScalers.FpIn[i] = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_FPIN(i)];
		gGtpScalers.FpOut[i] = pGtpPerStructPtr->Sd.Scalers[GTP_SD_SCALER_FPOUT(i)];
	}
	
	for(i = 0; i < 32; i++)
	{
		gGtpScalers.FCalEnergy[i] = pGtpPerStructPtr->FCal.HistDataEnergy;
		gGtpScalers.BCalEnergy[i] = pGtpPerStructPtr->BCal.HistDataEnergy;
		gGtpScalers.BCalHitModules[i] = pGtpPerStructPtr->BCal.HistDataHits;
		gGtpScalers.TOF[i] = pGtpPerStructPtr->TOF.Scalers[i];
		gGtpScalers.TagM[i] = pGtpPerStructPtr->TagM.Scalers[i];
		gGtpScalers.TagH[i] = pGtpPerStructPtr->TagH.Scalers[i];
		gGtpScalers.PS[i] = pGtpPerStructPtr->PS.Scalers[i];
		gGtpScalers.ST[i] = pGtpPerStructPtr->ST.Scalers[i];
		gGtpScalers.Trig_BCal[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_BCALHIT];
		gGtpScalers.Trig_BFCal[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_BFCAL];
		gGtpScalers.Trig_TAGM[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_TAGM];
		gGtpScalers.Trig_TAGH[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_TAGH];
		gGtpScalers.Trig_PS[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_PS];
		gGtpScalers.Trig_ST[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_ST];
		gGtpScalers.Trig_TOF[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_TOF];
		gGtpScalers.Trig[i] = pGtpPerStructPtr->Trigbits[i].Scalers[GTP_TRIGBIT_SCALER_TRIGOUT];
	}

	// Enable/reset scalers for accumulation
	pGtpPerStructPtr->Sd.ScalerLatch = 0;
	
	Gtp_Lock(0);
}

void GtpSetLed(int led)
{
	int status;
	
	Gtp_Lock(1);
	
	status = pGtpPerStructPtr->Cfg.CpuStatus;

	if(led & 0x1)
		status |= 0x1;
	
	if(led & 0x2)
		status |= 0x2;
	
	pGtpPerStructPtr->Cfg.CpuStatus = status;
	
	Gtp_Lock(0);
}

void GtpClearLed(int led)
{
	int status;
	
	Gtp_Lock(1);
	
	status = pGtpPerStructPtr->Cfg.CpuStatus;
	
	if(led & 0x1)
		status &= ~0x1;
	
	if(led & 0x2)
		status &= ~0x2;
	
	pGtpPerStructPtr->Cfg.CpuStatus = status;
	
	Gtp_Lock(0);
}

void GtpSetHostname()
{
	FILE *f;
	char name[100];
	int i;
	
	
	memset(name, 0, sizeof(name));
	f = fopen("/etc/hostname", "rt");
	if(f)
	{
		fgets(name, sizeof(name), f);
		fclose(f);
	}
	
	// shorten hostname in case it's a FQDN...
	for(i = 0; i < sizeof(name); i++)
	{
		if(!name[i] || (name[i] == '.'))
		{
			name[i] = 0;
			break;
		}
	}
	
	printf("GtpSetHostname(): set to %s\n", name);
	
	pGtpPerStructPtr->Cfg.Hostname[0] = (name[0]<<0) | (name[1]<<8) | (name[2]<<16) | (name[3]<<24);
	pGtpPerStructPtr->Cfg.Hostname[1] = (name[4]<<0) | (name[5]<<8) | (name[6]<<16) | (name[7]<<24);
	pGtpPerStructPtr->Cfg.Hostname[2] = (name[8]<<0) | (name[9]<<8) | (name[10]<<16) | (name[11]<<24);
	pGtpPerStructPtr->Cfg.Hostname[3] = (name[12]<<0) | (name[13]<<8) | (name[14]<<16) | (name[15]<<24);
}

void GtpPrintVersion()
{
	int v;
	
	Gtp_Lock(1);
	
	v = pGtpPerStructPtr->Cfg.BoardId;
	printf("Gtp BoardId = \"%c%c%c%c\"\n", (char)((v>>24) & 0xFF), (char)((v>>16) & 0xFF),
	                                       (char)((v>>8) & 0xFF), (char)((v>>0) & 0xFF));
	printf("Gtp FirmwareRev = 0x%08X\n", pGtpPerStructPtr->Cfg.FirmwareRev);
		
	Gtp_Lock(0);
}

int gtpmem_open()
{
	// Get pointer to Gtp peripherals
	fdGtpMem = open("/dev/uio0", O_RDWR);
	if(fdGtpMem < 1)
	{
		perror("failed to open /dev/uio0\n");
		return -1;
	}
	pGtp = (int *)mmap(NULL, 0x10000, PROT_READ | PROT_WRITE, MAP_SHARED, fdGtpMem, (off_t)0);
	
	if(pGtp == MAP_FAILED)
	{
		perror("mmap /dev/uio0 Gtp Mem failed\n");
		pGtp = NULL;
		pGtpPerStructPtr = NULL;
		return -1;
	}
	pGtpPerStructPtr = (Gtp_regs *)pGtp;
	
	printf("GtpMem starting @ 0x%08X\n", (unsigned int)pGtpPerStructPtr);
	
	return 0;
}

void gtpmem_close()
{
	if(pGtp)
	{
		munmap(pGtp, 0x10000);
		close(fdGtpMem);

		pGtp = NULL;
		pGtpPerStructPtr = NULL;
	}
}

int main(int argc, char *argv[])
{
	if(signal(SIGINT, sig_handler) == SIG_ERR)
	{
		perror("signal");
		exit(0);
	}
	
	pthread_mutex_init(&mutexRegisterAccess, NULL);
	
	gtpmem_open();
	
// Run socket server
	gCrateServerCBFcn.Read16 = NULL;
	gCrateServerCBFcn.Write16 = NULL;
	gCrateServerCBFcn.Read32 = Gtp_Read32;
	gCrateServerCBFcn.Write32 = Gtp_Write32;
	gCrateServerCBFcn.Delay = Gtp_Delay;
	gCrateServerCBFcn.ReadScalers = Gtp_ReadScalers;
	
	printf("Starting CrateMsgServer...\n");
	CrateMsgServerStart(&gCrateServerCBFcn, CRATEMSG_LISTEN_PORT);

	GtpPrintVersion();
	GtpSetHostname();
	GtpSetLed(LED_AMBER);
	
	while(1)
	{
		sleep(1);
		//GtpPollScalers();
	}
	
	GtpClearLed(LED_AMBER);
	
	gtpmem_close();
	pthread_mutex_destroy(&mutexRegisterAccess);
	
	return 0;
}

void closeup()
{
	GtpClearLed(LED_AMBER);
	
	gtpmem_close();
	pthread_mutex_destroy(&mutexRegisterAccess);
	printf("GTP server closed...\n");
}

void sig_handler(int signo)
{
	printf("%s: signo = %d\n",__FUNCTION__,signo);
	switch(signo)
	{
		case SIGINT:
			closeup();
			exit(1);  /* exit if CRTL/C is issued */
	}
}
