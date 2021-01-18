#include "OutputDataDialogProc.bi"
#include "win\commctrl.bi"
#include "DisplayError.bi"
#include "Resources.RH"

Const C_COLUMNS As Integer = 6

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
