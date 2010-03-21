DWORD CODE_SIZE = 0;
DWORD CODE_START = 0;
DWORD VAR_START = 0;
static DWORD VAR[4];

void __stdcall InputDcrpt()
{
	__asm
	{
		MOV EAX, offset CodeEnd
		SUB EAX, offset CodeStart
		MOV CODE_SIZE, EAX
		MOV EAX, offset CodeStart
		MOV CODE_START, EAX
		MOV EAX, offset Promenne
		SUB EAX, offset CodeStart
		MOV VAR_START,EAX

		JMP CodeEnd
	}

CodeStart:				//Assembler decryptor//
	__asm
	{
		push ebx
		push ecx
		push edx
		push esi
		push edi
		push ebp

		call Test
Test:
		pop ebp
		sub ebp,offset Test
		push ebp
		mov ecx,offset ImageBase
		mov ebx, [ebp+ecx]
		mov ecx,offset EntryPoint
		mov eax, [ebp+ecx]
		add eax,ebx
		pop ebp

		push eax											//Zacatek decrypt
		mov edx, offset CryptSz
		mov edx, [ebp+edx]

		mov eax, offset CryptStrt
		mov eax, [ebp+eax]
		add eax, ebx
		xor ecx, ecx

dcrpt:														//smycka
		mov ecx, [eax]
		xchg ch, cl
		mov ebx, [eax]
		shr ebx, 16
		xchg bh, bl
		shl ebx, 16
		and ecx, 0x0000FFFF
		or ecx, ebx
		mov [eax], ecx

		sub edx, 4
		add eax, 4
		cmp edx, 0
		jnz dcrpt											//konec smycky

		pop eax												//Konec decrypt

		pop ebp
		pop edi
		pop esi
		pop edx
		pop ecx
		pop ebx
		jmp eax				//jump na puvodni PEP

Promenne:

ImageBase:
		__emit 0x00
		__emit 0x00 
		__emit 0x00
		__emit 0x00

EntryPoint:
		__emit 0x00
		__emit 0x00
		__emit 0x00
		__emit 0x00

CryptStrt:
		__emit 0x00
		__emit 0x00
		__emit 0x00
		__emit 0x00

CryptSz:
		__emit 0x00
		__emit 0x00
		__emit 0x00
		__emit 0x00
	}

CodeEnd:;
}

	using namespace std;						//C++ cryptor//
	ofstream myfile; 
	myfile.open ("example.txt");
		AdrOfSecTable = (DWORD)pImageNT + (sizeof IMAGE_NT_HEADERS);
	*pSection = RvaToSection(pImageNT,pMem,AdrOfSecTable);		//3BCA20
	DWORD *cryptStart = (DWORD *)(pMem + pSection->PointerToRawData);
	DWORD cryptSize = (DWORD)pSection->SizeOfRawData;
	//VAR[2] =  (WORD)cryptStart;	
	VAR[2] =  pImageNT->OptionalHeader.SectionAlignment;
	VAR[3] = cryptSize;
		memcpy((VOID*)(pMem+*PointerToRawData+VAR_START),(VOID*)VAR, sizeof VAR);						//zapsani promennych
	for(unsigned long i = 0; i < cryptSize; i=i+2)
	{
		BYTE change1, change2;
		BYTE pole[6200];

		DWORD *abc = (DWORD *)((BYTE *)cryptStart+i);						//NIC
		DWORD *bac = (DWORD *)((BYTE *)cryptStart+1+i);						//NIC
		BYTE *cab = ((BYTE*)cryptStart+i);						//NIC
		BYTE *cba = ((BYTE*)cryptStart+1+i);						//NIC
		memcpy(&change1, (VOID*)((BYTE *)cryptStart+i), sizeof BYTE);
		if((pSection->SizeOfRawData % 2 == 0) && (i != pSection->SizeOfRawData))
			memcpy(&change2, (VOID*)((BYTE *)cryptStart+1+i), sizeof BYTE);
		memcpy((BYTE*)(cryptStart)+i, (BYTE*)&change2, sizeof BYTE);
		if((pSection->SizeOfRawData % 2 == 0) && (i != pSection->SizeOfRawData))
			memcpy((BYTE*)(cryptStart)+1+i, (BYTE*)&change1, sizeof BYTE);
		//memcpy(&pole[i], (VOID*)((BYTE *)cryptStart+i), sizeof BYTE);						//NIC
		//if(pSection->SizeOfRawData % 2 == 0 && i != (DWORD)pSection->SizeOfRawData)
		//	memcpy(&pole[1+i], (VOID*)((BYTE *)cryptStart+1+i), sizeof BYTE);						//NIC
		if(i == 4000)
			int a = 0;
		//if(i%16==0)
		//	myfile << hex << setw(5) << setfill('0') << i << ": ";
		//	myfile << setw(2) << setfill('0') << hex << (unsigned long)pole[i];
		//	myfile << " ";
		//	myfile << setw(2) << setfill('0') << hex << (unsigned long)pole[i+1];
		//	myfile << " ";

		//	if((i!=0) && ((i+1)%16==0))
		//		myfile << "\n";
	}

	//BYTE *cryptStart = (pMem+*PointerToRawData)/*+(VOID*)(CODE_START), CODE_SIZE*/;

	myfile.close();

	pImageNT->OptionalHeader.AddressOfEntryPoint = *VirtualAddress;

	delete Characteristics;
	delete PointerToRawData;
	delete SizeOfRawData;
	delete VirtualSize;
	delete VirtualAddress;
	delete pSection;
	
	return RealSize;
}