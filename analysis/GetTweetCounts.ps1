Get-ChildItem "./data" -Filter *.csv | 
Foreach-Object {
	Write-Host -NoNewline $_.FullName
	Write-Host -NoNewline ": "
	$count = (gc $_.FullName).count - 1
	Write-Host $count
}