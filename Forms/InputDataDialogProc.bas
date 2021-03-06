#include "InputDataDialogProc.bi"
#include "win\shlwapi.bi"
#include "CompoundInterest.bi"
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
					Dim OpeningBalance As LongInt = Any
					Dim OverralLength As LongInt = Any
					Dim Annual As LongInt = Any
					Dim Interest As LongInt = Any
					Dim Tax As LongInt
					
					Scope
						Dim szOpeningBalance(511) As TCHAR = Any
						GetDlgItemText( _
							hwndDlg, _
							IDC_EDT_OPENINGBALANCE, _
							@szOpeningBalance(0), _
							511 _
						)
						StrToInt64Ex(@szOpeningBalance(0), STIF_DEFAULT, @Cast(LONGLONG, OpeningBalance))
					End Scope
					
					Scope
						Dim szOverralLength(511) As TCHAR = Any
						GetDlgItemText( _
							hwndDlg, _
							IDC_EDT_OVERRALLENGTH, _
							@szOverralLength(0), _
							511 _
						)
						StrToInt64Ex(@szOverralLength(0), STIF_DEFAULT, @Cast(LONGLONG, OverralLength))
					End Scope
					
					Scope
						Dim szAnnual(511) As TCHAR = Any
						GetDlgItemText( _
							hwndDlg, _
							IDC_EDT_ANNUAL, _
							@szAnnual(0), _
							511 _
						)
						StrToInt64Ex(@szAnnual(0), STIF_DEFAULT, @Cast(LONGLONG, Annual))
					End Scope
					
					Scope
						Dim szInterest(511) As TCHAR = Any
						GetDlgItemText( _
							hwndDlg, _
							IDC_EDT_INTEREST, _
							@szInterest(0), _
							511 _
						)
						StrToInt64Ex(@szInterest(0), STIF_DEFAULT, @Cast(LONGLONG, Interest))
					End Scope
					
					Scope
						Dim szTax(511) As TCHAR = Any
						GetDlgItemText( _
							hwndDlg, _
							IDC_EDT_TAX, _
							@szTax(0), _
							511 _
						)
						StrToInt64Ex(@szTax(0), STIF_DEFAULT, @Cast(LONGLONG, Tax))
					End Scope
					
					If CInt(OverralLength) > 0 Then
						Dim pInterestTable As CompoundInterest Ptr = HeapAlloc( _
							GetProcessHeap(), _
							HEAP_NO_SERIALIZE, _
							SizeOf(CompoundInterest) * CInt(OverralLength) _
						)
						If pInterestTable <> NULL Then
							CalculatePrincipal( _
								pInterestTable, _
								CInt(OverralLength), _
								OpeningBalance, _
								Annual, _
								Interest, _
								Tax _
							)
							
							Dim Parameter As OutputDataDialogProcParameter Ptr = HeapAlloc( _
								GetProcessHeap(), _
								HEAP_NO_SERIALIZE, _
								SizeOf(OutputDataDialogProcParameter) * CInt(OverralLength) _
							)
							If Parameter <> NULL Then
								Parameter->pInterestTable = pInterestTable
								Parameter->OverralLength = CInt(OverralLength)
								Parameter->LocalHeap =  HeapCreate(HEAP_NO_SERIALIZE, 0, 0)
								
								If Parameter->LocalHeap <> NULL Then
									Dim DialogBoxParamResult As INT_PTR = DialogBoxParam( _
										GetModuleHandle(NULL), _
										MAKEINTRESOURCE(IDD_DLG_OUTPUTDATA), _
										hwndDlg, _
										@OutputDataDialogProc, _
										Cast(LPARAM, Parameter) _
									)
									If DialogBoxParamResult = -1 Then
										DisplayError(GetLastError(), DIALOGBOXPARAM_ERRORSTRING)
										EndDialog(hwndDlg, 0)
									End If
									
									HeapDestroy(Parameter->LocalHeap)
								End If
								
								HeapFree( _
									GetProcessHeap(), _
									HEAP_NO_SERIALIZE, _
									Parameter _
								)
							End If
							
							HeapFree( _
								GetProcessHeap(), _
								HEAP_NO_SERIALIZE, _
								pInterestTable _
							)
						End If
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
