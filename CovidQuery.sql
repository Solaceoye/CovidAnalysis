--Checking the table loaded to confirm its accuracy
Select *
from PORTFOLIO..['COVID19 new updated$']

--Select data i will be using
Select Country,Day,[New cases ],[Total Cases],Population,[Total Death]
from PORTFOLIO..['COVID19 new updated$']
order by 1,2

--looking at Total Cases vs Total Deaths 
Select Country,Day,[Total Death ],[Total Cases],
CASE
WHEN [Total Cases]= 0 THEN 0
ELSE [Total Death ]/[Total Cases]
END AS DeathPercentage
from PORTFOLIO..['COVID19 new updated$']
order by 1,2

--where Nigeria is a case study 
--showing the likelihood of dying if you contract covid
Select Country,Day,[Total Death ],[Total Cases],
CASE
WHEN [Total Cases]= 0 THEN 0
ELSE [Total Death ]/[Total Cases]
END AS DeathPercentage
from PORTFOLIO..['COVID19 new updated$']
Where Country like '%Nigeria%'
 order by 1,2

 --looking at Total Cases vs Population  
Select Country,Day,Population,[Total Cases],
CASE
WHEN [Total Cases]= 0 THEN 0
ELSE [Total Cases] /Population
END AS Casespercentage
from PORTFOLIO..['COVID19 new updated$']
order by 1,2


 --looking at Total Cases vs Population  
 --With Nigeria has a case study

Select Country,Day,Population,[Total Cases],
CASE
WHEN [Total Cases]= 0 THEN 0
ELSE ([Total Cases] /Population)*100
END AS Casespercentage
from PORTFOLIO..['COVID19 new updated$']
Where Country like '%Nigeria%'
order by 1,2
 
 --Countries with highest infection rate compared to population 
 Select Country,Population,MAX([Total Cases]) as highestinfectioncount,
CASE
WHEN MAX([Total Cases])= 0 THEN 0
ELSE (MAX([Total Cases]) /Population)*100
END AS PercentagePopulationInfected
from PORTFOLIO..['COVID19 new updated$']
--Where Country like '%Nigeria%'
Group by Population,Country
order by PercentagePopulationInfected desc


--showing country with highest death count per population


 --Countries with highest infection rate compared to population 
 Select Country,MAX(cast([Total Death] as int)) as Totaldeathcountcount
from PORTFOLIO..['COVID19 new updated$']
--Where Country like '%Nigeria%'
Group by Country
order by Totaldeathcountcount desc


--Breaking it across Africa with the Countries picked and Africa at large

Select Day,SUM([New cases ]) as SelectedAfricaNewCases,SUM(CAST([New deaths] as int)) as SelectedAfricaNewDeath,
CASE
WHEN SUM([New cases ])= 0 THEN 0
ELSE SUM(CAST([New deaths] as int)) /SUM([New cases])*100
END AS PercentageNew
from PORTFOLIO..['COVID19 new updated$']
Where Country is  not null
group by Day
order by 1,2


--looking at Total Population  vs Vaccination
Select cvd.Country,cvd.Day,cvd.Population,vac.[People Vaccinated]
from ['COVID19 new updated$']  cvd
Join Vaccination vac
on cvd.Country=vac.Country
and cvd.Day=vac.Day
order by 1

--To do Rolling count 

Select cvd.Country,cvd.Day,cvd.Population,vac.[People Vaccinated],
SUM(CONVERT(int,vac.[People Vaccinated])) OVER(partition by cvd.country order by cvd.country,cvd.day) as Rollingpeoplevaccinated
from ['COVID19 new updated$']  cvd
Join Vaccination vac
on cvd.Country=vac.Country
and cvd.Day=vac.Day
order by 1,2

--using a cte

With PopvsVac (Country,day,population,[People Vaccinated],Rollingpeoplevaccinated)
as(
Select cvd.Country,cvd.Day,cvd.Population,vac.[People Vaccinated],
SUM(CONVERT(int,vac.[People Vaccinated])) OVER(partition by cvd.country order by cvd.country,cvd.day) as Rollingpeoplevaccinated
from ['COVID19 new updated$']  cvd
Join Vaccination vac
on cvd.Country=vac.Country
and cvd.Day=vac.Day
)
select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac

--TEMP TABLE

CREATE TABLE #percentpopulationVaccinated
(Country nvarchar (255),
day datetime,
population numeric,
[People Vaccinated] numeric,
Rollingpeoplevaccinated numeric)
 
Insert into #percentpopulationVaccinated
Select cvd.Country,cvd.Day,cvd.Population,vac.[People Vaccinated],
SUM(CONVERT(int,vac.[People Vaccinated])) OVER(partition by cvd.country order by cvd.country,cvd.day) as Rollingpeoplevaccinated
from ['COVID19 new updated$']  cvd
Join Vaccination vac
on cvd.Country=vac.Country
and cvd.Day=vac.Day

select *, (Rollingpeoplevaccinated/population)*100
from #percentpopulationVaccinated


--Creating Views to store data for visualization

create view percentpopulationVaccinated as
Select cvd.Country,cvd.Day,cvd.Population,vac.[People Vaccinated],
SUM(CONVERT(int,vac.[People Vaccinated])) OVER(partition by cvd.country order by cvd.country,cvd.day) as Rollingpeoplevaccinated
from ['COVID19 new updated$']  cvd
Join Vaccination vac
on cvd.Country=vac.Country
and cvd.Day=vac.Day
