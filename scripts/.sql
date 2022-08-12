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

Select 
