BORDCR equ 23624

START equ 16384

	org 8192
	ld a,h                  ; 8192
	or l                    ; 8193
	jr nz,Lab8202           ; 8194
Lab8196
	ld hl,Usage
BucPrintMsg
	ld a,(hl)
	or a
	ret z
	rst 10h
	inc hl
	jr BucPrintMsg
Lab8202
	call zero
	ld hl, buffer
	ld a,42                 ; 8216
	ld b,12; create file                 ; 8218
	rst 8                   ; 8220
	sbc a,d  ; open               ; 8221
	ret c                   ; 8222
	ld (handle),a          ; 8223
	jr nc, petla
wypad:  ; 8231
	ld a,(handle)          ; 8234
	rst 8                   ; 8237
	sbc a,e ; close                ; 8238
	rst 0
	ret                     ; 8239
;Lab8240
;	ld bc,(Lab8468)           ; 8241
;	ld de,(Lab8470)         ; 8245
	

petla
	ld ix, START + 2
	ld de, 65535 - START - 2
	ld a,0
	scf
	call ld_bytes

	ld a,ixh
	cp 64
	jr nz,save
	ld a,ixl
	cp 2
	jr z,wypad
save
	ld a, 4 ; green
	out (254), a
	or a
	ld hl, START + 2
	ld d,ixh
	ld e,ixl
	ex de,hl
	sbc hl,de
	ld (START),hl
	ld b,h
	ld c,l
	ld hl,START
	inc bc
	inc bc

	ld a,(handle)          ; 8234
	rst 8
	sbc a,(hl); write
	jr petla

ld_ret
	push af
	ld a,(BORDCR)
	and 0x38
	rrca
	rrca
	rrca
	out (254),a
	ld a,0x7f
	in a,(254)
	rra
	ei
;	jr c,ld_end
;report_d
;	rst 0x08
;	defb 0x0c
ld_end
	pop af
	ret

ld_bytes
	inc d
	ex af,af'
	dec d
	di
	ld a,0x0f
	out (254),a
	ld hl,ld_ret
	push hl
	in a,(254)
	rra
	and 0x20
	or 0x02
	ld c,a
	cp a
ld_break
	ret nz
ld_start
	call ld_edge_1
	jr nc,ld_break
	ld hl,0x0415
ld_wait
	djnz ld_wait
	dec hl
	ld a,h
	or l
	jr nz,ld_wait
	call ld_edge_2
	jr nc,ld_break
ld_leader
	ld b,0x9c
	call ld_edge_2
	jr nc,ld_break
	ld a,0xc6
	cp b
	jr nc,ld_start
	inc h
	jr nz,ld_leader
ld_sync
	ld b,0xc9
	call ld_edge_1
	jr nc,ld_break
	ld a,b
	cp 0xd4
	jr nc,ld_sync
	call ld_edge_1
	ret nc
	ld a,c
	xor 0x03
	ld c,a
	ld h,0
	ld b,0xb0
	jr ld_marker
ld_loop
	ex af,af'
;;;	jr nz,ld_flag
	ld (ix+0),l
;;	jr nc, ld_verify
;;;	jr ld_next
;;;ld_flag
;;;	rl c
;;;	xor l
;;;	ret nz
;;;	ld (ix+0),l
;;;	ld a,c
;;;	rra
;;;	ld c,a
;;	inc de
;;	jr ld_dec
;ld_verify
;	ld a,(ix+0)
;	xor l
;	ret nz
ld_next
	inc ix
ld_dec
	dec de
	ex af,af'
	ld b,0xb2
ld_marker
	ld l,1
ld_8_bits
	call ld_edge_2
	ret nc
	ld a,0xcb
	cp b
	rl l
	ld b,0xb0
	jp nc,ld_8_bits
	ld a,h
	xor l
	ld h,a
	ld a,d
	or e
	jr nz,ld_loop
	ld a,h
	cp 1
	ret

ld_edge_2
	call ld_edge_1
	ret nc
ld_edge_1
	ld a,0x16
ld_delay
	dec a
	jr nz,ld_delay
	and a
ld_sample
	inc b
	ret z
	ld a,0x7f
	in a,(254)
	rra
	ret nc
	xor c
	and 0x20
	jr z,ld_sample
	ld a,c
	cpl
	ld c,a
	and 0x07
	or 0x08
	out (254),a
	scf
	ret

zero
	ld b, 255
	ld d, h
	ld e, l
	ld hl, buffer
zero_p
	ld a,(de)
	ld (hl), a
	or a
	ret z
	cp 13
	jr nz, colon
zeruj
	xor a
	ld (hl),a
	ret
colon
	cp ':'
	jr z, zeruj
	inc de
	inc hl
	djnz zero_p
	ret

Usage
	db ".ear2tap new.tap",13,13
	db "Copy from EAR to new.tap file.",13
	db "Similar to COPY-COPY program.",13
	db "It restarts the machine after BREAK.",13,0

handle
	nop
Lab8461 nop ;drive
Lab8462	nop ;device
Lab8463	nop; attr
Lab8464	nop ; date
	nop
	nop
	nop
Lab8468 ; size
	nop
	nop
	nop
	nop
LabDlug nop
	nop
Lab8472 nop
	nop
header
	defb 255
buffer
	nop
