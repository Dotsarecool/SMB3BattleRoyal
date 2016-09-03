ORG $118000

dma_player_graphics:
		PHP
		REP #$10
		
		LDA #$80
		STA $2115
		LDA #$3D
		STA $4304
		LDX #$1801
		STX $4300
		LDX #$0006
		LDA #$01
	.loop:
		REP #$20
		TXA
		XBA
		LSR A
		CLC
		ADC #$7400
		TAY
		SEP #$20
		LDA #$01
		STY $2116
		
		LDY !player_tiles,X
		STY $4302
		LDY #$0040
		STY $4305
		STA $420B
		
		LDY !player_tiles+$10,X
		STY $4302
		LDY #$0040
		STY $4305
		STA $420B
		
		LDY !player_tiles+$20,X
		STY $4302
		LDY #$0040
		STY $4305
		STA $420B
		
		LDY !player_tiles+$30,X
		STY $4302
		LDY #$0040
		STY $4305
		STA $420B	
	
		DEX
		DEX
		BPL .loop
		
		LDX #$0001
		PLP
		RTL

update_controllers:
		STZ $4016 ; i/o bit
		LDX #$03
		LDY #$06
	.loop:
		LDA !controller_axlr_hold,X
		AND $4218,Y
		EOR $4218,Y
		STA !controller_axlr_frame,X
		LDA $4218,Y
		STA !controller_axlr_hold,X
		
		LDA !controller_byetudlr_hold,X
		AND $4219,Y
		EOR $4219,Y
		STA !controller_byetudlr_frame,X
		LDA $4219,Y
		STA !controller_byetudlr_hold,X
		
		DEY
		DEY
		DEX
		BPL .loop
		RTL

load_player_pose:
		REP #$30
		LDA #$F82E
		STA $04
		LDA #$1000
		STA $00
		
		LDX #$0003
	.loop:
		LDA !player_animation_frame,X
		AND #$00FF
		TAY
		PHX
		TXA
		ASL #4
		TAX
		
		LDA ($04),Y
		CLC
		ADC $00
		STA !player_tiles,X
		INY
		INY
		LDA ($04),Y
		CLC
		ADC $00
		STA !player_tiles+2,X
		INY
		INY
		LDA ($04),Y
		CLC
		ADC $00
		STA !player_tiles+4,X
		INY
		INY
		LDA ($04),Y
		CLC
		ADC $00
		STA !player_tiles+6,X
		
		LDA $00
		EOR #$1000
		STA $00
		
		PLX
		DEX
		BPL .loop
		
		SEP #$30
		RTL

; given X = player 0-3
draw_players:
		LDA !player_y_position_high,X
		BPL .check_zero
		LDA !player_y_position_low,X
		CMP #$E0
		BCS .flash
		RTL
	.check_zero:
		BEQ .flash
		RTL
	.flash:
		LDA !player_invinsible,X
		BEQ .draw
		LDA $15
		AND #$02
		BEQ .draw
		RTL
	.draw:
		
		TXA
		ASL #4
		TAY
		LDA !player_x_position,X
		STA $0900,Y
		STA $0904,Y
		STA $0908,Y
		STA $090C,Y
		LDA !player_y_position_low,X
		STA $0901,Y
		STA $0909,Y
		CLC
		ADC #$10
		STA $0905,Y
		STA $090D,Y
		TXA
		ASL A
		CLC
		ADC #$40
		STA $0902,Y
		STA $090A,Y
		CLC
		ADC #$20
		STA $0906,Y
		STA $090E,Y
		TXA
		ASL #2
		EOR #$0F
		STA $00
		LDA !player_direction,X
		AND #$01
		CLC
		ROR #3
		ORA $00
		ORA #$20
		STA $00
		STA $0903,Y
		STA $0907,Y
		STA $090B,Y
		STA $090F,Y
		
		TXA
		ASL #2
		TAY
		LDA #$02
		STA $0A60,Y
		STA $0A61,Y
		LDA #$03
		STA $0A62,Y
		STA $0A63,Y
		
		LDA !player_animation_frame,X
		CMP #$30
		BNE .done
		
		TXA
		ASL #3
		TAY
		LDA !player_y_position_low,X
		CLC
		ADC #$10
		STA $0941,Y
		CLC
		ADC #$08
		STA $0945,Y
		LDA #$8E
		STA $0942,Y
		LDA #$8F
		STA $0946,Y
		LDA $00
		AND #$FE
		STA $0943,Y
		STA $0947,Y
		LDA !player_direction,X
		AND #$01
		BEQ .flip_foot
		LDA !player_x_position,X
		CLC
		ADC #$10
		BRA .foot_merge
	.flip_foot:
		LDA !player_x_position,X
		SEC
		SBC #$08
	.foot_merge:
		STA $0940,Y
		STA $0944,Y
		
		TXA
		ASL #2
		TAY
		LDA #$00
		STA $0A70,Y
		STA $0A71,Y
		
	.done:
		RTL

load_level:
		PHB
		PHK
		PLB
		PHP
		
		REP #$10
		LDX #$00EF
	.loop_level:
		LDA custom_level,X
		STA $7E2000,X
		DEX
		BPL .loop_level
		
		LDX #$0009
	.loop_scoreboard:
		LDA scoreboard,X
		STA $7E2003,X
		LDA scoreboard+$0A,X
		STA $7E2013,X
		DEX
		BPL .loop_scoreboard
		
		PLP
		PLB
		RTL
		
scoreboard:
		db $20,$21,$22,$23,$24,$25,$26,$27,$28,$29
		db $40,$41,$42,$43,$44,$45,$46,$47,$48,$49
normal_level:
		db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		db $81,$80,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$80,$81
		db $83,$82,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$82,$83
		db $C1,$C1,$C1,$C1,$C1,$C1,$02,$02,$02,$02,$C1,$C1,$C1,$C1,$C1,$C1
		db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$02,$02,$02,$02
		db $C1,$C1,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$C1,$C1
		db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		db $C1,$C1,$C1,$C1,$C1,$C1,$02,$02,$02,$02,$C1,$C1,$C1,$C1,$C1,$C1
		db $81,$80,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$80,$81
		db $83,$82,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$82,$83
		db $50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50
		db $50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50
custom_level:
		db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		db $81,$80,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$80,$81
		db $83,$82,$02,$02,$02,$02,$02,$C1,$C1,$02,$02,$02,$02,$02,$82,$83
		db $C1,$C1,$C1,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$C1,$C1,$C1
		db $02,$C0,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$C0,$02
		db $02,$C0,$02,$C1,$C1,$C1,$C1,$02,$02,$C1,$C1,$C1,$C1,$02,$C0,$02
		db $02,$C0,$02,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$02,$C0,$02
		db $02,$C0,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$C0,$02
		db $C1,$C1,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$C1,$C1
		db $02,$02,$02,$02,$02,$02,$C1,$C1,$C1,$C1,$02,$02,$02,$02,$02,$02
		db $02,$02,$02,$02,$02,$C1,$C1,$02,$02,$C1,$C1,$02,$02,$02,$02,$02
		db $C1,$C1,$C1,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$C1,$C1,$C1
		db $81,$80,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$80,$81
		db $83,$82,$02,$02,$02,$02,$02,$50,$50,$02,$02,$02,$02,$02,$82,$83
		db $50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50
		
clear_scoreboards:
		PHP
		
		REP #$20
		LDA #$4900
		STA $1602
		LDA #$4E00
		STA $1608
		LDA #$5300
		STA $160E
		LDA #$5800
		STA $1614
		LDA #$0100
		STA $1604
		STA $160A
		STA $1610
		STA $1616
		LDA #$191A
		STA $1606
		LDA #$1D1A
		STA $160C
		LDA #$192A
		STA $1612
		LDA #$193A
		STA $1618
		
		LDA #$FFFF
		STA $161A
		
		PLP
		RTL

tally_point:
		LDA !winner_of_game
		DEC A
				EOR #$01 ; remove this when !winner_of_game is updated
		TAX
		LDA #$01
		STA $1203
		INC !number_won_games,X
		LDA !number_won_games,X
		CMP #$05
		BCC .done
		INC !number_won_matches,X
		LDA #$05
		STA $1203
	.done:
		RTL

load_all_players_byetudlr:
		LDA !controller_byetudlr_frame
		ORA !controller_byetudlr_frame+1
		ORA !controller_byetudlr_frame+2
		ORA !controller_byetudlr_frame+3
		RTL
		
load_all_players_axlr:
		LDA !controller_axlr_frame
		ORA !controller_axlr_frame+1
		ORA !controller_axlr_frame+2
		ORA !controller_axlr_frame+3
		RTL
		
make_all_players_big:
		LDA #$01
		STA !player_size
		STA !player_size+1
		STA !player_size+2
		STA !player_size+3
		RTL

flash_scoreboard:
		PHB
		PHK
		PLB
		
		LDA $078C
	;	DEC A ; temp
	;	AND #$03
				AND #$01
		TAX
		LDA !player_coin_count,X
		CMP #$05
		BNE .done
		LDA $2143
		BNE .no_sound
		LDA #$05
		STA $1203
	.no_sound:
		LDA $15
		AND #$04
		BEQ .erase_tile
	.draw_tile:
		LDA number_5_properties,X
		STA $1607
		LDA number_5_tiles,X
		BRA .merge
	.erase_tile:
		LDA #$10
		STA $1607
		LDA #$FF
	.merge:
		STA $1606
		LDA #$FF
		STA $1608
		STZ $1602
		LDA number_5_locations,X
		STA $1603
		STZ $1604
		LDA #$01
		STA $1605
		
	.done:
		PLB
		RTL

number_5_locations:
		db $49,$4E,$53,$58
number_5_tiles:
		db $1F,$1F,$2F,$3F
number_5_properties:
		db $19,$1D,$19,$19
		
merge_controls:
		LDX #$03
	.loop:
		LDA !controller_axlr_hold,X
		AND #$C0
		ORA !controller_byetudlr_hold,X
		STA !controller_byetudlr_hold,X
		LDA !controller_axlr_frame,X
		AND #$C0
		ORA !controller_byetudlr_frame,X
		STA !controller_byetudlr_frame,X
		
	.check_lr:
		LDA !controller_byetudlr_hold,X
		AND #$03
		CMP #$03
		BNE .check_ud
		LDA !controller_byetudlr_hold,X
		AND #$FE
		STA !controller_byetudlr_hold,X
	.check_ud:
		LDA !controller_byetudlr_hold,X
		AND #$0C
		CMP #$0C
		BNE .continue
		LDA !controller_byetudlr_hold,X
		AND #$F7
		STA !controller_byetudlr_hold,X
	
	.continue:
		DEX
		BPL .loop
		RTL

disable_controls:
		LDX #$0F
	.loop:
		STZ !controller_axlr_hold,X
		DEX
		BPL .loop
		RTL

decrement_death_timers:
		STZ !player_y_offset,X
		LDA $76
		BNE .done
		LDA !player_death_timer_a,X
		BEQ .check_b
		DEC !player_death_timer_a,X
	.check_b:
		LDA !player_death_timer_b,X
		BEQ .done
		DEC !player_death_timer_b,X
	.done:
		RTL