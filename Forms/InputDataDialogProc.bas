#include "InputDataDialogProc.bi"
#include "Resources.RH"

Function InputDataDialogProc( _
		ByVal hwndDlg As HWND, _
		ByVal uMsg As UINT, _
		ByVal wParam As WPARAM, _
		ByVal lParam As LPARAM _
	)As INT_PTR
	
	Select Case uMsg
		
		Case WM_INITDIALOG
			
			
		Case WM_COMMAND
			Select Case LOWORD(wParam)
				
				Case IDOK
					EndDialog(hwndDlg, 1)
					
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
