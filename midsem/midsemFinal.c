/*Kalpesh Patil (130040019)
  EE 337 lab midsem exam */
	
/* @section  I N C L U D E S */
#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port
#define Vref 3.3     							  //3.3 is used as Vref and ratios are calculated accordingly

//Required functions

void SPI_Init();
void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);


sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag
sbit ONULL = P1^0;
bit transmit_completed= 0;					// To check if spi data transmit is complete
bit offset_null = 0;								// Check if offset nulling is enabled
bit roundoff = 0;
int adcVal=0;

unsigned char serial_data;
unsigned char data_save_high;
unsigned char data_save_low;

int temp1 = 0;      //10's place value of temperature
int	temp2 = 0;      //unit place value of temperature
int temp3 = 0;      //first decimal place value of temperature
int datatemp;       //temparary variable to store data of ADC

/**

 * FUNCTION_INPUTS:  P1.5(MISO) serial input  
 * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
 *                   P1.4(SSbar)
                     P1.6(SCK)
 */

void main(){
	P3 = 0X00;											// Make Port 3 output 
	P2 = 0x00;											// Make Port 2 output 
	P1 &= 0xEF;											// Make P1 Pin4 output
	P0 &= 0xF0;											// Make Port 0 Pins 0,1,2 output
	
	SPI_Init();
	LCD_Init();
	
	
	while(1)												// endless 
	{// read value from ADC and store it in adcVal
		
		CS_BAR = 0;                 // enable ADC as slave		 
		SPDAT= 0x01;								// Write start bit to start ADC 
		while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 
		transmit_completed = 0;    	// clear software transfert flag 
		
		SPDAT= 0x80;				// 80H written to start ADC CH0 single ended sampling
		while(!transmit_completed);	// wait end of transmition 
		data_save_high = serial_data & 0x03 ;  
		transmit_completed = 0;    	// clear software transfer flag 
				
		SPDAT= 0x00;								// 
		while(!transmit_completed);	// wait end of transmition 
		data_save_low = serial_data;
		transmit_completed = 0;    	// clear software transfer flag 
		CS_BAR = 1;                	// disable ADC as slave
		
		adcVal = (data_save_high <<8) + (data_save_low);
	
  
	//writing value to LCD
	
	LCD_CmdWrite(0x80);
	
	datatemp = adcVal;
	datatemp = datatemp*100;
	datatemp = datatemp/31;        						//31 factor from the calculation bu considering Vref
	
	temp1 = datatemp/100; 										//10's place 
	LCD_DataWrite((unsigned char)temp1 + '0');
	
	datatemp = datatemp%100;    							
	temp2 = datatemp/10;											//unit's place
	LCD_DataWrite((unsigned char)temp2 + '0');
	
	
	
	datatemp = datatemp%10;
	temp3 = datatemp;													//first decimal value
	LCD_StringWrite(".",1);
	LCD_DataWrite((unsigned char)temp3 + '0');
	
	delay_ms(5000);													  //delay of 5 seconds 
																						//value will be read only after 5 sec interval
	
}
}

/**
 * FUNCTION_PURPOSE:interrupt
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: transmit_complete is software transfert flag
 */
void it_SPI(void) interrupt 9 /* interrupt address is 0x004B */
{
	switch	( SPSTA )         /* read and clear spi status register */
	{
		case 0x80:	
			serial_data=SPDAT;   /* read receive data */
      transmit_completed=1;/* set software flag */
 		break;

		case 0x10:
         /* put here for mode fault tasking */	
		break;
	
		case 0x40:
         /* put here for overrun tasking */	
		break;
	}
}



//default functions of LCD and SPI 

void SPI_Init()
{
	CS_BAR = 1;	                  	// DISABLE ADC SLAVE SELECT-CS 
	SPCON |= 0x20;               	 	// P1.1(SSBAR) is available as standard I/O pin 
	SPCON |= 0x01;                	// Fclk Periph/4 AND Fclk Periph=12MHz ,HENCE SCK IE. BAUD RATE=3000KHz 
	SPCON |= 0x10;               	 	// Master mode 
	SPCON &= ~0x08;               	// CPOL=0; transmit mode example|| SCK is 0 at idle state
	SPCON |= 0x04;                	// CPHA=1; transmit mode example 
	IEN1 |= 0x04;                	 	// enable spi interrupt 
	EA=1;                         	// enable interrupts 
	SPCON |= 0x40;                	// run spi;ENABLE SPI INTERFACE SPEN= 1 
}
	/**
 * FUNCTION_PURPOSE:Timer Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */


	/**
 * FUNCTION_PURPOSE:LCD Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Init()
{
  sdelay(100);
  LCD_CmdWrite(0x38);   	// LCD 2lines, 5*7 matrix
  LCD_CmdWrite(0x0E);			// Display ON cursor ON  Blinking off
  LCD_CmdWrite(0x01);			// Clear the LCD
  LCD_CmdWrite(0x80);			// Cursor to First line First Position
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: cmd- command to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_CmdWrite(char cmd)
{
	LCD_Ready();
	LCD_data=cmd;     			// Send the command to LCD
	LCD_rs=0;         	 		// Select the Command Register by pulling LCD_rs LOW
  LCD_rw=0;          			// Select the Write Operation  by pulling RW LOW
  LCD_en=1;          			// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: dat- data to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_DataWrite( char dat)
{
	LCD_Ready();
  LCD_data=dat;	   				// Send the data to LCD
  LCD_rs=1;	   						// Select the Data Register by pulling LCD_rs HIGH
  LCD_rw=0;    	     			// Select the Write Operation by pulling RW LOW
  LCD_en=1;	   						// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}
/**
 * FUNCTION_PURPOSE: Write a string on the LCD Screen
 * FUNCTION_INPUTS: 1. str - pointer to the string to be written, 
										2. length - length of the array
 * FUNCTION_OUTPUTS: none
 */
void LCD_StringWrite( char * str, unsigned char length)
{
    while(length>0)
    {
        LCD_DataWrite(*str);
        str++;
        length--;
    }
}

/**
 * FUNCTION_PURPOSE: To check if the LCD is ready to communicate
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Ready()
{
	LCD_data = 0xFF;
	LCD_rs = 0;
	LCD_rw = 1;
	LCD_en = 0;
	sdelay(5);
	LCD_en = 1;
	while(LCD_busy == 1)
	{
		LCD_en = 0;
		LCD_en = 1;
	}
	LCD_en = 0;
}

/**
 * FUNCTION_PURPOSE: A delay of 15us for a 24 MHz crystal
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
}

/**
 * FUNCTION_PURPOSE: A delay of around 1000us for a 24MHz crystel
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}