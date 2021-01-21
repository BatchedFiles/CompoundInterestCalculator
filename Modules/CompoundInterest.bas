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
		pInterestTable[i].OpeningBalance = Initial
		pInterestTable[i].Annual = Annual
		
		' Scope
			' Dim varLeft As VARIANT = Any
			' varLeft.vt = VT_I8
			' varLeft.llVal = (Initial + Annual) * Interest
			
			' Dim varRight As VARIANT = Any
			' varRight.vt = VT_I8
			' varRight.llVal = 100
			
			' Dim varResult As VARIANT = Any
			' VariantInit(@varResult)
			
			' Dim hr As HRESULT = VarIdiv( _
				' @varLeft, _
				' @varRight, _
				' @varResult _
			' )
			
			' pInterestTable[i].Revenue = varResult.llVal ' ((pInterestTable[i].OpeningBalance + Annual) * Interest) \ 100
		' End Scope
		Dim Revenue As LongInt = Integer64Division((Initial + Annual) * Interest, 100)
		pInterestTable[i].Revenue = Revenue
		
		' pInterestTable[i].Tax = (pInterestTable[i].Revenue * Tax) \ 100
		pInterestTable[i].Tax = Integer64Division(Revenue * Tax, 100)
		
		
		pInterestTable[i].Profit = Revenue - pInterestTable[i].Tax
		pInterestTable[i].EndingBalance = pInterestTable[i].Profit + pInterestTable[i].OpeningBalance + Annual
		
		Initial = pInterestTable[i].EndingBalance
	Next
End Sub
