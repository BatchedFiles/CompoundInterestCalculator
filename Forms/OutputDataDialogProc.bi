#ifndef OUTPUTDATADIALOGPROC_BI
#define OUTPUTDATADIALOGPROC_BI

#include "windows.bi"

Declare Function OutputDataDialogProc( _
	ByVal hwndDlg As HWND, _
	ByVal uMsg As UINT, _
	ByVal wParam As WPARAM, _
	ByVal lParam As LPARAM _
)As INT_PTR

#endif
