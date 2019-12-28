# http://rprokhorov.ru/?p=254
Clear-host
# Подавляем вывод
$ErrorActionPreference = "silentlycontinue"
# Присваивание переменных
$Software = "База данных 2GIS Нижнего Новгорода (.orig.zip)"
$DistribPath = '.\'

$URLPage = 'http://info.2gis.ru/nizhniy-novgorod/products/download'

# Получаем ссылку на скачивание

Write-Host "-===========-" -ForegroundColor Green
Write-Host "Product: $Software"
#Write-Host "Version: "$version

if (test-path $DistribPath\2gis\3.0\Data_N_Novgorod.dgdat)
{
	Write-Host "Найден распакованный файл Data_N_Novgorod.dgdat"
	$date1 = (dir $DistribPath\2gis\3.0 -Filter Data_N_Novgorod.dgdat -ErrorAction Silentlycontinue).LastWriteTime
    $ver1 = ((((dir $DistribPath  -Filter 2GISData_N_Novgorod-*.orig.zip -ErrorAction Silentlycontinue).Name).Split("-"))[1]).Split(".")[0]
}
$HttpContent = Invoke-WebRequest -URI $URLPage -UseBasicParsing

$HttpContent.Links | Foreach{
    if ($_.href -like "http://download.2gis.com/arhives/2GISData_N_Novgorod-*.orig.zip")
    {
        ($DownLoadURL = $_.href)
    }
}
$ver2 = (($DownLoadURL.Split("-"))[1]).Split(".")[0]
$FileName = "2GISData_N_Novgorod-$ver2.orig.zip"
#$HttpContent.Links | fl innerText, href

if (Test-Path "$DistribPath\2GISData_N_Novgorod-*.orig.zip")
{
    if (!(Test-Path "$DistribPath\temp\2GISData_N_Novgorod-*.orig.zip"))
    {
        New-Item -Path $DistribPath\temp -ItemType "directory" -ErrorAction Silentlycontinue |out-null
    }
	# Указываем куда будем сохранять скачиваемый файл
	$destination = "$DistribPath\temp\$FileName"
    # Скачивание файла
    write-host "Скачиваем файл с сервера..."
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($DownLoadURL, $destination)
	$hash1 = Get-FileHash $DistribPath\2GISData_N_Novgorod-*.orig.zip -Algorithm MD5 |select -exp hash
	$hash2 = Get-FileHash $DistribPath\temp\$FileName -Algorithm MD5 |select -exp hash
	if ($hash1 -eq $hash2)
	{
		write-host "Подтверждаю, что файл на сервере не обновился"
		del $DistribPath\temp\$FileName
	}
	else
	{
		Write-warning "Файл на сервере обновился"
		del $DistribPath\2GISData_N_Novgorod-*.orig.zip
        try
        {
            Move-Item $DistribPath\temp\$FileName -Destination $DistribPath -Force
            
			del $DistribPath\temp
			if (test-path "C:\Program Files\7-Zip\7z.exe")
			{
				Write-Host "Обнаружен установленный 7-zip"
				# Разархивируем
				#Распаковка со всеми поддиректориями в архиве (команда x), в целевую папку (ключ -o)
				Write-Host "Распаковываем zip с помощью 7-Zip"
				Start-Process "C:\Program Files\7-Zip\7z.exe" -ArgumentList "x -r $DistribPath\$FileName -o$DistribPath" -wait
				if (test-path $DistribPath\2gis\3.0\Data_N_Novgorod.dgdat)
				{
					Write-Host "Найден распакованный файл Data_N_Novgorod.dgdat"
					$date2 = (dir $DistribPath\2gis\3.0 -Filter Data_N_Novgorod.dgdat -ErrorAction Silentlycontinue).LastWriteTime
				}
			}
			else
			{
				Write-Warning "Установленный 7-zip не обнаружен"
				"При определении версии дистрибутива Firefox на $env:COMPUTERNAME установленный 7-zip не обнаружен`n" >> d:\Update-soft-for-WDS.txt
			}
            "$Software версия $ver1 от $date1 -> версия $ver2 от $date2" >> d:\Update-soft-for-WDS.txt
        }
        catch
        {
            $host.version
            Write-Host "Если номера сборки и/или ревизии имеют значение -1, это означает что установлен beta - релиз PowerShell. В финальном релизе данные номера будут иметь значение 0."
            pause
        }
	}
}
else
{
    #if (!(Test-Path "$DistribPath\temp\$FileName"))
    #{
        #New-Item -Path $DistribPath\temp -ItemType "directory" -ErrorAction Silentlycontinue |out-null
        #write-host
    #}
	# Указываем куда будем сохранять скачиваемый файл
	$destination = "$DistribPath\$FileName"
    # Скачивание файла
    write-host "Скачиваем файл с сервера"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($DownLoadURL, $destination)
	pause
}

Write-Host "-===========-" -ForegroundColor Green