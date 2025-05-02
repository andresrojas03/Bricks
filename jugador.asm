title "Codigo prueba para jugador Bricks"
    .model small
    .386
    .stack 64
    .data

    ;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		30
;Valores de referencia para la posición inicial del jugador y la bola
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	22

;/////variables/////////
pos_x			db 		"Posicion x"
pos_y			db 		"Posicion y"
conta 			db 		0
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;1000 auxiliar para operación DIV entre 1000
diez 			dw 		10 		;10 auxiliar para operaciones
sesenta			db 		60 		;60 auxiliar para operaciones
status 			db 		0 		;0 stop, 1 play, 2 pause
ticks 			dw		0 		;Variable para almacenar el número de ticks del sistema y usarlo como referencia

player_col      db      ini_columna
player_ren      db      ini_renglon

col_aux         db      0
ren_aux         db      0

brick_color 	db 		0
mapa_bricks 	db 		3,2,1,3,2,1,'#',2,1,3,2,1,3,'#',1,3,2,1,3,2,'#',3,2,1,3,2,1,'#',2,1,3,2,1,3,'%' 
;el número indica el "nivel" del brick, el carácter '#' indica el fin del renglón
;el carácter '%' indica el fin del mapa


;Bola
bola_col		db 		ini_columna 	 	;columna de la bola
bola_ren		db 		ini_renglon-1 		;renglón de la bola
bola_pend 		db 		1 		;pendiente de desplazamiento de la bola
bola_rap 		dw 		1		;rapidez de la bola ////modificada a 1, el original es 2
bola_dir		db 		3 		;dirección de la bola. 0 izquierda-abajo, 1 derecha-abajo, 2 izquierda-arriba, 3 derecha-arriba
bola_dir_x		db		2		;dirección en x de la bola 
bola_dir_y		db		1		;dirección en y de la bola


;variables nuevas para las funciones agregadas
toco_lim_izq 	db 		0
toco_lim_der	db 		0
end_game 		db 		0
delay_ticks		dw 		3
aux_mul			dw		0
dir_colision	db 		0	; 0 No colision, 1 colision superior, 2 colision inferior, 3 colision izquierda, 4 colision derecha
;////////macros//////
;limpiar pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;//////////////////////////////
;////////MACROS AGREGADAS//////
;//////////////////////////////


    .code
inicio: 
    inicializa_ds_es
	clear
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call IMPRIME_BRICKS
	call BORRA_BOLA
	call IMPRIME_BOLA
	call IMPRIME_JUGADOR
	
	;obtener ticks iniciales
	mov ah, 00h 
	int 1Ah		;	CX:DX = ticks iniciales
	mov ticks, dx 

;"ciclo" para que salga hasta que se presione la tecla esc
jugar:
	;verificamos la entrada del jugador
	mov ah, 01h					;función hay tecla disponible
	int 16h 
	jnz tecla_presionada		;si hay tecla, procesamos esa entrada 

mover_bola:
	
	call MOVIMIENTO_BOLA 
	jmp jugar	

tecla_presionada:
	call MOVER_JUGADOR	
	cmp end_game, 1				;comprobamos si se presionó la tecla esc
	je salir					;si end_game == 1 => saltamos a la etiqueta salir
	call MOVIMIENTO_BOLA 
	jmp jugar

salir: 
	clear
    mov ax, 4C00h
    int 21h


;procedimientos

PRINT_TEXT proc
		posiciona_cursor [ren_aux], [col_aux]
		imprime_cadena_color [pos_x], 9,cBlanco, bgNegro
		inc[col_aux]

		posiciona_cursor [ren_aux], [col_aux]
		imprime_cadena_color [bola_dir_x], 4, cBlanco, bgNegro
		inc[col_aux]
		
		posiciona_cursor [ren_aux], [col_aux]
		imprime_cadena_color [pos_y], 9, cBlanco,bgNegro
		inc[col_aux]

		posiciona_cursor [ren_aux], [col_aux]
		imprime_cadena_color [bola_dir_y], 4, cBlanco, bgNegro

		
	endp



PRINT_PLAYER proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		ret
	endp

;Borra la barra del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central de la barra
DELETE_PLAYER proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 20h,cBlanco,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 20h,cBlanco,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 20h,cBlanco,bgNegro
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 20h,cBlanco,bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 20h,cBlanco,bgNegro
		ret
		ret
	endp

IMPRIME_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_PLAYER
		ret
	endp

BORRA_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_PLAYER
		ret
	endp

;Imprime la bola de juego, que recibe como parámetros las variables bola_col y bola_ren, que indican la posición de la bola
IMPRIME_BOLA proc
		mov ah,[bola_col]
		mov al,[bola_ren]
		mov [col_aux],ah
		mov [ren_aux],al
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 2d,cCyanClaro,bgNegro 
		ret
	endp

	;Borra la bola de juego, que recibe como parámetros las variables bola_col y bola_ren, que indican la posición de la bola
BORRA_BOLA proc
		mov ah,[bola_col]
		mov al,[bola_ren]
		mov [col_aux],ah
		mov [ren_aux],al
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color ' ',cBlanco,bgNegro 
		ret
	endp

;/////////////////////////////////////////////////////////////////
;///////Las funciones debajo de este mensaje//////////////////////
;///////son la que necesitamos para el código/////////////////////
;/////////////////////////////////////////////////////////////////

;logica para el movimiento del jugador
MOVER_JUGADOR proc
		;preparamos la lectura de teclado
		mov ah, 00h
		int 16h
		jz fin_movimiento
		;si leemos "a" el jugador se mueve a la izquierda
		cmp al, "a"
		je izquierda
		;si leemos "d" el jugador se mueve a la derecha
		cmp al, "d"
		je derecha

		;comprueba si se presionó la tecla esc, cambiar esto para que funcione
		;con el botón cuando se implemente
		cmp al, 1Bh
		je terminar_juego

		jmp fin_movimiento
		
		izquierda:
			;detectamos si se llegó al limite de la zona de juego
			call COMP_LIM_JUGADOR_IZQ
			cmp toco_lim_izq, 1		;comprobar si se llegó al limite
			je fin_movimiento

			call BORRA_JUGADOR
			dec [player_col]
			call IMPRIME_JUGADOR
			jmp fin_movimiento
			

		derecha: 
			;detectamos si se llegó al limite de la zona de juego
			call COMP_LIM_JUGADOR_DER
			cmp toco_lim_der, 1
			je fin_movimiento

			call BORRA_JUGADOR
			inc [player_col]
			call IMPRIME_JUGADOR
			jmp fin_movimiento

		fin_movimiento:
			mov ah, 00h
			ret

		terminar_juego:
			mov end_game, 1
			ret	
	endp

;lógica para que el jugador no salga de la zona de juego por la izquierda
COMP_LIM_JUGADOR_IZQ proc
		dec [player_col]	;realizamos un decremento para la comparación
		cmp [player_col], lim_izquierdo + 1	;player_col < lim_izquierdo
		
		jl lim_izq_tocado
		jmp lim_izq_no_tocado

		lim_izq_tocado:
			mov toco_lim_izq, 1
			inc [player_col] 	;regresamos el decremento de la comparación
			ret
		lim_izq_no_tocado:
			mov toco_lim_izq, 0
			inc [player_col]
			ret
	endp

;lógica para que el jugador no salga de la zona de juego por la derecha
COMP_LIM_JUGADOR_DER proc
		inc [player_col]	;realizamos un incremento para la comparación
		cmp [player_col], lim_derecho - 1	;player_col > lim_derecho

		jg lim_der_tocado
		jmp lim_der_no_tocado 

		lim_der_tocado:
			mov toco_lim_der, 1
			dec [player_col]	;regresamos el incremento que hicimos
			ret
		lim_der_no_tocado:
			mov toco_lim_der, 0
			dec [player_col]
			ret
	endp





;//////////////////////////////////////////////
;////////////LOGICA DE LA BOLA/////////////////
;//////////////////////////////////////////////

;El inicio de la pantalla (0,0) está ubicado en la esquina superior
;izquierda, por lo que el eje Y está invertido, si se quiere ir para
;arriba se deben restar números y al revés

MOVIMIENTO_BOLA proc
		delay:
			mov ah, 00h 
			int 1Ah 
			sub dx, [ticks]
			cmp dx, [delay_ticks]
			jb delay

			call BORRA_BOLA
			

			; Movimiento según dirección actual
			cmp [bola_dir], 0   ; Izquierda abajo
			je direccion_0
			cmp [bola_dir], 1   ; Derecha abajo
			je direccion_1
			cmp [bola_dir], 2   ; Izquierda arriba
			je direccion_2
			cmp [bola_dir], 3   ; Derecha arriba
			je direccion_3

		direccion_0:
			dec [bola_col]      ; Mover izquierda
			inc [bola_ren]      ; Mover abajo
			jmp comprobar_colision

		direccion_1:
			inc [bola_col]      ; Mover derecha
			inc [bola_ren]      ; Mover abajo
			jmp comprobar_colision

		direccion_2:
			dec [bola_col]      ; Mover izquierda
			dec [bola_ren]      ; Mover arriba
			jmp comprobar_colision

		direccion_3:
			inc [bola_col]      ; Mover derecha
			dec [bola_ren]      ; Mover arriba
			jmp comprobar_colision

		comprobar_colision:
			;Verificamos colision con la barra del jugador
			mov al, [player_ren]

			;Verificar colisiones con los bricks
			call DETECTA_COLISION_BRICKS
			cmp [dir_colision], 1	;Si hubo colisión superior
			je col_superior_escenario
			cmp [dir_colision], 2	;Si hubo colision inferior
			je col_inferior_escenario
			cmp [dir_colision], 3	;Si hubo colision izquierda
			je col_lat_izq_escenario
			cmp [dir_colision], 4	;Si hubo colision derecha
			je col_lat_der_escenario

			; Verificar colisiones laterales del escenario
			cmp [bola_col], lim_izquierdo
			jle col_lat_izq_escenario
			cmp [bola_col], lim_derecho
			jge col_lat_der_escenario

			; Luego verificar colisiones verticales
			cmp [bola_ren], lim_superior
			jle col_superior_escenario

			;detectar si tocó al jugador para que rebote
			call DETECTA_COLISION_JUGADOR
			jc col_inferior_escenario		; si CF = 1 detectó al jugador

			;detecta si se tocó el limite inferior para
			;la logica de perder vida
			cmp [bola_ren], lim_inferior
			jge col_inferior_escenario
			jmp dibujar_bola     ; Si no hay colisiones

		col_lat_izq_escenario:
			; Cambiar dirección al rebotar en pared izquierda
			cmp [bola_dir], 0    ; Si venía de izquierda-abajo
			je cambiar_a_dir1    ; Cambiar a derecha-abajo
			cmp [bola_dir], 2    ; Si venía de izquierda-arriba
			je cambiar_a_dir3    ; Cambiar a derecha-arriba
			jmp ajustar_posicion

		col_lat_der_escenario:
			; Cambiar dirección al rebotar en pared derecha
			cmp [bola_dir], 1    ; Si venía de derecha-abajo
			je cambiar_a_dir0    ; Cambiar a izquierda-abajo
			cmp [bola_dir], 3    ; Si venía de derecha-arriba
			je cambiar_a_dir2    ; Cambiar a izquierda-arriba
			jmp ajustar_posicion  

		col_superior_escenario:
			; Cambiar dirección al rebotar en techo
			cmp [bola_dir], 2    ; Si venía de izquierda-arriba
			je cambiar_a_dir0    ; Cambiar a izquierda-abajo
			cmp [bola_dir], 3    ; Si venía de derecha-arriba
			je cambiar_a_dir1    ; Cambiar a derecha-abajo
			jmp ajustar_posicion

		col_inferior_escenario:
			; Cambiar dirección al rebotar en suelo
			cmp [bola_dir], 0    ; Si venía de izquierda-abajo
			je cambiar_a_dir2    ; Cambiar a izquierda-arriba
			cmp [bola_dir], 1    ; Si venía de derecha-abajo
			je cambiar_a_dir3    ; Cambiar a derecha-arriba

		cambiar_a_dir0:
			mov [bola_dir], 0
			jmp ajustar_posicion

		cambiar_a_dir1:
			mov [bola_dir], 1
			jmp ajustar_posicion

		cambiar_a_dir2:
			mov [bola_dir], 2
			jmp ajustar_posicion

		cambiar_a_dir3:
			mov [bola_dir], 3
			jmp ajustar_posicion

		ajustar_posicion:
			; Asegurar que la bola no se quede fuera de los límites
			cmp [bola_col], lim_izquierdo
			jg no_ajustar_izq
			mov [bola_col], lim_izquierdo
		no_ajustar_izq:
			cmp [bola_col], lim_derecho
			jl no_ajustar_der
			mov [bola_col], lim_derecho
		no_ajustar_der:
			cmp [bola_ren], lim_superior
			jg no_ajustar_sup
			mov [bola_ren], lim_superior
		no_ajustar_sup:
			cmp [bola_ren], lim_inferior
			jl no_ajustar_inf
			mov [bola_ren], lim_inferior
		no_ajustar_inf:
			jmp dibujar_bola

		dibujar_bola:
			call IMPRIME_BOLA
			mov ah, 00h 
			int 1Ah 
			mov [ticks], dx
			ret
	endp

DETECTA_COLISION_JUGADOR proc
		push ax
		push bx
		push cx 
		push dx 


		;Guardar posición original de la bola
		mov dh, [bola_ren]
		mov dl, [bola_col]
		inc dh						;incremento debajo de la bola para la colisión
		
		;posicionar cursor
		mov bh, 00h                  ; Página de video 0
		mov ah, 02h                  ; Función para posicionar cursor
		int 10h
		
		; Leer carácter y atributo en cursor
		mov ah, 08h                  
		int 10h
		cmp ah, cBlanco              ; Comparar con color blanco
		je colision_valida_jugador	 ;Colision con el jugador
		
		jmp no_colision_jugador
		
		colision_valida_jugador:
			cmp al, 223			;compara si tocó el caracter del jugador
			jne no_colision_jugador    ;si no lo tocó no hay colisión   

			stc					;CF = 1 porque hubo colision
			jmp fin_deteccion

		no_colision_jugador:
			clc					;CF = 0 porque no hubo colisión
		fin_deteccion:
			pop dx
			pop cx
			pop bx
			pop ax
			ret

	endp



;////////////////////////////////////////////////
;//////////////LOGICA BRICKS/////////////////////
;////////////////////////////////////////////////
IMPRIME_BRICKS proc
		mov [col_aux],1
		mov [ren_aux],2
		mov di,0
		mapa_sig_columna:
			mov bl,[mapa_bricks+di]
			cmp bl,3
			je mapa_brick_n3
			cmp bl,2
			je mapa_brick_n2
			cmp bl,1
			je mapa_brick_n1
			cmp bl,'#'
			je mapa_fin_renglon
			cmp bl,'%'
			je mapa_fin
		mapa_brick_n3:
			mov [brick_color],cAzul
			jmp mapa_imprime_brick
		mapa_brick_n2:
			mov [brick_color],cVerde
			jmp mapa_imprime_brick
		mapa_brick_n1:
			mov [brick_color],cRojo
		mapa_imprime_brick:
			call PRINT_BRICK
			add [col_aux],5
			inc di
			jmp mapa_sig_columna		
		mapa_fin_renglon:
			add [ren_aux],2
			mov [col_aux],1
			inc di
			jmp mapa_sig_columna
		mapa_fin:
		ret
	endp

;Imprime un brick, que recibe como parámetros las variables ren_aux, col_aux y color_brick, que indican la posición superior izquierda del brick y su color
PRINT_BRICK proc
		mov ah,[col_aux]
		mov al,[ren_aux]
		push ax
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		pop ax
		mov [ren_aux],al
		mov [col_aux],ah
		ret
	endp

DETECTA_COLISION_BRICKS proc
		push ax
		push bx
		push cx 
		push dx 

		; Guardar posición original y dirección
		mov dh, [bola_ren]
		mov dl, [bola_col]
		mov ch, [bola_dir]

		; Primera verificación (arriba de la bola)
		dec dh                     ; Mover arriba para verificación
		inc dl					
		verificar_superior:
			mov [dir_colision], 1
			; Posicionar cursor
			mov bh, 00h
			mov ah, 02h
			int 10h
			
			; Leer carácter y atributo
			mov ah, 08h
			int 10h
			
			call ES_UN_BRICK
			jc determinar_direccion_colision
			; Verificar colores de brick
			;cmp ah, cAzul
			;je verificar_caracter_brick
			;cmp ah, cVerde
			;je verificar_caracter_brick
			;cmp ah, cRojo
			;je verificar_caracter_brick
			
			; Si no hubo colisión superior, verificar inferior
			jmp verificar_inferior
			

		verificar_caracter_brick:
			cmp al, 219d            ; Verificar caracter del brick
			jne verificar_inferior  ; Si no es el caracter, verificar inferior
			jmp determinar_direccion_colision

		verificar_inferior:
			; Restaurar posición original y mover abajo
			mov [dir_colision], 2
			mov dh, [bola_ren]
			mov dl, [bola_col]
			add dh, 1               ; Mover abajo para verificación
			
			; Posicionar cursor
			mov bh, 00h
			mov ah, 02h
			int 10h
			
			; Leer carácter y atributo
			mov ah, 08h
			int 10h
			
			call ES_UN_BRICK
			jc determinar_direccion_colision
			; Verificar colores de brick
			;cmp ah, cAzul
			;je verificar_caracter_brick_inf
			;cmp ah, cVerde
			;je verificar_caracter_brick_inf
			;cmp ah, cRojo
			;je verificar_caracter_brick_inf
			
			; Si no hubo colisión inferior pasamos a la verificación lateral
			jmp verificar_izquierda

		;verificar_caracter_brick_inf:
		;	cmp al, 219d            ; Verificar caracter del brick
		;	jne no_colision_bricks  ; Si no es el caracter, no hay colisión
		;	jmp	determinar_direccion_colision 

		verificar_derecha:
			; Restaurar posición original y mover a la derecha
			mov dh, [bola_ren]
			mov dl, [bola_col]
			mov [dir_colision], 4      ; Dirección 4 = derecha
			inc dl                     ; Mover a la derecha
			
			; Posicionar cursor
			mov bh, 00h
			mov ah, 02h
			int 10h
			
			; Leer carácter y atributo
			mov ah, 08h
			int 10h
			
			; Verificar si es brick (optimizado)
			call es_un_brick
			jc determinar_direccion_colision ; Si es brick, hay colisión
			jmp no_colision_bricks         ; Si no, verificar izquierda

		verificar_izquierda:
			; Restaurar posición original y mover a la izquierda
			mov dh, [bola_ren]
			mov dl, [bola_col]
			mov [dir_colision], 3      ; Dirección 3 = izquierda
			dec dl                     ; Mover a la izquierda
			
			; Posicionar cursor
			mov bh, 00h
			mov ah, 02h
			int 10h
			
			; Leer carácter y atributo
			mov ah, 08h
			int 10h
			
			; Verificar si es brick (usando misma función)
			call es_un_brick
			jc determinar_direccion_colision ; Si es brick, hay colisión
			jmp verificar_derecha          ; Si no, pasar a verificar inferior


		determinar_direccion_colision:
			; Determinar tipo de colisión según dirección
			cmp [dir_colision], 1
			je colision_superior_brick
			cmp [dir_colision], 2
			je colision_inferior_brick
			cmp [dir_colision], 3
			je colision_izquierda_brick
			cmp [dir_colision], 4
			je colision_derecha_brick

		colision_superior_brick:
			call CAMBIAR_NIVEL_BRICK
			stc                     ; Indicar colisión
			jmp fin_deteccion_bricks

		colision_inferior_brick:
			call CAMBIAR_NIVEL_BRICK
			stc                     ; Indicar colisión
			jmp fin_deteccion_bricks

		colision_izquierda_brick:		
			call CAMBIAR_NIVEL_BRICK
			stc                     ; Indicar colisión
			jmp fin_deteccion_bricks
		
		colision_derecha_brick:	
			call CAMBIAR_NIVEL_BRICK
			stc                     ; Indicar colisión
			jmp fin_deteccion_bricks

		no_colision_bricks:
			mov[dir_colision], 0 
			clc                     ; Indicar no colisión

		fin_deteccion_bricks:
			pop dx
			pop cx
			pop bx
			pop ax
			ret
	endp

ES_UN_BRICK proc
		es_un_brick:
			; Verifica si el carácter en AH/AL es un brick válido
			; Retorna CF=1 si es brick, CF=0 si no
			cmp al, 219d            ; Primero verificar el carácter
			jne no_es_brick
			cmp ah, cAzul
			je es_brick
			cmp ah, cVerde
			je es_brick
			cmp ah, cRojo
			je es_brick
		
		no_es_brick:
			clc
			ret
		es_brick:
			stc
			ret

	endp
;Para disminuir el nivel del brick en caso de colisión
CAMBIAR_NIVEL_BRICK proc
		;Verificamos el nivel con el color guardado en el registro AH
		mov [col_aux], dl 	;guardamos la columna donde fue la colisión
		mov [ren_aux], dh	;guardamos el renglón donde fue la colisión
		mov ch, ah 			;guardamos el color que se detectó
		
		; Calcular posición relativa dentro del brick (0-4)
		mov al, [col_aux]
		xor ah, ah          ; AX = col_aux
		mov bl, 5
		dec al				;Ajuste porque columnas inician en 1
		div bl              ;AX / BL -> = índice de ladrillo, AH = offset
		mul bl				;AL = AL * 5 -> inicio relativo desde 0
		inc al				;+1 para compensar la columna base (1)
		mov [col_aux], al 	;[col_aux] = inicio del ladrillo colisionado

		;Comparamos el color del brick para determinar el nivel de la colisión
		cmp ch, cAzul		;colisión nivel 3 -> nivel 2
		je nivel_2
		
		cmp ch, cVerde		;colisión nivel 2 -> nivel 1
		je nivel_1
		
		cmp ch, cRojo		;colisión nivel 1 -> borrar Brick (pintar de negro)
		je borra_brick

		jmp fin_cambio

		nivel_2:
			mov [brick_color], cVerde
			jmp imprimir_brick

		nivel_1:
			mov [brick_color], cRojo
			jmp imprimir_brick

		borra_brick:
			mov [brick_color], cNegro
			jmp imprimir_brick 

		imprimir_brick:
			call PRINT_BRICK		

		fin_cambio:
			ret 

	endp
end inicio; fin del programa
