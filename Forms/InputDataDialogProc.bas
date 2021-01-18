#include "InputDataDialogProc.bi"
#include "DisplayError.bi"
#include "OutputDataDialogProc.bi"
#include "Resources.RH"

Const DIALOGBOXPARAM_ERRORSTRING = __TEXT("Failed to show OutputDataDialog")

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
					Dim DialogBoxParamResult As INT_PTR = DialogBoxParam( _
						GetModuleHandle(NULL), _
						MAKEINTRESOURCE(IDD_DLG_OUTPUTDATA), _
						hwndDlg, _
						@OutputDataDialogProc, _
						Cast(LPARAM, 0) _
					)
					If DialogBoxParamResult = -1 Then
						DisplayError(GetLastError(), DIALOGBOXPARAM_ERRORSTRING)
						EndDialog(hwndDlg, 0)
					End If
					
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
