#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/DecisionMaking/BaseDecision.mqh>

class MoneyBetOnDecision : public BaseMoneyManagement
{
	protected:
		double MaxDecision;
		double CurrentDecision;
		int NumberOfBots;
	
	public:
		MoneyBetOnDecision(double maxDecision, double currentDecision, int numberOfBots)
		{
			this.MaxDecision = maxDecision;
			this.CurrentDecision = currentDecision;
			
			if(numberOfBots != 0)
				this.NumberOfBots = numberOfBots;
			else
				this.NumberOfBots = (int) AutoDetectNumberOfBots();
		}
		
		virtual void SetCurrentDecision(double currentDecision) { this.CurrentDecision = currentDecision; }
		virtual void SetMaxDecision(double maxDecision) { this.MaxDecision = maxDecision; }
		
		virtual double GetProfitBasedOnDecision(double currentDecision,
			string symbolName, datetime calculationDate, ENUM_TIMEFRAMES timeFrame, int shift)
		{
			if(currentDecision != 0.0)
				this.CurrentDecision = currentDecision;
			if(this.MaxDecision == 0.0)
				this.MaxDecision = 1.0;
			if(this.NumberOfBots == 0.0)
				this.NumberOfBots = 1.0;
			
			double priceForQuoteCurrency = CalculateCurrencyRateForSymbol(symbolName, calculationDate, timeFrame, shift); // on market closed this price is zero
			double priceBasedOnCurrentDecision = GetPriceBasedOnDecision(currentDecision, symbolName); // on incertitude this price is zero
			double multiplicationPowerOfTwo = pow(2.0, this.CurrentDecision/this.MaxDecision) / this.NumberOfBots;
			return priceForQuoteCurrency * priceBasedOnCurrentDecision * Pip() * multiplicationPowerOfTwo; // to do: check & fix
		}
		
		
		virtual string ToString()
		{
			string retString = typename(this) + " { ";
			
			retString += "MaxDecision:" + DoubleToString(MaxDecision) + " ";
			retString += "CurrentDecision:" + DoubleToString(CurrentDecision) + " ";
			retString += "NumberOfBots:" + IntegerToString(NumberOfBots) + " ";
			
			retString += "} ";
			return retString;
		}
};