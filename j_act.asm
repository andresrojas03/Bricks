title "Codigo prueba para jugador Bricks"
title 
    .model small
    .386
    .stack 64
    .data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Atributos de color de BIOS
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

;variables de puntaje y vidas
player_lives 	db 		3
player_score 	dw 		0
player_hiscore 	dw 		0

player_col      db      ini_columna
player_ren      db      ini_renglon

col_aux         db      0
ren_aux         db      0

brick_color 	db 		0
mapa_bricks 	db 		3,2,1,3,2,1,'#',2,1,3,2,1,3,'#',1,3,2,1,3,2,'#',3,2,1,3,2,1,'#',2,1,3,2,1,3,'%' 
;el número indica el "nivel" del brick, el carácter '#' indica el fin del renglón
;el carácter '%' indica el fin del mapa

boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
boton_bg_color	db 		0

;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'



;Bola
bola_col		db 		ini_columna 	 	;columna de la bola
bola_ren		db 		ini_renglon-1 		;renglón de la bola
bola_pend 		db 		1 		;pendiente de desplazamiento de la bola
bola_rap 		dw 		1		;rapidez de la bola ////modificada a 1, el original es 2
bola_dir		db 		3 		;dirección de la bola. 0 izquierda-abajo, 1 derecha-abajo, 2 izquierda-arriba, 3 derecha-arriba
bola_dir_x		db		2		;dirección en x de la bola 
bola_dir_y		db		1		;dirección en y de la bola



;variables nuevas para el archivo de hi-score
filename        db      "hiscore.dat", 0   ; Nombre del archivo
filehandle      dw      ?                  ; Manejador del archivo

;variables cadenas que se necesitan para mostrar e puntaje
titulo 			db 		"BRICKS"
scoreStr        db     "SCORE"
hiscoreStr      db     "HI-SCORE"
livesStr 		db		"LIVES"
blank           db     "     "

;Variables para control de botones
boton_pausa      db 0   ; 0=no presionado, 1=presionado
boton_reinicio   db 0   ; 0=no presionado, 1=presionado
boton_play		db	0	; 0 =no presionado, 1 = presionado
;Valores para la posición de los controles e indicadores dentro del juego
;Lives
lives_col 		equ  	lim_derecho+7
lives_ren 		equ  	4

;Constantes
;Scores
hiscore_ren     equ    11
hiscore_col     equ    lim_derecho+7
score_ren       equ    13
score_col       equ    lim_derecho+7

;Constante para posicion de textos
;Scores
hiscore_ren     equ    11
hiscore_col     equ    lim_derecho+7
score_ren       equ    13
score_col       equ    lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+15
stop_ren 		equ 	19
stop_izq 		equ 	stop_col-1
stop_der 		equ 	stop_col+1
stop_sup 		equ 	stop_ren-1
stop_inf 		equ 	stop_ren+1

;Botón PAUSE
pause_col 		equ 	lim_derecho+25
pause_ren 		equ 	19
pause_izq 		equ 	pause_col-1
pause_der 		equ 	pause_col+1
pause_sup 		equ 	pause_ren-1
pause_inf 		equ 	pause_ren+1

;Botón PLAY
play_col 		equ 	lim_derecho+35
play_ren 		equ 	19
play_izq 		equ 	play_col-1
play_der 		equ 	play_col+1
play_sup 		equ 	play_ren-1
play_inf 		equ 	play_ren+1


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

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
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

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm


;//////////////////////////////
;////////MACROS AGREGADAS//////
;//////////////////////////////


    .code
inicio: 
    inicializa_ds_es
	clear
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'

imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz
	muestra_cursor_mouse 	;hace visible el cursor del mouse
	
;En "mouse_no_clic" se revisa que el boton izquierdo del mouse no esté presionado
;Si el botón está suelto, continúa a la sección "mouse"
;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
conversion_mouse:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x

	;Si el mouse fue presionado en el renglon 19
	;se va a revisar si fue el boton play o el stop
	cmp dx, 19

	jge mas_botones

	jmp mouse_no_clic
boton_x:
	jmp boton_x1

;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
	cmp cx,76
	jge boton_x2
	jmp mouse_no_clic
boton_x2:
	cmp cx,78
	jbe boton_x3
	jmp mouse_no_clic
boton_x3:
	;Se cumplieron todas las condiciones
	jmp salir

mas_botones:
	cmp dx, 20
	jbe mas_botones1
	jmp mouse_no_clic

mas_botones1:
	call COMPROBAR_BOTON_PLAY
	cmp [boton_play], 1
	je jugar
	call COMPROBAR_BOTON_STOP
	cmp [boton_reinicio], 1
	je reinicio_detectado
	jmp mouse_no_clic

;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

	;obtener ticks iniciales
	mov ah, 00h 
	int 1Ah		;	CX:DX = ticks iniciales
	mov ticks, dx 

start_game:
	cmp [boton_pausa], 1
	jne no_hubo_pausa
	jmp mouse

no_hubo_pausa:
	call REINICIAR_JUEGO
	call IMPRIME_LIVES
	jmp mouse

;"ciclo" para que salga hasta que se presione la tecla esc
jugar:
	mov [status], 1
	mov [boton_play], 0
	mov [boton_reinicio], 0
	mov [boton_pausa], 0

restart_game: 
	; Verificar si se presionó botón reinicio
	cmp [boton_reinicio], 1
	jne no_reiniciar
	jmp reinicio_detectado
	
no_reiniciar:
	;verificamos la entrada del jugador
	mov ah, 01h					;función hay tecla disponible
	int 16h 
	jz no_tecla		;si no hay tecla, salta
	
	;cmp [status], 1
	;je jugar

tecla_presionada:
	call MOVER_JUGADOR	
	cmp end_game, 1				;comprobamos si se presionó la tecla esc
	je salir					;si end_game == 1 => saltamos a la etiqueta salir

no_tecla:
	call MOVIMIENTO_BOLA 
	cmp [status], 0		;si se acabaron las vidas
	je reinicio_detectado
	cmp [status], 2		;si se perdió una vida
	je pausa_detectada

	call COMPROBAR_BOTON_PAUSE
	cmp [boton_pausa], 1
	je pausa_detectada

	jmp jugar



pausa_detectada:
	call IMPRIME_LIVES
	cmp [boton_pausa], 1
	je pause_presionado
	cmp [status], 2
	je perdio_vida

pause_presionado:
	jmp start_game

perdio_vida:
	call REINICIAR_JUEGO
	jmp start_game

reinicio_detectado:
	call REINICIAR_JUEGO
	;reiniciar_true:	
	;	mov ah, 00h
	;	int 16h
	;	cmp al, "r"
	;	jne reiniciar_true
	call BORRA_LIVES
	mov [player_lives], 3
	call IMPRIME_LIVES
	;mov [status], 0
	call VACIAR_BUFFER_TECLADO
	jmp start_game

;tecla_presionada:
;
;	call MOVER_JUGADOR	
;	cmp end_game, 1				;comprobamos si se presionó la tecla esc
;	je salir					;si end_game == 1 => saltamos a la etiqueta salir
;
;	call MOVIMIENTO_BOLA 
;	cmp [boton_reinicio], 1		;si se acabaron las vidas
;	je reinicio_detectado
;	cmp [boton_pausa], 1		;si se perdió una vida
;	je pausa_detectada
;
;	
;
;
	;jmp jugar

salir: 
	CALL GUARDAR_HISCORE
	clear
    mov ax, 4C00h
    int 21h


;procedimientos

DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Limite mouse
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cAmarillo,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1 		
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior 
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cAmarillo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cAmarillo,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],6,cAmarillo,bgNegro

		call IMPRIME_TEXTOS

		call IMPRIME_BOTONES

		call IMPRIME_BRICKS

		call IMPRIME_DATOS_INICIALES

		call IMPRIME_SCORES

		call IMPRIME_LIVES
		
		call INICIALIZA_MOUSE

		call CARGAR_HISCORE

		call IMPRIME_HISCORE
		
		call BORRA_BOLA

		call IMPRIME_BOLA

		call IMPRIME_JUGADOR


		ret
	endp

IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d		;Carácter '■'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],stop_ren 	;Renglón en "stop_ren"
		mov [boton_columna],stop_col 	;Columna en "stop_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PAUSE
		mov [boton_caracter],19d 		;Carácter '‼'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],pause_ren 	;Renglón en "pause_ren"
		mov [boton_columna],pause_col 	;Columna en "pause_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PLAY
		mov [boton_caracter],16d  		;Carácter '►'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],play_ren 	;Renglón en "play_ren"
		mov [boton_columna],play_col 	;Columna en "play_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		ret
	endp

IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		;imprime la barra del jugador
		;borra la posición actual, luego se reinicializa la posición y entonces se vuelve a imprimir
		call BORRA_JUGADOR
		mov [player_col], ini_columna
		mov [player_ren], ini_renglon
		call IMPRIME_JUGADOR

		;imprime bola
		;borra la posición actual, luego se reinicializa la posición y entonces se vuelve a imprimir
		call BORRA_BOLA
		mov [bola_col], ini_columna
		mov [bola_ren], ini_renglon-1
		call IMPRIME_BOLA

		ret
	endp

IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
	


;Inicializa variables del juego
DATOS_INICIALES proc
	mov [player_score],0
	mov [player_lives], 3
	ret
endp

;Imprime los caracteres ☻ que representan vidas. Inicialmente se imprime el número de 'player_lives'
IMPRIME_LIVES proc
	xor cx,cx
	mov di,lives_col+20
	mov cl,[player_lives]
	imprime_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 2d,cCyanClaro,bgNegro
		add di,2
		pop cx
		loop imprime_live
		ret
endp

BORRA_LIVES proc
	xor cx,cx
	mov di,lives_col+20
	mov cl,[player_lives]
	cmp cl, 0
	je contador_cero
	borra_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 20h,cNegro,bgNegro
		add di,2
		pop cx
		loop borra_live
		ret
	contador_cero:
		ret
endp

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

		call COMPROBAR_BOTON_PAUSE
		cmp [boton_pausa], 1
		je fin_movimiento
		;Botón P (Pausa)
		;cmp al, "p"
		;je pausar_juego
		;Botón R (Reinicio)
		;cmp al, "r"
		;je reiniciar_game
		;comprueba si se presionó la tecla esc, cambiar esto para que funcione
		;con el botón cuando se implemente
		;cmp al, 1Bh
		;je terminar_juego
		;jmp fin_movimiento

		

		;Sección para pausar el juego
		pausar_juego:
			xor [status], 1      ; Alternar entre 0 y 1
			jmp fin_movimiento
		
		;NUEVO: Sección para reiniciar el juego
		reiniciar_game:
			mov [boton_reinicio], 1
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
		cmp [player_col], lim_izquierdo + 2	;player_col < lim_izquierdo
		
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
		cmp [player_col], lim_derecho - 2	;player_col > lim_derecho

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
			;Comprobamos si está tocando el fondo
			mov cl, [lim_inferior]
			cmp cl, [bola_ren]
			je quitar_vida
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

		quitar_vida:
			call BORRA_LIVES
			dec [player_lives]
			;mov [status], 1
			;si no quedan vidas
			cmp [player_lives], 0	
			je no_vidas
			;si aun quedan vidas
			cmp [player_lives], 0
			ja hay_vidas
			

		no_vidas:
			;mov [boton_reinicio], 1 	;detenemos el juego
			mov [status], 0				
			mov ah, 00h
			ret

		hay_vidas:
			;mov [boton_pausa], 1 	;ponemos una pausa condicional despues de perder una vida
			mov [status], 2
			mov ah, 00h
			ret

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
			
			; Si no hubo colisión inferior pasamos a la verificación lateral
			jmp verificar_izquierda

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
    mov [col_aux], dl   ;guardamos la columna donde fue la colisión
    mov [ren_aux], dh   ;guardamos el renglón donde fue la colisión
    mov ch, ah          ;guardamos el color que se detectó
    
    ; Calcular posición relativa dentro del brick (0-4)
    mov al, [col_aux]
    xor ah, ah          ; AX = col_aux
    mov bl, 5
    dec al              ;Ajuste porque columnas inician en 1
    div bl              ;AX / BL -> = índice de ladrillo, AH = offset
    mul bl              ;AL = AL * 5 -> inicio relativo desde 0
    inc al              ;+1 para compensar la columna base (1)
    mov [col_aux], al   ;[col_aux] = inicio del ladrillo colisionado

    ;Comparamos el color del brick para determinar el nivel de la colisión
    cmp ch, cAzul       ;colisión nivel 3 -> nivel 2
    je nivel_2
    
    cmp ch, cVerde      ;colisión nivel 2 -> nivel 1
    je nivel_1
    
    cmp ch, cRojo       ;colisión nivel 1 -> borrar Brick (pintar de negro)
    je borra_brick

    jmp fin_cambio

    nivel_2:
        ; Incrementar puntaje por golpear un brick de nivel 3
        add word ptr [player_score], 30
        mov [brick_color], cVerde
        jmp imprimir_brick

    nivel_1:
        ; Incrementar puntaje por golpear un brick de nivel 2
        add word ptr [player_score], 20
        mov [brick_color], cRojo
        jmp imprimir_brick

    borra_brick:
        ; Incrementar puntaje por golpear un brick de nivel 1
        add word ptr [player_score], 10
        mov [brick_color], cNegro
        jmp imprimir_brick 

    imprimir_brick:
        ; Guardar coordenadas actuales del brick
        push ax
        push bx
        push cx
        push dx
        
        ; Guardar valores de las variables en registros de 8 bits
        mov cl, [col_aux]  ; Usar CL para guardar col_aux (8 bits)
        mov ch, [ren_aux]  ; Usar CH para guardar ren_aux (8 bits)
        
        ; Imprimir el brick con el color correspondiente
        call PRINT_BRICK
        
        ; Actualizar puntaje más alto si es necesario
        call ACTUALIZA_HISCORE
        ; Actualizar visualización de puntajes
        call BORRA_SCORES
        call IMPRIME_SCORES
        
        ; Restaurar coordenadas del brick
        mov [col_aux], cl
        mov [ren_aux], ch
        
        pop dx
        pop cx
        pop bx
        pop ax

    fin_cambio:
        ret 
endp

;Procedimiento para reiniciar el juego
REINICIAR_JUEGO proc
	;Borramos la posicion de la bola y el jugador para evitar artefactos
	;Al reiniciar el juego
	call BORRA_JUGADOR
	call BORRA_BOLA
	; Restaurar posición inicial
	mov [player_col], ini_columna
	mov [player_ren], ini_renglon
	mov [bola_col], ini_columna
	mov [bola_ren], ini_renglon-1
	mov [bola_dir], 3
	
	; Reiniciar puntaje 
	mov [player_score], 0
	
	; Reiniciar bricks
	call IMPRIME_BRICKS
	
	
	
	; Actualizar pantalla
	call BORRA_BOLA
	call IMPRIME_BOLA
	call BORRA_JUGADOR
	call IMPRIME_JUGADOR
	call BORRA_SCORES
	call IMPRIME_SCORES
	
	

	; Reiniciar estado del botón
	mov [boton_reinicio], 0
	
	

	ret
endp


;Manejo del puntaje
; Procedimiento para actualizar HI-SCORE si es necesario
ACTUALIZA_HISCORE proc
    mov ax, [player_score]
    cmp ax, [player_hiscore]
    jle fin_hiscore     ; Si score <= hiscore, no actualizamos
    
    ; Si score > hiscore, actualizamos el hiscore
    mov [player_hiscore], ax
    call GUARDAR_HISCORE
    
    fin_hiscore:
        ret
endp

; Procedimiento para mostrar textos "SCORE" y "HI-SCORE"
IMPRIME_TEXTOS proc
	;Imprime cadena "LIVES"
	posiciona_cursor lives_ren,lives_col
	imprime_cadena_color livesStr,5,cGrisClaro,bgNegro

    ;Imprime cadena "SCORE"
    posiciona_cursor score_ren, score_col
    imprime_cadena_color scoreStr, 5, cGrisClaro, bgNegro

    ;Imprime cadena "HI-SCORE"
    posiciona_cursor hiscore_ren, hiscore_col
    imprime_cadena_color hiscoreStr, 8, cGrisClaro, bgNegro
    ret
endp

; Procedimiento para imprimir scores (tanto el actual como el hi-score)
IMPRIME_SCORES proc
    call IMPRIME_SCORE
    call IMPRIME_HISCORE
    ret
endp

; Procedimiento para imprimir el score actual
IMPRIME_SCORE proc
    mov [ren_aux], score_ren
    mov [col_aux], score_col+20
    mov bx, [player_score]
    call IMPRIME_BX
    ret
endp

; Procedimiento para imprimir el hi-score
IMPRIME_HISCORE proc
    mov [ren_aux], hiscore_ren
    mov [col_aux], hiscore_col+20
    mov bx, [player_hiscore]
    call IMPRIME_BX
    ret
endp

; Procedimiento para borrar los scores de la pantalla (para actualización)
BORRA_SCORES proc
    call BORRA_SCORE
    call BORRA_HISCORE
    ret
endp

; Procedimiento para borrar el score actual de pantalla
BORRA_SCORE proc
    posiciona_cursor score_ren, score_col+20
    imprime_cadena_color blank, 5, cBlanco, bgNegro
    ret
endp

; Procedimiento para borrar el hi-score de pantalla
BORRA_HISCORE proc
    posiciona_cursor hiscore_ren, hiscore_col+20
    imprime_cadena_color blank, 5, cBlanco, bgNegro
    ret
endp

; Procedimiento para imprimir un valor numérico (en BX) en pantalla
IMPRIME_BX proc
    mov ax, bx
    mov cx, 5
	div10:
		xor dx, dx
		div [diez]
		push dx
		loop div10
		mov cx, 5
	imprime_digito:
		mov [conta], cl
		posiciona_cursor [ren_aux], [col_aux]
		pop dx
		or dl, 30h
		imprime_caracter_color dl, cBlanco, bgNegro
		xor ch, ch
		mov cl, [conta]
		inc [col_aux]
		loop imprime_digito
		ret
endp

;--- Procedimientos para guardar/cargar hi-score ---
GUARDAR_HISCORE proc
    ; Abrir archivo (crear/sobrescribir)
    mov ah, 3Ch
    mov cx, 0
    lea dx, filename
    int 21h
    jc error_guardar
    mov [filehandle], ax

    ; Escribir hi-score (2 bytes)
    mov ah, 40h
    mov bx, [filehandle]
    mov cx, 2
    lea dx, player_hiscore
    int 21h
    jc error_guardar

    ; Cerrar archivo
    mov ah, 3Eh
    mov bx, [filehandle]
    int 21h
    ret

	error_guardar:
		; Opcional: Mostrar mensaje de error
		ret
endp

CARGAR_HISCORE proc
    ; Abrir archivo (lectura)
    mov ah, 3Dh
    mov al, 0
    lea dx, filename
    int 21h
    jc error_cargar
    mov [filehandle], ax

    ; Leer hi-score 
    mov ah, 3Fh
    mov bx, [filehandle]
    mov cx, 2
    lea dx, player_hiscore
    int 21h
    jc error_cargar

    ; Cerrar archivo
    mov ah, 3Eh
    mov bx, [filehandle]
    int 21h
    ret

	error_cargar:
		; Si no existe el archivo, inicializar hi-score a 0
		mov [player_hiscore], 0
		ret
endp


;/////////////////////////////////////////////////////////
;//////// Inicialización y restricción del mouse//////////
;/////////////////////////////////////////////////////////

INICIALIZA_MOUSE proc
    ; Inicializar mouse
	lee_mouse
    ; Verificar si el mouse está instalado
    comprueba_mouse
    
    ; Mostrar puntero del mouse
	muestra_cursor_mouse
    
    ; Establecer límites horizontales (en píxeles)
    ; Columna 31 = 31 * 8 = 248 píxeles
    ; Columna 79 = 79 * 8 = 632 píxeles
   	mov ax, 7
    mov cx, 248     ; Límite izquierdo (columna 31)
    mov dx, 632     ; Límite derecho (columna 79)
    int 33h
    
    ; Establecer límites verticales (en píxeles)
    ; Renglón 0 = 0 * 8 = 0 píxeles
    ; Renglón 24 = 24 * 8 = 192 píxeles
    mov ax, 8
    mov cx, 0       ; Límite superior (renglón 0)
    mov dx, 192     ; Límite inferior (renglón 24)
    int 33h

endp 

;////////////////////////////////////////////////////////
;///////Procedimientos para manejar los botones//////////
;////////////////////////////////////////////////////////

COMPROBAR_BOTON_STOP proc
	mouse_no_clic_stop:
		lee_mouse
		test bx,0001h
		jnz mouse_no_clic_stop

	mouse_stop:
		lee_mouse

	conversion_mouse_stop:
		mov ax,dx 			
		div [ocho] 			
		xor ah,ah 			
		mov dx,ax 			
		mov ax,cx 			
		div [ocho] 			

		xor ah,ah 			
		mov cx,ax 			

		;Aquí se revisa si se hizo clic en el botón izquierdo
		test bx,0001h 		
		jz mouse_stop	

	;El boton stop [■] está contenido en los renglones 43 y 47, y en las columnas 18 y 20
	cmp dx, 44
	jge comprueba_columna_stop

	comprueba_columna_stop:
		cmp cx, 19
		jge limite_izquierdo_stop

	jmp mouse_no_clic_stop

	
	limite_izquierdo_stop:
		cmp cx, stop_izq
		jge limite_derecho_stop
		ret
	limite_derecho_stop:
		cmp cx, stop_der
		jbe limite_sup_stop
		ret
	limite_sup_stop:
		cmp dx, stop_sup
		jge limite_inf_stop
		ret
	limite_inf_stop:
		cmp dx, stop_inf
		jbe boton_stop_detectado
		ret
	boton_stop_detectado:
		mov [boton_reinicio], 1
		ret
endp

COMPROBAR_BOTON_PAUSE proc

	mouse_no_clic_pause:
		lee_mouse
		test bx,0001h
		jz fin_comprobar_pause

	mouse_pause:
		lee_mouse

	conversion_mouse_pause:
		mov ax,dx 			
		div [ocho] 			
		xor ah,ah 			
		mov dx,ax 			
		mov ax,cx 			
		div [ocho] 			

		xor ah,ah 			
		mov cx,ax 			

		;Aquí se revisa si se hizo clic en el botón izquierdo
		test bx,0001h 		
		jz mouse_pause	

	;El boton pausa ["!!"] está contenido en los renglones 53 y 57, y en las columnas 18 y 20
	cmp dx, 54
	jge comprueba_columna_pause

	comprueba_columna_pause:
		cmp cx, 19
		jge limite_izquierdo_pause

		jmp mouse_no_clic_pause
	
	limite_izquierdo_pause:
		cmp cx, pause_izq
		jge limite_derecho_pause
		ret
	limite_derecho_pause:
		cmp cx, pause_der
		jbe limite_sup_pause
		ret
	limite_sup_pause:
		cmp dx, pause_sup
		jge limite_inf_pause
		ret
	limite_inf_pause:
		cmp dx, pause_inf
		jbe boton_pause_detectado
		ret
	boton_pause_detectado:
		mov [boton_pausa], 1
		mov [boton_play], 0
	
	fin_comprobar_pause:
		ret
endp

COMPROBAR_BOTON_PLAY proc
	mouse_no_clic_play:
		lee_mouse
		test bx,0001h
		jnz mouse_no_clic_play

	mouse_play:
		lee_mouse

	conversion_mouse_play:
		mov ax,dx 			
		div [ocho] 			
		xor ah,ah 			
		mov dx,ax 			
		mov ax,cx 			
		div [ocho] 			

		xor ah,ah 			
		mov cx,ax 			

		;Aquí se revisa si se hizo clic en el botón izquierdo
		test bx,0001h 		
		jz mouse_play	

	;El boton play [►] está contenido en los renglones 63 y 67, y en las columnas 18 y 20
	cmp dx, 64
	jge comprueba_columna_play

	comprueba_columna_play:
		cmp cx, 19
		jge limite_izquierdo_play

		jmp mouse_no_clic_play
	
	limite_izquierdo_play:
		cmp cx, play_izq
		jge limite_derecho_play
		ret
	limite_derecho_play:
		cmp cx, play_der
		jbe limite_sup_play
		ret
	limite_sup_play:
		cmp dx, play_sup
		jge limite_inf_play
		ret
		limite_inf_play:
		cmp dx, play_inf
		jbe boton_play_detectado
		ret
	boton_play_detectado:
		mov [status], 1
		mov [boton_play], 1
		mov [boton_pausa], 0
		call VACIAR_BUFFER_TECLADO
		ret
endp


VACIAR_BUFFER_TECLADO proc
	vaciar_b_tec:
		mov ah, 0001h
		int 16h
		jz fin_vaciar_b_tec

		mov ah, 00h
		int 16h
		jmp vaciar_b_tec
	
	fin_vaciar_b_tec:
		ret

endp



end inicio; fin del programa