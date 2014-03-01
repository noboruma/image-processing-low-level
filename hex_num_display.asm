; tp2real.asm
;
; MI01 - TP Assembleur 2
;
; Affiche un nombre de 32 bits sous forme lisible

.686
.MODEL	FLAT,C

EXTRN	getchar:NEAR
EXTRN	putchar:NEAR

.DATA
		nombre		dd	-4321Ah		; nombre a convertir
		chaine		db	32 dup(?)	; chaine pour stocker le nombre
		base		dd	30			; base dans laquelle on converti
		chiffres	db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
									; digit de la nouvelle base
		
.CODE

main	PROC

	PUSH EAX						; sauvegarde des registres
	PUSH EBX
	
	MOV EAX,[nombre]				; on stocke le nombre dans EAX
    LEA EBX,[chaine]				; et l'adresse de la chaine dans EBX
    MOV ECX,[base]					; on se sert de ECX pour les divisions par la base
    
	cmp EAX,0						; test pour les nombres negatifs
    JNS boucle						; saut conditionnel si EAX < 0
    
    MOV EDX, '-'					; signe - a afficher
    PUSH EDX						; Parametre de putchar
	CALL putchar					; Appel
	ADD ESP, 4						; Nettoyage des parametres
	MOV ECX,[base]					; on stocke a nouveau la base si elle a ete effacee

	NEG [nombre]					; on est dans le cas d'un nombre negatif donc on inverse en memoire
	MOV EAX, [nombre]				; on recupere sa valeur (positive) dans EAX
    
boucle:
	XOR EDX,EDX						; EDX = 0
	DIV ECX							; EAX = EAX / ECX et EDX = EAX % ECX
	LEA ESI, [chiffres+EDX]			; on recupere l'adresse du caractere
	MOV EDX, [ESI]					; on recupere le digit a l'adresse de contenue dans ESI
	MOV [EBX],EDX					; on le place dans la chaine
	INC EBX							; on se deplace dans la chaine
	CMP EAX,0						; test si EAX = 0
	JNE boucle						; si oui, on sort de la boucle
	
	LEA ESI, [chaine]				; on recupere l'adresse de chaine
	DEC EBX							; on decremente EBX pour neutraliser le dernier INC EBX
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Procedure d'affichage codee dans le TP4                        ;
	; Le fonctionnement est le meme mais la chaine est lue a l'envers;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
suivant:
	MOV EAX, [EBX]			; on parcours la chaine grace a l'adresse dans EBX	
	PUSH EAX				;
	CALL putchar			;
	ADD ESP, 4				;
	DEC EBX					; on prend le digit d'avant
	CMP ESI,EBX				; on compare l'adresse de EBX et celle de chaine
	JBE suivant				; si elle est superieur ou egale on affiche les digits restants
	
	call getchar
	
	POP EBX					; on restaure les parametres
	POP EAX					; 
	
	ret
main	ENDP

end