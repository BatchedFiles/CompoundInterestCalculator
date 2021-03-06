#include "OutputDataDialogProc.bi"
#include "win\commctrl.bi"
#include "DisplayError.bi"
#include "Resources.RH"

Const C_COLUMNS As Integer = 7

Declare Function LongIntToStringA Alias "LongIntToStringA"( _
	ByVal hHeap As HANDLE, _
	ByVal li As LongInt _
)As ZString Ptr

#ifndef UNICODE
Declare Function LongIntToString Alias "LongIntToStringA"( _
	ByVal hHeap As HANDLE, _
	ByVal li As LongInt _
)As ZString Ptr
#endif

Declare Function LongIntToStringW Alias "LongIntToStringW"( _
	ByVal hHeap As HANDLE, _
	ByVal li As LongInt _
)As WString Ptr

#ifdef UNICODE
Declare Function LongIntToString Alias "LongIntToStringW"( _
	ByVal hHeap As HANDLE, _
	ByVal li As LongInt _
)As WString Ptr
#endif

#ifdef UNICODE
Function LongIntToStringW Alias "LongIntToStringW"( _
		ByVal hHeap As HANDLE, _
		ByVal li As LongInt _
	)As WString Ptr
	
	Const IntegerToStringBufferLength As Integer = 1024 - 1
	
	Dim lpData As WString Ptr = HeapAlloc( _
		hHeap, _
		HEAP_NO_SERIALIZE, _
		SizeOf(WString) * (IntegerToStringBufferLength + 1) _
	)
	If lpData = NULL Then
		Return NULL
	End If
	
	_i64tow(li, lpData, 10)
	
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
			Dim Parameter As OutputDataDialogProcParameter Ptr = Cast(OutputDataDialogProcParameter Ptr, lParam)
			Dim LocalHeap As HANDLE = Parameter->LocalHeap
			
			ListView_SetExtendedListViewStyle(hListInterest, LVS_EX_FULLROWSELECT Or LVS_EX_GRIDLINES)
			
			Scope
				Dim szSummary(265) As TCHAR = Any
				LoadString(hInst, IDS_SUMMARY, @szSummary(0), 264)
				
				Dim buffer(4096) As TCHAR = Any
				wsprintf( _
					@buffer(0), _
					@szSummary(0), _
					Parameter->OverralLength, _
					Parameter->pInterestTable[Parameter->OverralLength - 1].EndingBalance, _
					Parameter->pInterestTable[Parameter->OverralLength - 1].Revenue, _
					Parameter->pInterestTable[Parameter->OverralLength - 1].Profit _
				)
				
				SetDlgItemText(hwndDlg, IDC_EDT_DESCRIPTION, @buffer(0))
			End Scope
			
			Scope
				Dim szText(265) As TCHAR = Any
				
				Dim Column As LVCOLUMN = Any
				With Column
					.mask = LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
					.fmt = LVCFMT_RIGHT
					.cx = 100
					.pszText = @szText(0)
					' .cchTextMax = 0
					' iSubItem as long
					' iImage as long
					' iOrder as long
				End With
				
				For i As Integer = 0 To C_COLUMNS - 1
					LoadString(hInst, IDS_YEAR + i, @szText(0), 264)
					Column.iSubItem = i
					ListView_InsertColumn(hListInterest, i, @Column)
				Next
			End Scope
			
			Scope
				For i As Integer = 0 To Parameter->OverralLength - 1
					Dim Item As LVITEM = Any
					With Item
						.mask = LVIF_TEXT ' Or LVIF_STATE Or LVIF_IMAGE
						.iItem  = i
						.iSubItem = 0
						' .state = 0
						' .stateMask = 0
						.pszText = LongIntToString(LocalHeap, i + 1)
						' .cchTextMax = 0
						' .iImage = i
						' lParam as LPARAM
						' iIndent as long
						' iGroupId as long
						' cColumns as UINT
						' puColumns as PUINT
					End With
					
					ListView_InsertItem(hListInterest, @Item)
					
					' LvItem.iSubItem=i;
					' sprintf(Temp,"SubItem %d",i);
					' LvItem.pszText=Temp;
					' SendMessage(hList,LVM_SETITEM,0,(LPARAM)&LvItem); // Enter text to SubItems
					
					Item.iSubItem = 1
					Item.pszText = LongIntToString(LocalHeap, Parameter->pInterestTable[i].OpeningBalance)
					ListView_SetItem(hListInterest, @Item)
					
					Item.iSubItem = 2
					Item.pszText = LongIntToString(LocalHeap, Parameter->pInterestTable[i].Annual)
					ListView_SetItem(hListInterest, @Item)
					
					Item.iSubItem = 3
					Item.pszText = LongIntToString(LocalHeap, Parameter->pInterestTable[i].Revenue)
					ListView_SetItem(hListInterest, @Item)
					
					Item.iSubItem = 4
					Item.pszText = LongIntToString(LocalHeap, Parameter->pInterestTable[i].TaxValue)
					ListView_SetItem(hListInterest, @Item)
					
					Item.iSubItem = 5
					Item.pszText = LongIntToString(LocalHeap, Parameter->pInterestTable[i].Profit)
					ListView_SetItem(hListInterest, @Item)
					
					Item.iSubItem = 6
					Item.pszText = LongIntToString(LocalHeap, Parameter->pInterestTable[i].EndingBalance)
					ListView_SetItem(hListInterest, @Item)
					
				Next
			End Scope
			
		Case WM_COMMAND
			Select Case LOWORD(wParam)
				
				Case IDCANCEL
					EndDialog(hwndDlg, 0)
					
			End Select
			
		Case WM_CLOSE
			EndDialog(hwndDlg, 0)
			
		Case Else
			Return False
			
	End Select
	
	Return True
	
End Function
