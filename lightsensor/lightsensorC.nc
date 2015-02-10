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
 *
ing demo application. See README.txt file in this directory for usage
 * instructions and have a look at tinyos-2.x/doc/html/tutorial/lesson5.html
 * for a general tutorial on sensing in TinyOS.
 *
 * @author Jan Hauer
 */

#include "Timer.h"

module lightsensorC
{
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli>;
  uses interface Read<uint16_t>;
  uses interface Mts300Sounder;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation
{
    // sampling frequency in binary milliseconds
    #define SAMPLING_FREQUENCY 1000
    message_t pkt;
    bool busy = FALSE;

    event void Boot.booted() {
        call Timer.startPeriodic(SAMPLING_FREQUENCY);
        call AMControl.start();
    }

    event void Timer.fired(){
        call Read.read();
    }

    event void Read.readDone(error_t result, uint16_t data){
        call Leds.led0On();
        if(data <600 ){
            call Leds.led2On();
            if (!busy) {
                hophophopMsg* btrpkt = (hophophopMsg*)(call Packet.getPayload(&pkt, sizeof(hophophopMsg)));
                call Leds.led1On();
                if (btrpkt == NULL)
                    return;

                btrpkt->nodeid = TOS_NODE_ID;
                btrpkt->data = data;

                if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(hophophopMsg)) == SUCCESS)
                    busy = TRUE;
            }
        }
    }

    event void AMSend.sendDone(message_t* msg, error_t err) {
        call Leds.led2Off();
        call Leds.led1Off();
        if (&pkt == msg)
            busy = FALSE;
    }

    event void AMControl.startDone(error_t err) {
    }

    event void AMControl.stopDone(error_t err) {
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
        return NULL;
    }
}
