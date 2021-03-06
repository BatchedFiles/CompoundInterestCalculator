#include "CompoundInterest.bi"
#include "windows.bi"
#include "win\ole2.bi"
#include "win\oleauto.bi"

Function Integer64Division( _
		ByVal LeftValue As LongInt, _
		ByVal RightValue As LongInt _
	)As LongInt
	
	Dim varLeft As VARIANT = Any
	varLeft.vt = VT_I8
	varLeft.llVal = LeftValue
	
	Dim varRight As VARIANT = Any
	varRight.vt = VT_I8
	varRight.llVal = RightValue
	
	Dim varResult As VARIANT = Any
	VariantInit(@varResult)
	
	Dim hr As HRESULT = VarIdiv( _
		@varLeft, _
		@varRight, _
		@varResult _
	)
	If FAILED(hr) Then
		Return 0
	End If
	
	Return varResult.llVal
	
End Function

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
		Dim Balance As LongInt = Initial + Annual
		Dim Revenue As LongInt = Integer64Division(Balance * Interest, 100)
		Dim TaxValue As LongInt = Integer64Division(Revenue * Tax, 100)
		Dim Profit As LongInt = Revenue - TaxValue
		Dim EndingBalance As LongInt = Balance + Profit
		
		pInterestTable[i].OpeningBalance = Initial
		pInterestTable[i].Annual = Annual
		pInterestTable[i].Revenue = Revenue
		pInterestTable[i].TaxValue = TaxValue
		pInterestTable[i].Profit = Profit
		pInterestTable[i].EndingBalance = EndingBalance
		
		Initial = EndingBalance
	Next
End Sub
