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
#include "gtp.h"

void sig_handler(int signo);

int fdGtpMem;
int *pGtp;
Gtp_regs *pGtpPerStructPtr;
pthread_mutex_t mutexRegisterAccess;

void Gtp_Lock(int lock)
{
	if(lock)
		pthread_mutex_lock(&mutexRegisterAccess);
	else
		pthread_mutex_unlock(&mutexRegisterAccess);
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
	int isr_num;
	volatile int len;
	
	if(signal(SIGINT, sig_handler) == SIG_ERR)
	{
		perror("signal");
		exit(0);
	}
	
	pthread_mutex_init(&mutexRegisterAccess, NULL);
	
	gtpmem_open();

	GtpPrintVersion();

printf("pGtpPerStructPtr->TiGtp.FifoLen @ 0x%08X\n", (int)&pGtpPerStructPtr->TiGtp.FifoLen);

printf("pGtpPerStructPtr->Cfg @ 0x%08X\n", (int)&pGtpPerStructPtr->Cfg);
printf("pGtpPerStructPtr->Clk @ 0x%08X\n", (int)&pGtpPerStructPtr->Clk);
printf("pGtpPerStructPtr->Sd @ 0x%08X\n", (int)&pGtpPerStructPtr->Sd);
printf("pGtpPerStructPtr->La @ 0x%08X\n", (int)&pGtpPerStructPtr->La);
printf("pGtpPerStructPtr->GxbCfgOdd @ 0x%08X\n", (int)&pGtpPerStructPtr->GxbCfgOdd);
printf("pGtpPerStructPtr->GxbCfgEven @ 0x%08X\n", (int)&pGtpPerStructPtr->GxbCfgEven);
printf("pGtpPerStructPtr->Ser[15] @ 0x%08X\n", (int)&pGtpPerStructPtr->Ser[15]);
printf("pGtpPerStructPtr->Trg @ 0x%08X\n", (int)&pGtpPerStructPtr->Trg);
printf("pGtpPerStructPtr->TiGtp @ 0x%08X\n", (int)&pGtpPerStructPtr->TiGtp);

	pGtpPerStructPtr->TiGtp.FifoCtrl = 0x1;
	pGtpPerStructPtr->TiGtp.FifoCtrl = 0x0;
	write(fdGtpMem, &isr_num, sizeof(isr_num));

	if(fdGtpMem >= 1)
	{
		while(1)
		{
		  sleep(1);
		  /*
			read(fdGtpMem, &isr_num, sizeof(isr_num));
			len = pGtpPerStructPtr->TiGtp.FifoLen;
			printf("len=%d\n",len);fflush(stdout);
			write(fdGtpMem, &isr_num, sizeof(isr_num));
		  */
		}
	}
	
	gtpmem_close();
	pthread_mutex_destroy(&mutexRegisterAccess);
	
	return 0;
}

void closeup()
{
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