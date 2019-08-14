import random
import operator

'''
class Simulation:
	def__init__(self,farmers,plotsize,croplength,diseaselength)



'''
class Farmer:
	def __init__(self,crop_knowledge,money,age,name,birthyear):
		self.div_pref = random.uniform(0,1)
		self.explor_pref = random.uniform(0,1)
		self.crop_knowledge = crop_knowledge
		self.money = money
		self.age = age
		self.name = name
		self.income = 0
		self.crops_planted = []

def BestCrop(FarmerKnowledge,PatentCostDict,DiversityDict):
	#finds best known crop - accounting for farmers desire for biodiversity and known patent costs
	AggregateDict = {}
	for x in FarmerKnowledge.iteritems():
		#print x
		AdjustedYield = x[1]
		#print AdjustedYield
		try:
			AdjustedYield= AdjustedYield - PatentCostDict[x[0]]
		except:
			pass
		try:
			AdjustedYield= AdjustedYield - DiversityDict[x[0]]
		except:
			pass
		AggregateDict[x[0]] = AdjustedYield
		#print AggregateDict.items()[0]
		#print AggregateDict
	#finds best known crop available to farmer
	return max(AggregateDict.iteritems(), key=operator.itemgetter(1))[0]

def FarmerPlant(AcresOfCrops,Farmer,PatentCostDict,CropLength):
	CropsPlanted = []
	CropsPlantedDict = {}
	for x in range(0,AcresOfCrops):
		BestOption = BestCrop(Farmer.crop_knowledge,CropsPlantedDict,PatentCostDict)
		if Farmer.explor_pref < ((x+1)/float(AcresOfCrops)):
			try:
				CropsPlanted.append(BestOption)
				try:
					CropsPlantedDict[BestOption] = CropsPlantedDict[BestOption] + (1/float(AcresOfCrops)) * Farmer.div_pref
				except:
					CropsPlantedDict[BestOption] = (1/float(AcresOfCrops)) * Farmer.div_pref
			except: 
				random_string = random_bit_string(CropLength)
				CropsPlanted.append(random_string)
		else:
			#farmers with higher explore preferences plant random seeds
			random_string = random_bit_string(CropLength)
			CropsPlanted.append(random_string)
	return CropsPlanted

'''
def FarmerHarvest:
'''

def CropFunction(CropLength):
	#This creates a list of dictionaries
	#For Now Complexity is of Legth 1
	subdict = {}
	for y in range(0,CropLength):
		subdict[y] = random.uniform(-1,1)
	return subdict

def CropEvolve(CropDict,Parameter):
	#this updates the value that each gene in the crop contributes to the overall harvest
	newdict = {}
	CropGenes = CropDict.items()
	for x in CropGenes:
		newval = x[1] + random.gauss(0,Parameter)
		if newval > 1:
			newval = 1
		if newval < -1:
			newval = -1
		newdict[x[0]] = newval
	return newdict


def CropEvaluate(CropDicts,CropString):
	CropFunction = 0
	Counter = 0
	for y in str(CropString):
		#print y
		if y == '1':
		#	print float(x[Counter])
			CropFunction = CropFunction + float(CropDicts[Counter])
		else:
		#	print -float(x[Counter])
			CropFunction = CropFunction - float(CropDicts[Counter])
		#print CropFunction
		Counter = Counter + 1
	return CropFunction



def random_bit_string(k):
	bin_string = str(bin(random.getrandbits(k))[2:])
	zerosneeded = k - len(bin_string) 
	for x in range(0,zerosneeded):
		bin_string = '0' + bin_string
	return bin_string

def mutate_disease(disease,mutation_rate):
	#picks a random gene on the disease and flips the locus
	if random.random() < mutation_rate:
		dis_length = len(disease)
		#print dis_length
		mutation_location = random.randint(0,dis_length-1)
		disease_list = list(disease)
		if disease_list[mutation_location] == '1':
			disease_list[mutation_location] = '0'
		else:
			disease_list[mutation_location] = '1'
	return "".join(disease_list)

def disease_check(crop,disease):
	croplen = len(crop)
	diseaselen = len(disease)
	Checker = False
	crop = crop + crop[:-1]
	for x in range (0,croplen):
		if crop[x:(diseaselen+x)] == disease:
			Checker = True
	return Checker

def HarvestAndLearn(farmers,disease,patentowners,cropvalues,cropcosts):
	patent_revenues = {}
	for y in farmers:
		income = 0
		for x in y.crops_planted:
			#print x
			revenue = 0
			diseased = disease_check(x,disease)
			if diseased == True:
				revenue = 0
			else:	
				revenue = CropEvaluate(cropvalues,x)
			try: 
				cost = cropcosts[x]
			#	print "cost",cost
				patentowner = patentowners[x]
				try:
					patent_revenues[patentowner] = patent_revenues[patentowner] + cost
				except:
					patent_revenues[patentowner] = cost
			except:
				cost = 0
			#print "rev",revenue
			income = income + revenue - cost
			#print "A", str(len(PatentedCropYields)),PatentedCropYields
			#print x
			y.crop_knowledge[x] = revenue #*************8
			#print y.crop_knowledge #***************
			#print "B", str(len(PatentedCropYields)),PatentedCropYields
		y.income = income
		y.crops_planted = []
	for q in farmers:
		try:
			q.income = q.income + patent_revenues[q.name]
		except:
			pass
	#print farmer.crop_knowledge
		#print q
		#print income
	return farmers

def UpdatePatents(farmers,Patents,PatentCostDict,PatentOwners,PatentLengthDict,PatentCost,PatentLength):
	#update lengths
	for q in PatentLengthDict.items():
		if PatentLengthDict[q[0]] > 0:
			PatentLengthDict[q[0]]= PatentLengthDict[q[0]]-1
		if PatentLengthDict[q[0]] == 0:
			PatentCostDict[q[0]] = 0
	PatentList = Patents.items()
	BestKnownCrop = PatentList[0][0]
	BestKnownValue = PatentList[0][1]
	##Find Highest Yielding Crop in Patent Dictionary
	for x in PatentList:
		if x[1] > BestKnownValue:
			BestKnownCrop = x[0]
			BestKnownValue = x[1]
	##Find best crop in each farmer's set of knowledge
	for y in farmers:
		if len(y.crop_knowledge.items()) > 0:
			FarmerKnownList = y.crop_knowledge.items()
			#print FarmerKnownList
			BestIndivCrop = FarmerKnownList[0][0]
			BestIndivValue = FarmerKnownList[0][1]
			for z in FarmerKnownList:
				if z[1] > BestIndivValue:
					BestIndivCrop = z[0]
					BestIndivValue = z[1]
		#print BestIndivCrop,BestIndivValue
		if BestIndivValue > BestKnownValue:
			if Patents.get(BestIndivCrop) == None: 
				try:
					Patents[BestIndivCrop] = BestIndivValue
					PatentCostDict[BestIndivCrop] = PatentCost
					PatentLengthDict[BestIndivCrop] = PatentLength
					PatentOwners[BestIndivCrop] = y.name
				except:
					pass
		#print Patents; PatentOwners
	return(Patents,PatentCostDict,PatentOwners,PatentLengthDict)

def getIncome(farmer):
	return farmer.income

def CullAndSpawn(farmers,year,counter,victims,parents):
	#sort farmers
	farmers = sorted(farmers, key=getIncome, reverse=True)
	survivors = len(farmers) - victims
	survivingfarmers = farmers[0:survivors]
	for q in range(0,victims):
		newFarmer = Farmer({},FM,0,farmercounter+q,birthyear)
		r1 = random.randint(0,parents-1)
		r2 = random.randint(0,parents-1)
		new_div_pref =  survivingfarmers[r1].div_pref + random.gauss(0,0.1)
		if new_div_pref < 0:
			new_div_pref = 0
		if new_div_pref > 1:
			new_div_pref = 1
		new_explor_pref = survivingfarmers[r2].explor_pref + random.gauss(0,0.1)
		if new_explor_pref < 0:
			new_explor_pref = 0
		if new_explor_pref > 1:
			new_explor_pref = 1
		newFarmer.explor_pref = new_explor_pref
		newFarmer.div_pref = new_div_pref
		survivingfarmers.append(newFarmer)
	return survivingfarmers



###Execute Simulation
for trial in range(0,10):
	for dl in (5,7,9):
		for ce in (0.01,0.025):
			CL = 10  #CropLength
			CC = 1  #CropComplexity
			DL = dl  #DiseaseLength
			PL = 500 # PatentLength
			PC = 2 # PatentCosts
			F = 10 # of Farmers
			A = 10 # of Acres Per Farmer
			FM = 10 # InitialFarmerMoney
			CE = ce # Standard Deviation of Crop Evolution Parmameter
			V = 2 #FarmersKilledEachRound
			P = 4 #ParentsOfNextGeneration
			Years = 500 # Years of Simulation
			PatentedCropYields = {}
			PatentedCropCosts = {}
			PatentTimeLeft = {}
			PatentOwner = {}
			#generate random crop function
			CropValues = CropFunction(CL)
			#pick initial random "patented" crop with cost X - PatentHasNoOwner
			init_patent = random_bit_string(CL)
			init_patent_val = CropEvaluate(CropValues,init_patent)
			PatentedCropYields[init_patent] = init_patent_val
			PatentedCropCosts[init_patent] = PC
			PatentTimeLeft[init_patent] = PL
			PatentOwner[init_patent] = "None"
			#print PatentOwner
			#initialize farmers
			birthyear = 0
			farmercounter = 0
			ListOfFarmers = []
			for x in range (0,F):
				NewFarmer = Farmer({},FM,-1,farmercounter,birthyear)
				for j in PatentedCropYields.items():
					NewFarmer.crop_knowledge[j[0]] = j[1]
				ListOfFarmers.append(NewFarmer)
				farmercounter = farmercounter + 1
			#initialize disease
			Disease = random_bit_string(DL)
			for year in range(0,Years):
				#FStep 1 - Farmers Plant Crops and Income Set to Zero
				for y in ListOfFarmers:
					y.income = 0
					y.crops_planted = FarmerPlant(A,y,PatentedCropCosts,CL)
				#Step 2 - Disease Evolves and Strikes # And Crop Function Evolves Too
				CropValues = CropEvolve(CropValues,CE)
				Disease = mutate_disease(Disease,1)
				#print(Disease)
			#Step 3 - Farmers Harvest Crop and Learn New Values
				ListOfFarmers = HarvestAndLearn(ListOfFarmers,Disease,PatentOwner,CropValues,PatentedCropCosts)
			#Step 4 - Farmer With Lowest Income Parishes and New Farmer Created
				for g in ListOfFarmers:
					print str(g.name) + '|' + str(g.income) + '|' + str(g.explor_pref) + '|' + str(g.div_pref) + '|' + str(year) + '|' + str(dl) + '|' + str(ce) + '|' + str(trial)
				#print str(year)
				#print len(PatentedCropYields)
				ListOfFarmers = CullAndSpawn(ListOfFarmers,year,farmercounter,V,P)
				farmercounter = farmercounter + V
			#Step 5 - Farmers Submit Highest Crop For Patent
				PatentedCropYields,PatentedCropCosts,PatentOwner,PatentTimeLeft = UpdatePatents(ListOfFarmers,PatentedCropYields,PatentedCropCosts,PatentOwner,PatentTimeLeft,PC,PL)
			#Step 5a - New Farmer Learns PAtents
				for a in ListOfFarmers:
					if a.age == 0:
						for t in PatentedCropYields.items():
							a.crop_knowledge[t[0]] = t[1]
