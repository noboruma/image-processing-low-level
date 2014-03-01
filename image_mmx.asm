; IMAGE.ASM
;
; MI01 - TP Assembleur 2 a 5
;
; Realise le traitement d'une image 32 bits. 

.686
; Instructions MMX
.MMX
.MODEL FLAT, C

.DATA
	
.CODE

; **********************************************************************
; Sous-programme _process_image_asm 
; 
; Realise le traitement d'une image 32 bits.
;
; Entrees sur la pile : Largeur de l'image (entier 32 bits)
;			Hauteur de l'image (entier 32 bits)
;			Pointeur sur l'image source (depl. 32 bits)
;			Pointeur sur l'image tampon 1 (depl. 32 bits)
;			Pointeur sur l'image tampon 2 (depl. 32 bits)
;			Pointeur sur l'image finale (depl. 32 bits)
; **********************************************************************

PUBLIC		process_image_mmx

process_image_mmx	PROC NEAR		; Point d'entree du sous programme
		
		push    ebp
		mov     ebp, esp

		push    ebx
		push    esi
		push    edi
		
		mov     ecx, [ebp + 8]		; biWidth
		imul    ecx, [ebp + 12]		; biWidth * biHeight

		mov     esi, [ebp + 16]		; img_src
		mov     edi, [ebp + 20]		; img_tmp1

		;*****************************************************************
		;*****************************************************************
		
		PUSH EAX					; sauvegarde des parametres
		PUSH EBX					; 
		PUSH EDX					;
		
		MOV EAX, 4D961Dh		; On initiation EAX avec les constantes
		MOVD MM1, EAX			; On place ces constantes dans MM1
		PUNPCKLBW MM1, MM1		; On reparti les constantes dans les Words
		PSRLW MM1, 8			; On decale chaque composante a droite pour les calculs
		
traitement:

		DEC ECX					; On passe au pixel precedent (decalage au premier tour)
		
		MOV EAX, [ESI+ECX*4]	; Recuperation des 4 bytes composant un pixel
		MOVD MM0, EAX			; Chargement des 4 bytes dans un registres MMX (de 64 bits)
		PUNPCKLBW MM0, MM0		; tranformation des 4 bytes en 4 Words dans le meme registre MMX 
		PSRLW MM0, 8			; Decalage d'un byte vers la droite des donnees contenus dans chaque Word
		PMADDWD MM0, MM1		; Multiplication et addition entre les Words correspondant entre les registres MM0 et MM1 (poids faible)
		MOVD EAX,MM0			; On stocke la partie basse de MM0
		MOVD MM2, EAX			; On met la partie basse de MM0 dans MM2
		PSRLQ MM0, 32			; On shift de 32 bits vers la droite (on shift la partie haute sur la partie basse) dans MM0
		PADDD MM0,MM2			; On ajoute la partie basse de MM0 avec MM2 (on realise la derniere addition)
		PSRLQ MM0, 8			; On place la valeur dans le pixel bleu (on decale pour compenser le decalage provoque avec les constantes entieres)
		

		;MOV EDX, [ESI + ECX*4]		; on recupere l'adresse du pixel
		
		;MOV EAX, EDX				; on travaille sur EAX dans lequel on copie le pixel
		;AND EAX, 000000FFh			; masque pour B
		;IMUL EAX, 29				; multiplication 0.114*256
		;MOV EBX, EAX				; stockage dans EBX
		
		;MOV EAX, EDX				; on travaille sur EAX dans lequel on copie le pixel
		;AND EAX, 0000FF00h			; masque pour G
		;SHR EAX, 8					; on decale vers le bleu
		;IMUL EAX, 150				; on multiplie 0.587*256
		;ADD EBX, EAX				; EBX = B + G (decale)
		
		;MOV EAX, EDX				; on travaille sur EAX dans lequel on copie le pixel
		;AND EAX, 00FF0000h			; masque pour R
		;SHR EAX, 16					; on decale vers le bleu
		;IMUL EAX, 77				; on multiplie par 0.299*256
		;ADD EBX, EAX				; EBX = B + G + R
		
		SHR EBX, 8					; on supprime le decalage sur EBX (stockage dans le bleu)
		;SHL EBX, 8					; poisson vert
		;SHL EBX, 8					; poisson rouge
		
		MOVD EAX, MM0
		MOV [EDI + ECX*4], EAX		; on enregistre le pixel dans l'image suivante
		CMP ECX, 0
		JNE traitement				; on repete jusqu'au dernier pixel


		
		;*****************************************************************
		;*****************************************************************
		;						TP4
		;*****************************************************************
		;*****************************************************************
		
		; Code pour le compteur lignes
		MOV ECX, [EBP+12]			; ECX <- height
		SUB ECX,2					; ECX <- height-2
		SHL ECX, 16					; on decale sur la gauche
		
		; code pour les adresses des pixels a traiter
		MOV ESI, EDI				; ESI <- img_tmp1
		MOV EDI, [EBP+24]			; EDI <- img_tmp2
		MOV EBP, [EBP+8]			; EBP <- width
		MOV EAX, EBP				; on recupere la taille d'une ligne
		IMUL EAX, 4					; on multiplie par taille d'un pixel
		ADD EDI, EAX				; on se decale pour eviter la premiere ligne
		ADD EDI, 4					; on se decale pour eviter la premiere colonne
		
		;  ___________
		; |___|___|___| 
		; |___|EDI|___|
		; |ESI|___|___|
		
ligne:
		ADD ECX, EBP				; nouvelle ligne
		SUB ECX, 2					; ECX <- width-2

	colonne:
			
			; CALCUL de Sx
			MOV EAX, [ESI+4]		; multiplication colonne
			IMUL EAX, 2				; negative
			ADD EAX, [ESI]			;
			ADD EAX, [ESI+8]		;
			NEG EAX					; 
			MOV EBX, [ESI+EBP*8+4]	; multiplication colonne
			IMUL EBX, 2				; positive
			ADD EBX, [ESI+EBP*8]	;
			ADD EBX, [ESI+EBP*8+8]	;
			ADD EAX, EBX			; addition des deux colonnes
			CMP EAX, 0				; test pour valeur absolue
			JG Sy
			NEG EAX
			
	Sy:		
			MOV [EDI], EAX			; on stocke temporairement
									; le resultat par Sx
			; Calcul de Sy
			MOV EAX, [ESI+EBP*4]	; multiplication ligne
			IMUL EAX, 2				; negative
			ADD EAX, [ESI]			;
			ADD EAX, [ESI+EBP*8]	;
			NEG EAX					;
			MOV EBX, [ESI+EBP*4+8]	; multiplication ligne
			IMUL EBX, 2				; positive
			ADD EBX, [ESI+8]		;
			ADD EBX, [ESI+EBP*8+8]	;
			ADD EAX, EBX			; addition des deux colonnes
			CMP EAX, 0				; test pour valeur absolue
			JG calculG
			NEG EAX
			
	calculG:
			; on ajoute les deux valeurs absolues
			MOV EBX, [EDI]			; on recupere le masque Sx
			ADD EAX, EBX			; on ajoute les valeurs
			CMP EAX, 255			; si on deborde on prend
			JL saut					; la valeur max = 255
			MOV EAX, 255
			
	saut:
			; on inverse les couleurs
			NEG EAX					; on inverse les "couleurs"
			ADD EAX, 255			;
			
			; Code pour niveau de gris
			MOV EDX, EAX
			SHL EDX, 8
			ADD EAX, EDX
			SHL EDX, 8
			ADD EAX, EDX
			; Fin de code pour niveau de gris
			
			MOV [EDI], EAX			; on renregistre le pixel
	
			
			ADD ESI, 4				; decalage des pixels
			ADD EDI, 4				; pour l'iteration suivante
			DEC ECX					; decremente une colonne
			
			CMP CX, 0				; fin de ligne ?
			JNE colonne
		
		SUB ECX, 10000h				; decremente une ligne
		
		ADD ESI, 8					; saute les deux pixels
		ADD EDI, 8					; a la fin de la ligne
		
		TEST ECX, 0FFFF0000h		; fin des colonnes ?
		JNE ligne
		
		
		POP EDX						; on restaure les paremetres
		POP EBX						;
		POP EAX						;
		      
			
fin:
		emms		
		pop     edi
		pop     esi
		pop     ebx

		pop     ebp

		ret			                ; Retour e la fonction MainWndProc
	
process_image_mmx	ENDP

	  END
