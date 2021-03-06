/*
 * Copyright (c) 2006, Technische Universitaet Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Technische Universitaet Berlin nor the names
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Revision -------------------------------------------------------------
 * $Revision: 1.4 $
 * $Date: 2006-12-12 18:22:49 $
 * @author: Jan Hauer
 * ========================================================================
 */

/**
 * 
 * Sensing demo application. See README.txt file in this directory for usage
 * instructions and have a look at tinyos-2.x/doc/html/tutorial/lesson5.html
 * for a general tutorial on sensing in TinyOS.
 *
 * @author Jan Hauer
 */

#include "Timer.h"

module hophophopC
{
  uses {
    interface Boot;
    interface Leds;
    interface Mts300Sounder;
    interface Packet;
    interface AMPacket;
    interface AMSend;
    interface Receive;
    interface SplitControl as AMControl;

  }
}
implementation
{
  uint16_t count;
  bool busy = FALSE;
  message_t pkt;
  // sampling frequency in binary milliseconds
  #define SAMPLING_FREQUENCY 100
  
  event void Boot.booted() {
    call AMControl.start();
    call Leds.led0On();
  }



  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
     
   
    if (len == sizeof(hophophopMsg)) {
     
      hophophopMsg* btrpkt = (hophophopMsg*)payload;
      if(btrpkt->nodeid == 1)
      {
        switch(count)
        {
          case 4:
          call Leds.led1On();
          call Leds.led2Off();
          break;

          case 1:
          call Leds.led1On();
          call Leds.led2On();
          break;

          case 2:
          call Leds.led2On();
          call Leds.led1Off();
          break;

          case 3:
          call Leds.led1Off();
          call Leds.led2Off();
          count = 0;
          break;


          }
        count++;
        call Mts300Sounder.beep(10);
      btrpkt->nodeid = TOS_NODE_ID;
      if (!busy) {
        if (call AMSend.send(3, &pkt, sizeof(hophophopMsg)) == SUCCESS) 
          busy = TRUE;
                  }
      }
        
    }  
    return msg;
  }




  event void AMControl.startDone(error_t err) {
  }

  event void AMControl.stopDone(error_t err) {
  }


  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) 
      busy = FALSE;
    }

  
}
