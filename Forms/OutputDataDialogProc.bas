#include "OutputDataDialogProc.bi"
#include "win\commctrl.bi"
#include "DisplayError.bi"
#include "Resources.RH"

Const C_COLUMNS As Integer = 7

Dim Shared InterestTable As CompoundInterestArray Ptr
Dim Shared LocalHeap As HANDLE

Declare Function LongIntToStringA Alias "LongIntToStringA"( _
	ByVal li As LongInt _
)As ZString Ptr

#ifndef UNICODE
Declare Function LongIntToString Alias "LongIntToStringA"( _
	ByVal li As LongInt _
)As ZString Ptr
#endif

Declare Function LongIntToStringW Alias "LongIntToStringW"( _
	ByVal li As LongInt _
)As WString Ptr

#ifdef UNICODE
Declare Function LongIntToString Alias "LongIntToStringW"( _
	ByVal li As LongInt _
)As WString Ptr
#endif

#ifdef UNICODE
Function LongIntToStringW Alias "LongIntToStringW"( _
		ByVal li As LongInt _
	)As WString Ptr
	
	Const IntegerToStringBufferLength As Integer = 1024 - 1
	
	Dim lpData As WString Ptr = HeapAlloc( _
		LocalHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(WString) * (IntegerToStringBufferLength + 1) _
	)
	If lpData = NULL Then
		Return NULL
	End If
	
	' #ifdef __FB_64BIT__
		_i64tow(li, lpData, 10)
	' #else
		' _itow(Cint(p), @wstrPointer, 10)
	' #endif
	
	Return lpData
	
End Function
#endif

Function OutputDataDialogProc( _
		ByVal hwndDlg As HWND, _
		ByVal uMsg As UINT, _
		ByVal wParam As WPARAM, _
		ByVal lParam As LPARAM _
	)As INT_PTR
	
	Select Case uMsg
		
		Case WM_INITDIALOG
			Dim hListInterest As HWND = GetDlgItem(hwndDlg, IDC_LVW_INTEREST)
			Dim hInst As HINSTANCE = GetModuleHandle(NULL)
			InterestTable = Cast(CompoundInterestArray Ptr, lParam)
			LocalHeap = HeapCreate(HEAP_NO_SERIALIZE, 0, 0)
			ListView_SetExtendedListViewStyle(hListInterest, LVS_EX_FULLROWSELECT Or LVS_EX_GRIDLINES)
			
			Scope
				Dim szSummary(265) As TCHAR = Any
				LoadString(hInst, IDS_SUMMARY, @szSummary(0), 264)
				
				Dim buffer(4096) As TCHAR = Any
				wsprintf( _
					@buffer(0), _
					@szSummary(0), _
					InterestTable->OverralLength, _
					InterestTable->pInterestTable[InterestTable->OverralLength - 1].EndingBalance, _
					InterestTable->pInterestTable[InterestTable->OverralLength - 1].Revenue, _
					InterestTable->pInterestTable[InterestTable->OverralLength - 1].Profit _
				)
				
				SetDlgItemText(hwndDlg, IDC_EDT_DESCRIPTION, @buffer(0))
			End Scope
			
			Scope
				Dim szText(265) As TCHAR = Any
				Dim Column As LVCOLUMN = Any
				Column.mask = LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
				Column.fmt = LVCFMT_RIGHT
				Column.cx = 100
				Column.pszText = @szText(0)
				
				For i As Integer = 0 To C_COLUMNS - 1
					LoadString(hInst, IDS_YEAR + i, @szText(0), 264)
					Column.iSubItem = i
					ListView_InsertColumn(hListInterest, i, @Column)
				Next
			End Scope
			
			Scope
				Dim lvI As LVITEM = Any
				lvI.pszText = LPSTR_TEXTCALLBACK
				lvI.mask = LVIF_TEXT Or LVIF_STATE ' Or LVIF_IMAGE
				lvI.stateMask = 0
				lvI.iSubItem = 0
				lvI.state = 0
				
				For i As Integer = 0 To InterestTable->OverralLength - 1
					lvI.iItem  = i
					' lvI.iImage = i
					ListView_InsertItem(hListInterest, @lvI)
				Next
			End Scope
			
		Case WM_NOTIFY
			Dim p As LPNMHDR = Cast(LPNMHDR, lParam)
			
			Select Case p->code
				Case LVN_GETDISPINFO
					Dim plvdi As NMLVDISPINFO Ptr = Cast(NMLVDISPINFO Ptr, lParam)
					
					Select Case plvdi->item.iSubItem
						' NOTE: In addition to setting pszText to point to the item text, you could 
						' copy the item text into pszText using StringCchCopy. For example:
						' 
						' StringCchCopy(plvdi->item.pszText, 
						'     plvdi->item.cchTextMax, 
						'     rgPetInfo[plvdi->item.iItem].szKind);
						Case 0
							plvdi->item.pszText = LongIntToString(plvdi->item.iItem + 1)
							
						Case 1
							' Dim OpeningBalance As LongInt ' Начальное сальдо
							plvdi->item.pszText = LongIntToString(InterestTable->pInterestTable[plvdi->item.iItem].OpeningBalance)
							
						Case 2
							' Dim Annual As LongInt         ' Довложение за период
							plvdi->item.pszText = LongIntToString(InterestTable->pInterestTable[plvdi->item.iItem].Annual)
							
						Case 3
							' Dim Revenue As LongInt        ' Доход за период
							plvdi->item.pszText = LongIntToString(InterestTable->pInterestTable[plvdi->item.iItem].Revenue)
							
						Case 4
							' Dim Tax As LongInt            ' Налог
							plvdi->item.pszText = LongIntToString(InterestTable->pInterestTable[plvdi->item.iItem].TaxValue)
							
						Case 5
							' Dim Profit As LongInt         ' Чистая прибыль за период
							plvdi->item.pszText = LongIntToString(InterestTable->pInterestTable[plvdi->item.iItem].Profit)
							
						Case 6
							' Dim EndingBalance As LongInt  ' Конечное сальдо
							plvdi->item.pszText = LongIntToString(InterestTable->pInterestTable[plvdi->item.iItem].EndingBalance)
							
						Case Else
							
					End Select
					
			End Select
			
		Case WM_COMMAND
			Select Case LOWORD(wParam)
				
				Case IDCANCEL
					HeapDestroy(LocalHeap)
					EndDialog(hwndDlg, 0)
					
			End Select
			
		Case WM_CLOSE
			HeapDestroy(LocalHeap)
			EndDialog(hwndDlg, 0)
			
		Case Else
			Return False
			
	End Select
	
	Return True
	
End Function
