###########################################
# where is data?
# 0xE0 - const coordinate of cdm8's bat on x
# 0xE1 - coordinates of cdm8's bat on y
# 0xE2, 0xE3 - ball's velocity by x and y
# 0xE4, 0xE5 - ball's coordinates
###########################################


macro idv/2
	ldi $1, $2
	ld $1, $1
mend

asect 0xe0

const_bat_coord_x: 	dc 30 #на самом деле это не надо но мне удобнее было чтобы она была
#тк считаем от 0	
bat_coords_y: 		ds 1
ball_velocity_x: 	ds 1
ball_velocity_y: 	ds 1
ball_coord_x: 		ds 1
ball_coord_y: 		ds 1

###########################################
# bot itself
#formula for counting
#d = y + (30 - x) / vx * vy - 31
#res = 31 - d
###########################################

asect 0x00

start:

	idv r0, ball_coord_x
	idv r1, ball_velocity_x
	
	#если мяч на левой стороне то ничего 
	#считать не нужно
	#и если он только движется к левой стене то 
	#считать нет смысла
	#влево х отрицательный
	if 
		tst r1
	is mi, or
		ldi r2, 15
		#если координата мяча больше 15 он справа
		cmp r0, r2
	is ge
	then
		br start
	fi
	
	#30 - x
	ldi r2, 30
	sub r2, r0
	
	#reset flags
	tst r0
	
	# деление
	ldi r2, 0
	neg r1
	while
		tst r0
	stays gt
		add r1, r0
		inc r2
	wend
	# r2 - результат деления
	idv r3, ball_velocity_y
	
	# multiply
	# r3 - vy, r2 - division res
	while
		tst r3
	stays gt
		add r2, r2
		# я в этом не уверена но по идее переполниться не может
		# потому что на самом деле скорости по 1))))
		dec r3
	wend
	
	idv r3, ball_coord_y
	# y + r2
	add r3, r2
	ldi r3, 31
	sub r2, r3
	
	ldi r0, bat_coords_y
	st r0, r3
	
	br start
	rts

halt
end
