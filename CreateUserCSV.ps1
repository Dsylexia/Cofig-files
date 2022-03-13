# Usage:
# .\CreateUserCSV.ps1
# will create the csv-file which can be used like this (if sec.core domain prepared):
# $ADUsers = Import-Csv seccoreusers.csv -Delimiter ";"
# # Headers: Username;GivenName;SurName;UserPrincipalName;DisplayName;Password;Department;Path
# foreach ($User in $ADUsers) {
#     New-ADUser `
#     -SamAccountName        $User.Username `
#     -UserPrincipalName     $User.UserPrincipalName `
#     -Name                  $User.DisplayName `
#     -GivenName             $User.GivenName `
#     -Surname               $User.SurName `
#     -Enabled               $True `
#     -ChangePasswordAtLogon $False `
#     -DisplayName           $user.Displayname `
#     -Department            $user.Department `
#     -Path                  $user.path `
#     -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force)
# }
# Note: might get "The password does not meet the length, complexity, or
# history requirement of the domain." due to bad default password policy

# Run this script to create your own list of 100 users for the WallE.IT
# infrastructure as a CSV-file
# Each time the script is run, it will create a new random combination
# of firstname (which is also the username), lastname and department
# New unique random passwords are generated for every user

# Test so we don't overwrite a file by accident
#
if ((Get-ChildItem -ErrorAction SilentlyContinue walleitusers.csv).Exists)
  {"You already have the file seccoreusers.csv!"; return;}
  

# 100 unique firstnames without norwegian characters ('øæå')
#
$FirstName = @("Nora","Emma","Ella","Maja","Olivia","Emilie","Sofie","Leah",
               "Sofia","Ingrid","Frida","Sara","Tiril","Selma","Ada","Hedda",
               "Amalie","Anna","Alma","Eva","Mia","Thea","Live","Ida","Astrid",
               "Ellinor","Vilde","Linnea","Iben","Aurora","Mathilde","Jenny",
               "Tuva","Julie","Oda","Sigrid","Amanda","Lilly","Hedvig",
               "Victoria","Amelia","Josefine","Agnes","Solveig","Saga","Marie",
               "Eline","Oline","Maria","Hege","Jakob","Emil","Noah","Oliver",
               "Filip","William","Lucas","Liam","Henrik","Oskar","Aksel",
               "Theodor","Elias","Kasper","Magnus","Johannes","Isak","Mathias",
               "Tobias","Olav","Sander","Haakon","Jonas","Ludvig","Benjamin",
               "Matheo","Alfred","Alexander","Victor","Markus","Theo",
               "Mohammad","Herman","Adam","Ulrik","Iver","Sebastian","Johan",
               "Odin","Leon","Nikolai","Even","Leo","Kristian","Mikkel",
               "Gustav","Felix","Sverre","Adrian","Lars"
              )

# 100 unique lastnames
#
$LastName = @("Hansen","Johansen","Olsen","Larsen","Andersen","Pedersen",
              "Nilsen","Kristiansen","Jensen","Karlsen","Johnsen","Pettersen",
              "Eriksen","Berg","Haugen","Hagen","Johannessen","Andreassen",
              "Jacobsen","Dahl","Jørgensen","Henriksen","Lund","Halvorsen",
              "Sørensen","Jakobsen","Moen","Gundersen","Iversen","Strand",
              "Solberg","Svendsen","Eide","Knutsen","Martinsen","Paulsen",
              "Bakken","Kristoffersen","Mathisen","Lie","Amundsen","Nguyen",
              "Rasmussen","Ali","Lunde","Solheim","Berge","Moe","Nygård",
              "Bakke","Kristensen","Fredriksen","Holm","Lien","Hauge",
              "Christensen","Andresen","Nielsen","Knudsen","Evensen","Sæther",
              "Aas","Myhre","Hanssen","Ahmed","Haugland","Thomassen",
              "Sivertsen","Simonsen","Danielsen","Berntsen","Sandvik",
              "Rønning","Arnesen","Antonsen","Næss","Vik","Haug","Ellingsen",
              "Thorsen","Edvardsen","Birkeland","Isaksen","Gulbrandsen","Ruud",
              "Aasen","Strøm","Myklebust","Tangen","Ødegård","Eliassen",
              "Helland","Bøe","Jenssen","Aune","Mikkelsen","Tveit","Brekke",
              "Abrahamsen","Madsen"
             )

# 1 CEO, 1 COO, 10 in HR, 0 ITAdmin, 4 RRT, 30 DevTeam, 25 NetworkEng, 25 ResponseTeam.
#
$OrgUnits = @("ou=CEO,ou=AllUsers","ou=COO,ou=CEO,ou=AllUsers",
              "ou=HR,ou=COO,ou=CEO,ou=ALLUSERS","ou=HR,ou=COO,ou=CEO,ou=ALLUSERS","ou=HR,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=HR,ou=COO,ou=CEO,ou=ALLUSERS","ou=HR,ou=COO,ou=CEO,ou=ALLUSERS","ou=HR,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=HR,ou=COO,ou=CEO,ou=ALLUSERS","ou=HR,ou=COO,ou=CEO,ou=ALLUSERS","ou=HR,ou=COO,ou=CEO,ou=ALLUSERS","ou=HR,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=ITAdmin,ou=COO,ou=CEO,ou=ALLUSERS","ou=ITAdmin,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=ITAdmin,ou=COO,ou=CEO,ou=ALLUSERS","ou=ITAdmin,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=RRT,ou=COO,ou=CEO,ou=ALLUSERS","ou=RRT,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=RRT,ou=COO,ou=CEO,ou=ALLUSERS","ou=RRT,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
	        "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
	        "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
              "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
	        "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=DevTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
  		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
  		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=NetworkEng,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS","ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS",
		  "ou=ResponseTeam,ou=Consultants,ou=COO,ou=CEO,ou=ALLUSERS"


             )

# Three shuffled indices to randomly mix firstname, lastname, and department
#
$fnidx = 0..99 | Get-Random -Shuffle
$lnidx = 0..99 | Get-Random -Shuffle
$ouidx = 0..99 | Get-Random -Shuffle

Write-Output "UserName;GivenName;SurName;UserPrincipalName;DisplayName;Password;Department;Path" > seccoreusers.csv

foreach ($i in 0..99) {
  $UserName          = $FirstName[$fnidx[$i]].ToLower()
  $GivenName         = $FirstName[$fnidx[$i]]
  $SurName           = $LastName[$lnidx[$i]]
  $UserPrincipalName = $UserName + '@' + 'WallE.IT'
  $DisplayName       = $GivenName + ' ' + $SurName
  $Password 	     =  -join ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPRSTUVWXYZ0123456789!"#$%&()*+,-./:<=>?@[\]_{|}'.ToCharArray() | Get-Random -Count 16)
      
  
  $Department        = ($OrgUnits[$ouidx[$i]] -split '[=,]')[1]
  $Path              = $OrgUnits[$ouidx[$i]] + ',' + "dc=WallE,dc=IT"
  Write-Output "$UserName;$GivenName;$SurName;$UserPrincipalName;$DisplayName;$Password;$Department;$Path" >> walleitusers.csv
}
