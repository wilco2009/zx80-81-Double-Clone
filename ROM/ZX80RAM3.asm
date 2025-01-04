; 1, 2, 3, 4 and 16kb RAM test for Sinclair ZX-80 computer
; (c) 7.2013 Louis Seidelmann

; program to burn into 2716 EPROM

; intercell leakage, address mirror test
; slow refresh test (16kB pack case)
; M1 fetch fast RAM access test

; =============================================================================================

; begin after reset
		org	0x0000

; fast mode setup in the case slow mode hardware is present
		out	(0xfd),a

; interrupt mode 1 setup
		IM	1

; display character generator high Byte address set
menuprep:	ld	a,0x07
		ld	i,a

; menu - choose test
menurep:	ld	ix,chramtstscr
		jr	screnter

; ---------------------------------------------------------------------------------------------

; menu - choose RAM
scrctstend:	ld	c,a
		xor	0x18
		cpl

; both 6 and 7 key pressed error test
		jr	z,menurep
		rlca
		rlca
		ld	ix,menuscr
		jr	screnter

; =============================================================================================

; "@ fetch M1"
mm1fe:		db	0x11, 0x12, 0x7f, 0x2f, 0x2d, 0x2c, 0x26, 0x25
		db	0x7f, 0x2b, 0x39
		halt

; "@ 17 code read"
mcre17:		db	0x11, 0x12, 0x7f, 0x39, 0x3f, 0x7f, 0x26, 0x30
		db	0x33, 0x2d, 0x7f, 0x34, 0x2d, 0x22, 0x33
		halt

; =============================================================================================

; INT IM1
		org	0x0038		; 13 clk interrupt entrance

; screen generator interrupt
; 207 clk total per line, resp. 828 clk per vertical fourline sync
; 207 = 13 + n + 4* (0x01 - r)
; n - total nb. ot instruction cycles from 0x0038 address to ld r,a (include)
; r - vallue in reg. a before ld r,a

		dec	e		; 4 clk
		jp	nz,scrilin	; 10 clk
		pop	de		; 10 clk
		pop	hl		; 10 clk
		pop	af		; 10 clk
scrilout:	and	c		; 4 clk
		jp	z,scrinh	; 10 clk
		ld	a,0xe3		; 7 clk
		ld	r,a		; 9 clk
		ei			; 4 clk
		jp	(hl)		; 4 clk

scr524:		ld	d,0x1d		; 7 clk NTSC frame setup
		ld	e,0x28		; 7 clk NTSC frame setup
scr628:		ex	af,af'		; 4 clk
		ld	a,d		; 4 clk
		ex	af,af'		; 4 clk
		cpl			; 4 clk
		and	l		; 4 clk
		inc	hl		; 6 clk (delay)
		inc	hl		; 6 clk (delay)
		inc	hl		; 6 clk (delay)
		out	(0xff),a	; 11 clk switch a vertical sync off
		jr	z,scrrep	; 7/12 clk
		exx
		ret			; jump to address on screen program bottom

scrrep:		ld	sp,ix		; 10 clk
		xor	a		; 4 clk
		ex	af,af'		; 4 clk
scrbott:	ex	af,af'		; 4 clk
scrinh:		add	0xe3		; 7 clk
scrrreld:	ld	r,a		; 9 clk
		ei			; 4 clk
		halt			; 4 clk

; =============================================================================================

; NMI
		org	0x0066

		rst	0x0000

; =============================================================================================

; SP/CR break test
scrmerrend:	jr	nz,menurep	; 7/12 clk

; total error test
		ld	a,(iy + mode1tblb - mode1tbla)	; 19 clk
		cp	c		; 4 clk
		jr	nz,lttopini	; 7/12 clk

; RAM select run screen
scrramsel:	ld	ix,runscr	; 14 clk
		ld	b,0x07		; 7 clk
		ld	a,(iy)		; 19 clk

; =============================================================================================

; part of an interrupt screen generator

; screen output enter point
; screen program address in ix, print filter bitmap in a - active high
; return address contained in screen program
; filtered keyboard output to a, zerro flag if no key pressed (timeout expired)
; using hidden registers, save bc, de, hl

screntsync:	djnz	screntsync	; 8/13 clk
screnter:	exx			; 4 clk
		ld	c,a		; 4 clk message line filter load
		ld	b,(ix-3)	; 19 clk load frame cycles timeout 1-256
		ld	hl,0x0000	; 10 clk must be 0x21, 0x00, 0x00 (nop)
scrfrl:		nop			; 4 clk
		ld	d,0x01		; 7 clk PAL frame setup
		ld	a,h		; 4 clk
		in	a,(0xfe)	; 11 clk switch a vertical sync on
		ld	e,0x1c		; 7 clk
vsyncl:		dec	e		; 4 ... 28*4= 120 clk
		jr	nz,vsyncl	; 12 ... 27*12+7= 353 clk
		bit	6,a		; 8 clk
		jr	z,scr524	; 7/12 clk
		ld	e,0x40		; 7 clk PAL frame setup
		jr	scr628		; 12 clk

scrilin:	pop	af		; 10 clk
		nop			; 4 clk
		nop			; 4 clk
		jr	nc,scrilout	; 7/12 clk
		ld	a,0x03		; 7 clk
		ex	af,af'		; 4 clk
		cp	e		; 4 clk
		jr	nz,scrbott	; 7/12 clk
		ex	af,af'		; 4 clk
		jr	nz,scrfrl - 2	; 7/12 clk jump to 0x00, 0x00 before scrfrl
		djnz	scrfrl		; 8/13 clk
		xor	a		; 4 clk
		exx			; 4 clk
		ret			; 10 clk jump to address on screen program bottom

; =============================================================================================

menrunstep:	di
		ld	hl,msepar + 0x8000
		ld	sp,menrunscr
scrarreld:	ld	a,0xf2
		jr	scrrreld

; ---------------------------------------------------------------------------------------------

; error indicator
scrrunendm:	or	c		; 4 clk
		jr	z,lttopini	; 7/12 clk

; error screen format choose
		ld	b,0x05		; 7 clk
		bit	7,(iy+1)
		jp	nz,testr16sw
		ld	ix,testres1234
		jr	screntsync	; 12 clk

; ---------------------------------------------------------------------------------------------

; RAM content validity set, old RAM byte test mode set
lttopini:	ld	a,d
		or	0x06
		ld	d,a

; new cycle top address set
		jr	ttopini

; ---------------------------------------------------------------------------------------------

; remark about d register bits using by RAMtest core:
; bit 0 one (0) or two (1) address bit test mode switch
; bit 1 used to switch between two different returns from RAM Byte calculate
; bit 2 RAM content validity flag (0 not valid, 1 valid)
; bit 3 must contain zero
; bit 4 used for RAM Byte content calculate by parity flag
; bit 5 must contain zero
; bit 6 not used
; bit 7 must contain zero
; cy -> bit 7 after "rr d" used for RAM Byte content calculate by parity flag

; rampack sellect by keys 1 - 5
scrmenend:	ld	iy,mode1tbla - (mode2tbla - mode1tbla)
		ld	de,mode2tbla - mode1tbla
menukl:		add	iy,de
		rra
		jr	nc,menukl
		and	a

; more keys test
		jr	nz,scrmerrend

; fetch / mosaic test sellect
		bit	4,c
		ld	l,a
		ld	c,a
		jp	nz,mfrtenter

; range set, cycle clear
		ld	d,a
		ld	e,0xfb

; start test cycle
ttopini:	ld	a,e
		rra
		rra
		rra
		rra
		xor	e
		and	0x06
		xor	e
		and	0x07
		exx
		ld	h,0x06
		ld	l,a
		ld	b,(hl)
		exx
		ld	a,c
		exx
		ld	e,a
		ld	c,0x00
		exx
		ld	c,l
		ld	a,h
		exx
		ld	d,a
		exx
		ld	h,(iy+1)
		jr	newaddr

; test and set cycle loop
; RAM content validity test
tscloop:	bit	2,d
		jr	z,newaddr

; old RAM Byte calculate setup
		ld	a,d
		xor	0x03
		ld	d,a
		rra
		ld	a,e
		sbc	0x00
		ld	e,a

; new address
newaddr:	dec	hl

; Byte content calculate
; bit 4 of e set to bit 4 of d
		ld	a,e
bconcalc:	xor	d
		and	0x10
		xor	d
		ld	d,a

; Byte content calculate - first address bit
; bits 0-2 of e to b
		ld	a,e
		and	0x07
		ld	b,a

; h or l depending on bit 3 of e
		ld	a,l
		bit	3,e
		jr	z,addrh0
		ld	a,h

; bit nb. b of h or l to cy
addrh0:		inc	b
addrl0:		rra
		djnz	addrl0
		ld	a,d
		rra
		ld	d,a
		jr	nc,oneaddr

; Byte content calculate - second address bit
; bits 5-7 of e shifted down to bits 0-2 of a; bit 3 of a set high
		ld	a,e
		scf
		rla
		rla
		rla
		rla

; add bits 0-3 of e and filtered write to b
		add	e
		and	0x0f
		ld	b,a

; h or l depending on bit 3 of b
		ld	a,l
		bit	3,b
		jr	z,addrh1
		ld	a,h

; reg. b bits 0-2 filter
		res	3,b

; bit nb. b of h or l to cy
addrh1:		inc	b
addrl1:		rra
		djnz	addrl1
		ld	a,d
		rra
		scf
oneaddr:	rl	d
		and	0xcc
		ld	a,b
		jp	pe,bcpeven
		cpl
bcpeven:	bit	1,d
		exx
		jr	z,newend

; old RAM content Byte test
		xor	d
		exx
		xor	(hl)
		or	c
		ld	c,a

; new RAM Byte calculate
nbcalc:		ld	a,d
		xor	0x03
		ld	d,a
		rra
		ld	a,e
		sbc	0xff
		ld	e,a

; new RAM content Byte set
		jr	bconcalc

; new RAM content write
newend:		xor	b
		exx
		ld	(hl),a

; RAM 1kB block end test
		ld	a,h
		and	0x03
		or	l
stscloop:	jp	nz,tscloop

; RAM technology switch
		bit	7,(iy+1)
		jr	nz,rfshw

; 4-bit RAM chip indicator
		ld	a,c
		rrca
		or	c
		rrca
		or	c
		rrca
		or	c
		and	0x88
		exx
		or	c
		rlca
		ld	c,a
		exx
		ld	c,b

; end cycle test
rfshwend:	ld	a,h
		xor	0x40
		jr	nz,stscloop

; error indicator modes or
		exx
		ld	a,e
		or	c
		exx
		or	c
		ld	c,a

; bit mosaic save to h
		exx
		ld	a,b
		exx
		ld	h,a

; runing indicator
		bit	2,d
		jp	z,lttopini
		jp	scrramsel

; slow refresh test if DRAM (16kB) case
rfshw:		ld	sp,0x4000
rfshloopa:	call	rfshp0a
rfshp0a:	call	rfshp1a
rfshp1a:	call	rfshp2a
rfshp2a:	call	rfshp3a
rfshp3a:	djnz	rfshloopa
rfshloopb:	call	rfshp0b
rfshp0b:	call	rfshp1b
rfshp1b:	call	rfshp2b
rfshp2b:	call	rfshp3b
rfshp3b:	djnz	rfshloopb
		jr	rfshwend

; ---------------------------------------------------------------------------------------------

; RAM preset by 0xc9 ret opcode before M1 fetch test
mfrtenter:	ld	h,0x40
		ld	de,0x4001
		ld	(hl),0xc9	; 10 clk opcode ret
		ld	a,(iy+1)
		sub	h
		ld	b,a
		dec	bc
		ldir

; fetch enter registers preset
mfcycent:	ld	a,h		; 4 clk
		exx			; 4 clk
		ld	h,a		; 4 clk
		ld	l,0xff		; 7 clk

; preset 256 test cycle and 10* fetch between ld r,a and ld a,r
		ld	bc,0x0f00	; 10 clk

; preset opcode rla, ret pe
		ld	de,0xe817	; 10 clk

; last address test
		inc	a		; 4 clk
		xor	(iy+1)		; 19 clk
		jr	nz,mftloop	; 7/12 clk

; new cycle preset
		cpl			; 4 clk (delay)
		exx			; 4 clk
		nop			; 4 clk (delay)
		in	a,(0xfe)	; 11 clk
		dec	sp		; 6 clk (delay)
		out	(0xff),a	; 11 clk
		ld	d,0x01		; 7 clk
		exx			; 4 clk
		ld	hl,0x4000	; 10 clk
		ld	(hl),0xe8	; 10 clk
		ld	a,d		; 4 clk
		xor	(hl)		; 7 clk
		jr	nz,ramend0	; 7/12 clk
		ld	r,a		; 9 clk
		ld	sp,ramretsp1	; 10 clk
		or	e		; 4 clk set p, nz, pe, reset cy
		nop			; 4 clk (delay)
		jp	testm + 0x8000	; 10 clk

; code e8 read error at 0x4000 way
ramend0:	ret	z		; 5(/11) clk (delay)
		ld	sp,ramretsp3	; 10 clk
		ld	a,0x3f		; 7 clk
		jp	testm1 + 0x8000	; 10 clk

ramret3:	jp	ramret5		; 10 clk

ramret2:	inc	hl		; 6 clk
		nop			; 4 clk (delay)
ramret5:	exx			; 4 clk
		or	b		; 4 clk
		ld	b,a		; 4 clk
		exx			; 4 clk
		ld	a,0xff		; 7 clk (delay)
		jr	emftlpt		; 12 clk

ramret1:	jp	ramret4		; 10 clk (delay)

ramret:		inc	hl		; 6 clk
ramret4:	sbc	e		; 4 clk
		jr	nz,ramendr	; 7/12 clk
		ld	a,r		; 9 clk
		cp	b		; 4 clk
		jr	nz,ramendr	; 7/12 clk
emftlpt:	dec	c		; 4 clk
		jp	z,rmftlend	; 10 clk
mftloop:	ld	(hl),e		; 7 clk
		in	a,(0xfe)	; 11 clk
		inc	hl		; 6 clk
		out	(0xff),a	; 11 clk
		ld	(hl),d		; 7 clk
		ld	a,d		; 4 clk
		xor	(hl)		; 7 clk
		jr	nz,ramend1	; 7/12 clk
		dec	hl		; 6 clk
		ld	a,e		; 4 clk
		xor	(hl)		; 7 clk
		jr	nz,ramend2	; 7/12 clk
		ld	sp,ramretsp	; 10 clk
		ld	r,a		; 9 clk
		or	e		; 4 clk set p, nz, pe, reset cy
		rra			; 4 clk set cy
		jp	testm + 0x8000	; 10 clk

; code e8 read error way
ramend1:	dec	hl		; 6 clk
		ld	a,(hl)		; 7 clk
		xor	e		; 4 clk
		jr	nz,ramend3	; 7/12 clk
		ret	nz		; 5(/11) clk (delay)
		ld	sp,ramretsp2	; 10 clk
		ld	a,0x3f		; 7 clk
		jp	testm1 + 0x8000	; 10 clk

; code 17 read error way
ramend2:	ret	z		; 5(/11) clk (delay)
		ld	sp,ramretsp2	; 10 clk
		ld	a,0x5f		; 7 clk
		jp	testm2 + 0x8000	; 10 clk

; code e8 and 17 read error way
ramend3:	ld	sp,ramretsp2	; 10 clk
		ld	a,0x7f		; 7 clk
		jp	testm3 + 0x8000	; 10 clk

; fetch error flag setup
ramendr:	exx
		set	7,b
		ld	c,l
		exx
		jr	rmfntsc0

testm:		db	0x39, 0x39, 0x39, 0x39	; "||||" 4*4=16 clk
		jp	(hl)		; 4 + (4+11) clk

testm1:		db	0x39, 0x39, 0x0f, 0x0f	; "||##" 4*4=16 clk
		ret	nc		; 11 clk

testm2:		db	0x0f, 0x0f, 0x39, 0x39	; "##||" 4*4=16 clk
		ret	nc		; 11 clk

testm3:		db	0x0f, 0x0f, 0x0f, 0x0f	; "####" 4*4=16 clk
		ret	nc		; 11 clk

; RAM fetch test frame end
rmftlend:	ld	a,0xff		; 7 clk (delay)
		in	a,(0xfe)	; 11 clk
		dec	sp		; 6 clk (delay)
		out	(0xff),a	; 11 clk

; space after picture frame before vertical sync 0 NTSC /20 PAL lines
		ld	c,0x14		; 7 clk
		rla			; 4 clk
		rla			; 4 clk
		jr	nc,rmfntsc0	; 7/12 clk
mfthpsync0:	ld	a,0x09		; 7 clk
mftpal0:	dec	a		; 9*4= 36 clk
		jr	nz,mftpal0	; 7+8*12= 103 clk
		nop			; 4 clk
		ld	a,0xff		; 7 clk (delay)
		in	a,(0xfe)	; 11 clk
		dec	sp		; 6 clk (delay)
		out	(0xff),a	; 11 clk
		inc	sp		; 6 clk (delay)
		dec	c		; 4 clk
		jr	nz,mfthpsync0	; 7/12 clk
		nop			; 4 clk (delay)
		inc	sp		; 6 clk (delay)
rmfntsc0:	ld	a,h		; 4 clk
		exx			; 4 clk
		ld	h,a		; 4 clk
		ld	a,d		; 4 clk
		or	0xe0		; 7 clk
		and	b		; 4 clk
		or	e		; 4 clk
		ld	e,a		; 4 clk
		ld	a,e		; 4 clk
		rla			; 4 clk
		or	a,e		; 4 clk
		rla			; 4 clk
		or	a,e		; 4 clk
		rla			; 4 clk
		or	a,e		; 4 clk
		rla			; 4 clk
		and	0x10		; 7 clk
		xor	0xf0		; 7 clk
		or	e		; 4 clk
		xor	0xf0		; 7 clk
		and	(iy + mode1tblb - mode1tbla + 1)	; 19 clk
		xor	e		; 4 clk
		ld	e,a		; 4 clk
		ld	a,h		; 4 clk
		and	0xf3		; 7 clk
		xor	0x43		; 7 clk
		nop			; 4 clk (delay)
		ex	af,af'		; 4 clk
		ld	a,0x3f		; 7 clk keyboard row filter hjklCR bnm.SP
		in	a,(0xfe)	; 11 clk
		dec	sp		; 6 clk (delay)
		out	(0xff),a	; 11 clk
		rra			; 4 clk

; SP/CR break test
		jp	nc,menuprep	; 10 clk
		ex	af,af'		; 4 clk
		sub	0x01		; 7 clk
		sbc	a		; 4 clk
		and	d		; 4 clk
		add	d		; 4 clk
		ld	d,a		; 4 clk
		inc	c		; 4 clk
		jr	z,rmftncyco	; 7/12 clk
		ld	b,0x1f		; 7 clk
rmftncyci:	in	a,(0xfe)	; 11 clk
rmfvsync:	nop			; 31*4= 124 clk (delay)
		djnz	rmfvsync	; 8+30*13= 398 clk
		rla			; 4 clk

; space after vertical sync before picture frame 1 NTSC /33 PAL lines
		ld	b,0x21		; 7 clk
		add	0x80		; 7 clk
		out	(0xff),a	; 11 clk
		jr	nc,mfthpsync2	; 7/12 clk
		jr	mfthpsync1	; 12 clk

mfthpsync2:	ld	b,0x01		; 7 clk
mfthpsync1:	ld	a,0x09		; 7 clk
mftpal:		dec	a		; 9*4= 36 clk
		jr	nz,mftpal	; 7+8*12= 103 clk
		ld	sp,hl		; 6 clk (delay)
		nop			; 4 clk (delay)
		nop			; 4 clk (delay)
		in	a,(0xfe)	; 11 clk
		dec	sp		; 6 clk (delay)
		out	(0xff),a	; 11 clk
		inc	sp		; 6 clk (delay)
		djnz	mfthpsync1	; 8/13 clk
		ld	b,0x04		; 7 clk
mftlhsd:	ret	nz		; 4*5(/11)= 20 clk
		djnz	mftlhsd		; 8+3*13= 47 clk
		jp	mfcycent	; 10 clk

rmftncyco:	ld	b,0x09
rmftncycor:	ld	ix,runscr
		ld	a,(iy)
		xor	0x60
		jr	lscrentsync

; SP/CR break test
scrrunend:	jp	nz,menurep	; 10 clk
		or	l		; 4 clk
		jp	z,scrrunendm	; 10 clk
		and	e		; 4 clk
		ld	b,0x1d		; 7 clk
		jr	z,rmftncyci	; 7/12 clk
		ld	ix,testfres	; 14 clk
		ld	b,0x06
		jr	lscrentsync

; SP/CR break test
scrferrend:	jr	nz,scrrunend	; 7/12 clk
		bit	7,e		; 8 clk
		ld	b,0x1e		; 7 clk
		jr	z,rmftncyci	; 7/12 clk
		ld	b,0x04		; 7 clk
		jr	rmftncycor	; 12 clk

; ---------------------------------------------------------------------------------------------

testr16sw:	ld	ix,testres16
lscrentsync:	jp	screntsync
		
; =============================================================================================

; choose RAM test
		dw	0x0008
chramtstscr:	dw	mcrtest + 0x8000
		db	0x04, 0xff
		dw	msepar + 0x8000
		db	0x08, 0xff
		dw	logo + 0x8000
		db	0x20, 0xff

; up down button border - fill empty 2B space
mudbb:		db	0x0f
		halt

		dw	0x0004
		dw	mudbb + 0x8000
		db	0x08, 0xff
		dw	m7mosaic + 0x8000
		db	0x04, 0xff
		dw	mudbb + 0x8000
		db	0x28, 0xff
		dw	0x0000, 0x0004
		dw	mudbb + 0x8000
		db	0x08, 0xff
		dw	m6fetch + 0x8000
		db	0x04, 0xff
		dw	mudbb + 0x8000
		db	0x7c, 0xff
		db	0x18		; keyboard column filter 67
		db	0xef		; keyboard row filter 67890
		db	0x01		; no timeout, bottom border
		db	0x00		; line address inhibit
		dw	scrctstend

; screen program RAM tested
; a = %0fmxxxxx

		db	0x64		; 2s timeout (PAL)
		dw	0x0008
runscr:		dw	mrtested + 0x8000
		db	0x04, 0xff
		dw	menrunstep
		db	0x00, 0xff

; ---------------------------------------------------------------------------------------------

; screen program menu
; a = %1fm11111

		dw	0x0008
menuscr:	dw	mrtest + 0x8000
		db	0x04, 0xff
		dw	msepar + 0x8000
		db	0x08, 0xff
menrunscr:	dw	logo + 0x8000
		db	0x20, 0xff
		dw	0x0000, 0x0004
		dw	mudbb + 0x8000
		db	0x08, 0x01
		dw	m1kb + 0x8000
		db	0x04, 0x01
		dw	mudbb + 0x8000
		db	0x04, 0x01
		dw	mudbb + 0x8000
		db	0x08, 0x02
		dw	m2kb + 0x8000
		db	0x04, 0x02
		dw	mudbb + 0x8000
		db	0x04, 0x02
		dw	mudbb + 0x8000
		db	0x08, 0x04
		dw	m3kb + 0x8000
		db	0x04, 0x04
		dw	mudbb + 0x8000
		db	0x04, 0x04
		dw	mudbb + 0x8000
		db	0x08, 0x08
		dw	m4kb + 0x8000
		db	0x04, 0x08
		dw	mudbb + 0x8000
		db	0x04, 0x08
		dw	mudbb + 0x8000
		db	0x08, 0x10
		dw	m16kb + 0x8000
		db	0x04, 0x10
		dw	mudbb + 0x8000
		db	0x24, 0x10
		dw	0x0000, 0x0008
		dw	mfetch + 0x8000
		db	0x08, 0x40
		dw	mmosaic + 0x8000
		db	0x08, 0x20
		dw	mresifd + 0x8000
		db	0x08, 0x40
		dw	menuendsw
		db	0x30, 0x80
		db	0x01		; keyboard column filter CR SP
		db	0x3f		; keyboard row filter hjklCR bnm.SP
		db	0x41		; timeout, bottom border
		db	0x00		; line address inhibit
		dw	scrrunend

menuendsw:	di
		ld	sp,menuendstep
		jp	scrarreld

		db	0x30, 0x00
menuendstep:	db	0x1f		; keyboard column filter 12345
		db	0xf7		; keyboard row filter 12345
		db	0x01		; no timeout, bottom border
		db	0x00		; line address inhibit
		dw	scrmenend

; screen program 1 - 4kB RAM result

		db	0x7d		; 2.5s timeout (PAL)
		dw	0x0008
testres1234:	dw	mmerf + 0x8000
		db	0x04, 0xff
		dw	msepar + 0x8000
		db	0x08, 0xff
		dw	logo + 0x8000
		db	0x08, 0xff
		dw	0x0000, 0x0004
		dw	msepar + 0x8000
		db	0x08, 0x0f
		dw	mbit7102 + 0x8000
		db	0x08, 0x0f

; return address preset - fill empty 2B space
ramretsp:	dw	ramret

		dw	0x0008
		dw	mset0 + 0x8000
		db	0x08, 0x01

; return address preset - fill empty 2B space
ramretsp1:	dw	ramret1

		dw	0x0008
		dw	mset1 + 0x8000
		db	0x08, 0x02

; return address preset - fill empty 2B space
ramretsp2:	dw	ramret2

		dw	0x0008
		dw	mset2 + 0x8000
		db	0x08, 0x04

; return address preset - fill empty 2B space
ramretsp3:	dw	ramret3

		dw	0x0008
		dw	mset3 + 0x8000
		db	0x04, 0x08
		dw	0x0000, 0x0004
		dw	msepar + 0x8000
		db	0x08, 0xff
		dw	mbit4356 + 0x8000
		db	0x08, 0xf0
		dw	0x0000, 0x0008
		dw	mset0 + 0x8000
		db	0x08, 0x10
		dw	0x0000, 0x0008
		dw	mset1 + 0x8000
		db	0x08, 0x20
		dw	0x0000, 0x0008
		dw	mset2 + 0x8000
		db	0x08, 0x40
		dw	0x0000, 0x0008
		dw	mset3 + 0x8000
		db	0x04, 0x80
		dw	0x0000, 0x0004
		dw	msepar + 0x8000
		db	0x38, 0xf0
		db	0x01		; keyboard column filter CR SP
		db	0x3f		; keyboard row filter hjklCR bnm.SP
		db	0x41		; timeout, bottom border
		db	0x00		; line address inhibit
		dw	scrmerrend

; screen program 16kB RAM result

		db	0xfa		; 5s timeout (PAL)
		dw	0x0008
testres16:	dw	mmerf + 0x8000
		db	0x04, 0xff
		dw	msepar + 0x8000
		db	0x08, 0xff
		dw	logo + 0x8000
		db	0x14, 0xff

; control table - fill empty 2B space
mode1tbla:	db	0x21
		db	0x44

		dw	0x0008
		dw	mbits + 0x8000
		db	0x10, 0xff

; control table - fill empty 2B space
mode2tbla:	db	0x22
		db	0x48

		dw	0x0008
		dw	mbit0 + 0x8000
		db	0x08, 0x01

; control table - fill empty 2B space
mode3tbla:	db	0x24
		db	0x4c

		dw	0x0008
		dw	mbit1 + 0x8000
		db	0x08, 0x02

; control table - fill empty 2B space
mode4tbla:	db	0x28
		db	0x50

		dw	0x0008
		dw	mbit2 + 0x8000
		db	0x08, 0x04

; control table - fill empty 2B space
mode16tbla:	db	0x30
		db	0x80

		dw	0x0008
		dw	mbit3 + 0x8000
		db	0x08, 0x08
		dw	0x0000, 0x0008
		dw	mbit4 + 0x8000
		db	0x08, 0x10
		dw	0x0000, 0x0008
		dw	mbit5 + 0x8000
		db	0x08, 0x20
		dw	0x0000, 0x0008
		dw	mbit6 + 0x8000
		db	0x08, 0x40
		dw	0x0000, 0x0008
		dw	mbit7 + 0x8000
		db	0x40, 0x80
		db	0x01		; keyboard column filter CR SP
		db	0x3f		; keyboard row filter hjklCR bnm.SP
		db	0x41		; timeout, bottom border
		db	0x00		; line address inhibit
		dw	scrmerrend

; screen program fetch result

		db	0x7d		; 2.5s timeout (PAL)
		dw	0x0008
testfres:	dw	mferf + 0x8000
		db	0x04, 0xff
		dw	msepar + 0x8000
		db	0x08, 0xff
		dw	logo + 0x8000
		db	0x24, 0xff
		dw	0x0000, 0x0008
		dw	mset0 + 0x8000
		db	0x08, 0x01
		dw	mset16 + 0x8000
		db	0x08, 0x10
		dw	mset1 + 0x8000
		db	0x08, 0x02

; control table - fill empty 2B space
mode1tblb:	db	0x11
		db	0x00

		dw	0x0008
		dw	mset2 + 0x8000
		db	0x08, 0x04

; control table - fill empty 2B space
mode2tblb:	db	0x33
		db	0x00

		dw	0x0008
		dw	mset3 + 0x8000
		db	0x20, 0x08

; control table - fill empty 2B space
mode3tblb:	db	0x77
		db	0x00

		dw	0x0008
		dw	mcre17 + 0x8000
		db	0x08, 0x40

; control table - fill empty 2B space
mode4tblb:	db	0xff
		db	0x00

		dw	0x0008
		dw	mcree8 + 0x8000
		db	0x08, 0x20

; control table - fill empty 2B space
mode16tblb:	db	0xff
		db	0xff

		dw	0x0008
		dw	mm1fe + 0x8000
		db	0x40, 0x80
		db	0x01		; keyboard column filter CR SP
		db	0x3f		; keyboard row filter hjklCR bnm.SP
		db	0x41		; timeout, bottom border
		db	0x00		; line address inhibit
		dw	scrferrend

; =============================================================================================

; "RAM tested"
mrtested:	db	0x29, 0x2a, 0x2b, 0x7f, 0x2c, 0x2d, 0x2e, 0x2c
		db	0x2d, 0x33
		halt

; "choose RAMtest:"
mcrtest:	db	0x26, 0x25, 0x30, 0x30, 0x2e, 0x2d, 0x7f, 0x29
		db	0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2c, 0x37
		halt

; "test RAM:"
mrtest:		db	0x2c, 0x2d, 0x2e, 0x2c, 0x7f, 0x29, 0x2a, 0x2b
		db	0x37
		halt

; "1 - 1k"
m1kb:		db	0xb9, 0x7f, 0x28, 0x7f, 0x39, 0x27
		halt

; "2 - 2k"
m2kb:		db	0xba, 0x7f, 0x28, 0x7f, 0x3a, 0x27
		halt

; "- restart if abort -"
mresifd:	db	0x28, 0x7f, 0x34, 0x2d, 0x2e, 0x2c, 0x22, 0x34
		db	0x2c, 0x7f, 0x36, 0x2f, 0x7f, 0x22, 0x35, 0x30
		db	0x34, 0x2c, 0x7f, 0x28
		halt

; "____________________"
msepar:		db	0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
		db	0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
		db	0x10, 0x10, 0x10, 0x10
		halt

; logo "(c) 2013 Louis Seidelmann"
logo:		db	0x13, 0x14, 0x15, 0x16, 0x7f, 0x17, 0x18, 0x19
		db	0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21
		halt

; "mosaic errors found:"
mmerf:		db	0x24, 0x30, 0x2e, 0x22, 0x36, 0x26, 0x7f, 0x2d
		db	0x34, 0x34, 0x30, 0x34, 0x2e, 0x7f, 0x2f, 0x30
		db	0x31, 0x32, 0x33, 0x37
		halt

; "fetch errors found:"
mferf:		db	0x2f, 0x2d, 0x2c, 0x26, 0x25, 0x7f, 0x2d, 0x34
		db	0x34, 0x30, 0x34, 0x2e, 0x7f, 0x2f, 0x30, 0x31
		db	0x32, 0x33, 0x37
		halt

; "7 - mosaic"
m7mosaic:	db	0xbf, 0x7f, 0x28, 0x7f

; "mosaic"
mmosaic:	db	0x24, 0x30, 0x2e, 0x22, 0x36, 0x26
		halt

; "6 - fetch M1"
m6fetch:	db	0xbe, 0x7f, 0x28, 0x7f

; "fetch M1"
mfetch:		db	0x2f, 0x2d, 0x2c, 0x26, 0x25, 0x7f, 0x2b, 0x39
		halt

; "@ bits 7-1-0-2"
mbit7102p:	db	0x11, 0x12, 0x7f

; "bits 7-1-0-2"
mbit7102:	db	0x35, 0x36, 0x2c, 0x2e, 0x7f, 0x3f, 0x28, 0x39
		db	0x28, 0x38, 0x28, 0x3a
		halt

; "@ set 4000-43ff"
mset0:		db	0x11, 0x12, 0x7f, 0x2e, 0x2d, 0x2c, 0x7f, 0x3c
		db	0x38, 0x38, 0x38, 0x28, 0x3c, 0x3b, 0x2f, 0x2f
		halt

; "@ set 4400-47ff"
mset1:		db	0x11, 0x12, 0x7f, 0x2e, 0x2d, 0x2c, 0x7f, 0x3c
		db	0x3c, 0x38, 0x38, 0x28, 0x3c, 0x3f, 0x2f, 0x2f
		halt

; "@ 16k set"
mset16:		db	0x11, 0x12, 0x7f, 0x39, 0x3e, 0x27, 0x7f, 0x2e
		db	0x2d, 0x2c
		halt

; "bit"
mbits:		db	0x35, 0x36, 0x2c
		halt

; "@ e8 code read"
mcree8:		db	0x11, 0x12, 0x7f, 0x2d, 0x23, 0x7f, 0x26, 0x30
		db	0x33, 0x2d, 0x7f, 0x34, 0x2d, 0x22, 0x33
		halt

; =============================================================================================

; bit test mosaic table
		org	0x0600

		db	%00000000
		db	%10101010
		db	%11001100
		db	%11110000
		db	%10010110
		db	%01100110
		db	%00111100
		db	%01011010

; =============================================================================================

; "@ bits 4-3-5-6"
mbit4356p:	db	0x11, 0x12, 0x7f

; "bits 4-3-5-6"
mbit4356:	db	0x35, 0x36, 0x2c, 0x2e, 0x7f, 0x3c, 0x28, 0x3b
		db	0x28, 0x3d, 0x28, 0x3e
		halt

; "3 - 3k"
m3kb:		db	0xbb, 0x7f, 0x28, 0x7f, 0x3b, 0x27
		halt

; "4 - 4k"
m4kb:		db	0xbc, 0x7f, 0x28, 0x7f, 0x3c, 0x27
		halt

; "5 - 16k"
m16kb:		db	0xbd, 0x7f, 0x28, 0x7f, 0x39, 0x3e, 0x27
		halt

; "@ set 4800-4bff"
mset2:		db	0x11, 0x12, 0x7f, 0x2e, 0x2d, 0x2c, 0x7f, 0x3c
		db	0x23, 0x38, 0x38, 0x28, 0x3c, 0x35, 0x2f, 0x2f
		halt

; "@ set 4c00-4fff"
mset3:		db	0x11, 0x12, 0x7f, 0x2e, 0x2d, 0x2c, 0x7f, 0x3c
		db	0x26, 0x38, 0x38, 0x28, 0x3c, 0x2f, 0x2f, 0x2f
		halt

; "@ 0"
mbit0:		db	0x11, 0x12, 0x7f, 0x38
		halt

; "@ 1"
mbit1:		db	0x11, 0x12, 0x7f, 0x39
		halt

; "@ 2"
mbit2:		db	0x11, 0x12, 0x7f, 0x3a
		halt

; "@ 3"
mbit3:		db	0x11, 0x12, 0x7f, 0x3b
		halt

; "@ 4"
mbit4:		db	0x11, 0x12, 0x7f, 0x3c
		halt

; "@ 5"
mbit5:		db	0x11, 0x12, 0x7f, 0x3d
		halt

; "@ 6"
mbit6:		db	0x11, 0x12, 0x7f, 0x3e
		halt

; "@ 7"
mbit7:		db	0x11, 0x12, 0x7f, 0x3f
		halt

; =============================================================================================

; character definitions
		org	0x0628

; 0x0f - down and up button border
		db	%11111111
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00000000
		db	%11111111

; 0x10 - separators
		db	%00000000
		db	%00000000
		db	%11111111
		db	%00000000
		db	%00000000
		db	%11111111
		db	%00000000
		db	%00000000

; 0x11 - pointed 0/
		db	%01111111
		db	%01000000
		db	%01000000
		db	%01010000
		db	%01001001
		db	%01000110
		db	%01000000
		db	%01111111

; 0x12 - pointed /
		db	%10010000
		db	%10100000
		db	%11000000
		db	%10000000
		db	%10000000
		db	%10000000
		db	%10000000
		db	%10000000

; 0x13 - logo
		db	%01010001
		db	%01011101
		db	%01000001
		db	%00111110
		db	%00111110
		db	%01000001
		db	%01011101
		db	%01010001

; 0x14
		db	%00000100
		db	%00001000
		db	%00010000
		db	%00011110
		db	%00000000
		db	%00001100
		db	%00010010
		db	%00000010

; 0x15
		db	%01001000
		db	%01001000
		db	%01001000
		db	%00110001
		db	%00000000
		db	%00110000
		db	%01001001
		db	%01001000

; 0x16
		db	%10000110
		db	%10000001
		db	%10000001
		db	%11001110
		db	%00000000
		db	%10001110
		db	%10000001
		db	%10000001

; 0x17
		db	%10000010
		db	%10000010
		db	%10000010
		db	%11110001
		db	%10000000
		db	%10000000
		db	%10000000
		db	%10000001

; 0a18
		db	%01001001
		db	%01001001
		db	%01001001
		db	%10000111
		db	%00000000
		db	%00000000
		db	%00000000
		db	%10001001

; 0x19
		db	%00100100
		db	%00100011
		db	%00100000
		db	%00100011
		db	%00000000
		db	%00100000
		db	%00000000
		db	%00100011

; 0x1a
		db	%00000001
		db	%00000001
		db	%10000001
		db	%00001110
		db	%00000111
		db	%00001000
		db	%00001000
		db	%00000110

; 0x1b
		db	%00100100
		db	%00111100
		db	%00100000
		db	%00011100
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00011000

; 0x1c
		db	%10010010
		db	%10010010
		db	%10010010
		db	%10001110
		db	%00000010
		db	%10000010
		db	%00000010
		db	%10001110

; 0x1d
		db	%01001001
		db	%01111001
		db	%01000001
		db	%00111001
		db	%00000011
		db	%00000001
		db	%00000001
		db	%00110001

; 0x1e
		db	%00100100
		db	%00100100
		db	%00100100
		db	%00100100
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00111011

; 0x1f
		db	%10000001
		db	%10001111
		db	%10010001
		db	%10001111
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00001110

; 0x20
		db	%00100100
		db	%00100100
		db	%00100100
		db	%00100100
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00111000

; 0x21
		db	%10010000
		db	%10010000
		db	%10010000
		db	%10010000
		db	%00000000
		db	%00000000
		db	%00000000
		db	%11100000

; 0x22 - 'a'
		db	%00000000
		db	%00000000
		db	%00111100
		db	%00000010
		db	%00111110
		db	%01000010
		db	%01000010
		db	%00111110

; 0x23 - '8'
		db	%00111100
		db	%01000010
		db	%01000010
		db	%00111100
		db	%01000010
		db	%01000010
		db	%01000010
		db	%00111100

; 0x24 - 'm'
		db	%00000000
		db	%00000000
		db	%11101100
		db	%10010010
		db	%10010010
		db	%10010010
		db	%10010010
		db	%10010010

; 0x25 - 'h'
		db	%01000000
		db	%01000000
		db	%01111100
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010

; 0x26 - 'c'
		db	%00000000
		db	%00000000
		db	%00111110
		db	%01000000
		db	%01000000
		db	%01000000
		db	%01000000
		db	%00111110

; 0x27 - 'k'
		db	%01000000
		db	%01000000
		db	%01000010
		db	%01000100
		db	%01001000
		db	%01110000
		db	%01001000
		db	%01000110

; 0x28 - "-"
		db	%00000000
		db	%00000000
		db	%00000000
		db	%00000000
		db	%01111110
		db	%00000000
		db	%00000000
		db	%00000000

; 0x29 - 'R'
		db	%01111100
		db	%01000010
		db	%01000010
		db	%01000100
		db	%01111000
		db	%01001000
		db	%01000100
		db	%01000010

; 0x2a - 'A'
		db	%00111100
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01111110
		db	%01000010
		db	%01000010
		db	%01000010

; 0x2b - 'M'
		db	%01000010
		db	%01100110
		db	%01011010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010

; 0x2c - 't'
		db	%00010000
		db	%00010000
		db	%01111100
		db	%00010000
		db	%00010000
		db	%00010000
		db	%00010000
		db	%00001110

; 0x2d - 'e'
		db	%00000000
		db	%00000000
		db	%00111100
		db	%01000010
		db	%01111110
		db	%01000000
		db	%01000000
		db	%00111110

; 0x2e - 's'
		db	%00000000
		db	%00000000
		db	%00111100
		db	%01000000
		db	%00111100
		db	%00000010
		db	%00000010
		db	%00111100

; 0x2f - 'f'
		db	%00001110
		db	%00010000
		db	%00010000
		db	%01111110
		db	%00010000
		db	%00010000
		db	%00010000
		db	%00010000

; 0x30 - 'o'
		db	%00000000
		db	%00000000
		db	%00111100
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%00111100

; 0x31 - 'u'
		db	%00000000
		db	%00000000
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%00111110

; 0x32 - 'n'
		db	%00000000
		db	%00000000
		db	%01111100
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010

; 0x33 - 'd'
		db	%00000010
		db	%00000010
		db	%00111110
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01000010
		db	%00111110

; 0x34 - 'r'
		db	%00000000
		db	%00000000
		db	%01011110
		db	%01100000
		db	%01000000
		db	%01000000
		db	%01000000
		db	%01000000

; 0x35 - 'b'
		db	%01000000
		db	%01000000
		db	%01000000
		db	%01111100
		db	%01000010
		db	%01000010
		db	%01000010
		db	%01111100

; 0x36 - 'i'
		db	%00011000
		db	%00011000
		db	%00000000
		db	%00111000
		db	%00001000
		db	%00001000
		db	%00001000
		db	%00111100

; 0x37 - ':'
		db	%00000000
		db	%00000000
		db	%00011000
		db	%00011000
		db	%00000000
		db	%00011000
		db	%00011000
		db	%00000000

; 0x38 - '0'
		db	%00011000
		db	%00100100
		db	%01000010
		db	%01001010
		db	%01010010
		db	%01000010
		db	%00100100
		db	%00011000

; 0x39 - '1'
		db	%00011000
		db	%00101000
		db	%01001000
		db	%00001000
		db	%00001000
		db	%00001000
		db	%00001000
		db	%01111110

; 0x3a - '2'
		db	%00111100
		db	%01000010
		db	%00000010
		db	%00000100
		db	%00001000
		db	%00010000
		db	%00100000
		db	%01111110

; 0x3b - '3'
		db	%00111100
		db	%01000010
		db	%00000010
		db	%00001100
		db	%00000010
		db	%00000010
		db	%01000010
		db	%00111100

; 0x3c - '4'
		db	%00000100
		db	%00001100
		db	%00010100
		db	%00100100
		db	%01000100
		db	%01111110
		db	%00000100
		db	%00000100

; 0x3d - '5'
		db	%01111110
		db	%01000000
		db	%01000000
		db	%01111100
		db	%00000010
		db	%00000010
		db	%01000010
		db	%00111100

; 0x3e - '6'
		db	%00111100
		db	%01000000
		db	%01000000
		db	%01111100
		db	%01000010
		db	%01000010
		db	%01000010
		db	%00111100

; 0x3f - '7'
		db	%01111110
		db	%01000010
		db	%00000100
		db	%00001000
		db	%00001000
		db	%00010000
		db	%00010000
		db	%00010000

;		end