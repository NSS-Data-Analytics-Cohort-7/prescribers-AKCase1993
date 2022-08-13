--1.a Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT npi, Sum(total_claim_count) AS total_claim
From prescription
Group BY npi
Order By total_claim Desc
-- 1.a 1881634483, 99707

--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
Select Sum(p1.total_claim_count) AS total_claim, p2.nppes_provider_last_org_name, p2.nppes_provider_first_name, p2.specialty_description
FROM prescription AS p1
Inner Join prescriber AS p2
ON p1.npi= p2.npi
Group By p2.nppes_provider_last_org_name, p2.nppes_provider_first_name, p2.specialty_description
Order By total_claim DESC
-- 1.b 99707, Pendley, Bruce, Family Practice

--a. Which specialty had the most total number of claims (totaled over all drugs)?
Select SUM(p1.total_claim_count)
FROM prescription AS p1
Inner Join prescriber AS p2
ON p1.npi= p2.npi
Where  p2.specialty_description = 'Family Practice'
-- 2.a Family Practice, 9752347

--b. Which specialty had the most total number of claims for opioids?
Select Count(d.opioid_drug_flag) AS total_opioid, p2.specialty_description, Sum(p1.total_claim_count)AS total_claim
From drug AS d
Left Join prescription as p1
ON p1.drug_name=d.drug_name
LEFT Join prescriber AS p2
ON p2.npi= p1.npi
Where d.opioid_drug_flag = 'Y'
Group BY p2.specialty_description
Order by total_opioid DESC
-- Nurse Practitioner, 900845, 9551

--c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

Select p2.specialty_description, p1.*
FROM prescription AS p1
Join prescriber AS p2
ON p1.npi= p2.npi
Group By p2.specialty_description, p1*
Order by p2.specialty_description 

--3.a. Which drug (generic_name) had the highest total drug cost?

Select d.generic_name, SUM(total_drug_cost) AS drug_cost
From drug AS d
INNER JOIN prescription AS p
ON p.drug_name= d.drug_name
Group By d.generic_name
Order By drug_cost DESC
-- INSULIN GLARGINE,HUM.REC.ANLOG- 104264066.35, Pirfenidone- 2829174.3

--b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

select d.generic_name, Round(p.total_drug_cost/total_day_supply,2) AS cost_per_day
From prescription AS p
Inner Join drug AS d
ON d.drug_name= p.drug_name
Group By d.generic_name, cost_per_day
Order By cost_per_day DESC
-- IMMUN GLOB G(IGG)/GLY/IGA OV50, 7141.11

--4.a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

Select drug_name,
Case When opioid_drug_flag= 'Y' Then 'opioid'
When antibiotic_drug_flag= 'Y' Then 'antibiotic'
Else 'neither' END AS drug_type
From drug

--4.b b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

Select Sum(p.total_drug_cost) AS Money,
Case When opioid_drug_flag= 'Y' Then 'opioid'
When antibiotic_drug_flag= 'Y' Then 'antibiotic'
Else 'neither' END AS drug_type
From drug AS d
INNER Join prescription AS p
ON p.drug_name=d.drug_name
Group By drug_type
Order By drug_type
--antibiotic, $38435121.26

--5.a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

Select Count(c.cbsa)  
From cbsa AS c
Inner Join fips_county AS f
ON c.fipscounty= f.fipscounty
Where f.state= 'TN'
--42

--5.b Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

Select Max(cbsa) AS largest_pop, cbsaname
From cbsa 
Group By cbsaname
Order By largest_pop 
--Yuma, AZ has the largest with 49740, Abilene, TX has the smallest with 10180

--5.c What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

Select f.county
From fips_county AS f
Join cbsa as c
ON c.fipscounty= f.fipscounty
Where c.cbsa IS NULL

--6.a Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

Select drug_name, total_claim_count
From prescription
Where total_claim_count > 2999
--? There are nine total

--6.b For each instance that you found in part a, add a column that indicates whether the drug is an opioid.


Select p.drug_name, p.total_claim_count,
Case When opioid_drug_flag= 'Y' Then 'opioid'
When opioid_drug_flag= 'N' Then 'not an opioid'
Else 'neither' END AS opioid
From drug AS d
INNER Join prescription AS p
ON p.drug_name=d.drug_name 
Where p.total_claim_count > 2999
Order By p.drug_name

--6.c Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

Select p2.nppes_provider_last_org_name, p2.nppes_provider_first_name, p1.drug_name, p1.total_claim_count,
Case When opioid_drug_flag= 'Y' Then 'opioid'
When opioid_drug_flag= 'N' Then 'not an opioid'
Else 'neither' END AS opioid
From drug AS d
INNER Join prescription AS p1
ON p1.drug_name=d.drug_name 
Inner Join prescriber AS p2
ON p1.npi= p2.npi
Where p1.total_claim_count > 2999
Order By p1.drug_name

--7 The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

--7.a First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


Select p2.npi, d.drug_name
From prescriber AS p2
Natural Join drug as d
Where p2.specialty_description= 'Pain Management'
AND p2.nppes_provider_city= 'NASHVILLE'
AND d.opioid_drug_flag= 'Y'

--7.b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

Select p2.npi, d.drug_name, p1.total_claim_count AS number_of_claims
From prescriber AS p2
Natural Join drug AS d, prescription AS p1
Where p2.specialty_description= 'Pain Management'
AND p2.nppes_provider_city= 'NASHVILLE'
AND d.opioid_drug_flag= 'Y'
Order By number_of_claims




