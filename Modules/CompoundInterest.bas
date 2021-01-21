#include "CompoundInterest.bi"

' Function CalculatePrincipal( _
		' ByVal PrincipalSum As Integer, _
		' ByVal Interest As Integer _
	' )As Integer
	
	' Return PrincipalSum * Interest \ 100
	
' End Function

Sub CalculatePrincipal( _
		ByVal pInterestTable As CompoundInterest Ptr, _
		ByVal OverralLength As Integer, _
		ByVal OpeningBalance As LongInt, _
		ByVal Annual As LongInt, _
		ByVal Interest As LongInt, _
		ByVal Tax As LongInt _
	)
	
	Dim Initial As LongInt = OpeningBalance
	
	For i As Integer = 0 To OverralLength - 1
		pInterestTable[i].OpeningBalance = Initial
		pInterestTable[i].Annual = Annual
		pInterestTable[i].Revenue = ((pInterestTable[i].OpeningBalance + Annual) * Interest) \ 100
		pInterestTable[i].Tax = (pInterestTable[i].Revenue * Tax) \ 100
		pInterestTable[i].Profit = pInterestTable[i].Revenue - pInterestTable[i].Tax
		pInterestTable[i].EndingBalance = pInterestTable[i].Profit + pInterestTable[i].OpeningBalance + Annual
		
		Initial = pInterestTable[i].EndingBalance
	Next
End Sub
