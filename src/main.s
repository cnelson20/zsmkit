.include "x16.inc"

.segment "LOADADDR"
.word $0801

.segment "BASICSTUB"
.word entry-2
.byte $00,$00,$9e
.byte "2061"
.byte $00,$00,$00
.proc entry
	jmp main
.endproc

.scope zsmkit
.include "zsmkit.inc"
.endscope

.segment "BSS"
oldirq:
	.res 2

.segment "STARTUP"

.proc main
	lda #1
	jsr zsmkit::init_engine

	jsr setup_handler

	lda #<filename
	ldy #>filename
	ldx #0
	jsr zsmkit::zsm_setfile
	jsr zsmkit::zsm_fill_buffers
	jsr zsmkit::zsm_fill_buffers
	ldx #0
	jsr zsmkit::zsm_play

loop:
	wai
	jsr zsmkit::zsm_fill_buffers
	bra loop
filename:
	.byte "LIVINGROCKS.ZSM",0
.endproc

.segment "CODE"

.proc setup_handler
	lda X16::Vec::IRQVec
	sta oldirq
	lda X16::Vec::IRQVec+1
	sta oldirq+1

	sei
	lda #<irqhandler
	sta X16::Vec::IRQVec
	lda #>irqhandler
	sta X16::Vec::IRQVec+1
	cli

	rts
.endproc

.proc irqhandler
	jsr zsmkit::zsm_tick
	jmp (oldirq)
.endproc