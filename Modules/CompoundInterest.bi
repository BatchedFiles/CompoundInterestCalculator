#ifndef COMPOUNDINTEREST_BI
#define COMPOUNDINTEREST_BI

Type CompoundInterest
	Dim OpeningBalance As LongInt ' Начальное сальдо
	Dim Annual As LongInt         ' Довложение за период
	Dim Revenue As LongInt        ' Доход за период
	Dim TaxValue As LongInt       ' Сумма подоходного налога
	Dim Profit As LongInt         ' Чистая прибыль за период
	Dim EndingBalance As LongInt  ' Конечное сальдо
End Type

Declare Sub CalculatePrincipal( _
	ByVal pInterestTable As CompoundInterest Ptr, _
	ByVal OverralLength As Integer, _
	ByVal OpeningBalance As LongInt, _
	ByVal Annual As LongInt, _
	ByVal Interest As LongInt, _
	ByVal Tax As LongInt _
)

#endif
