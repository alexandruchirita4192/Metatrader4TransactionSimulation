#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


struct GeneratorConfig
{
	public:
		double GeneratorStart, GeneratorStop, GeneratorStep;
		bool UseGenerator;
		
		GeneratorConfig(double generatorStart = 0.0, double generatorStop = 0.0, double generatorStep = 0.0)
		{
			SetupGenerator(generatorStart, generatorStop, generatorStep);
		}
		
		void SetupGenerator(double generatorStart = 0.1, double generatorStop = 4.5, double generatorStep = 0.1)
		{
			this.GeneratorStart = generatorStart;
			this.GeneratorStop = generatorStop;
			this.GeneratorStep = generatorStep;
			
			this.UseGenerator = ((generatorStart != 0.0) ||
				(generatorStop != 0.0) ||
				(generatorStep != 0.0));
		}
		void CleanGenerator() { this.UseGenerator = false; }
};
