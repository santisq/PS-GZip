# PS-Gzip Module

## Description

PS-GZip Module is a set of PowerShell functions designed to compress and expand strings and files using the [GZipStream Class](https://docs.microsoft.com/en-us/dotnet/api/system.io.compression.gzipstream).

See the [Docs folder](/PS-GZip/Docs/) for details on each function.

## Requirements

Requires PowerShell 5.1 and above.

## Examples

- Compressing a String

```powershell
PS /> Compress-GzipString 'Hello world!'

H4sIAAAAAAAACvNIzcnJVyjPL8pJUQQAlRmFGwwAAAA=
```

- Expanding a Base64 GZip compressed String

```powershell
PS /> Expand-GzipString H4sIAAAAAAAACvNIzcnJVyjPL8pJUQQAlRmFGwwAAAA=

Hello world!
```
- An example using Lorem Ipsum API

```powershell
$loremIp = Invoke-RestMethod loripsum.net/api/10/long
$compressedLoremIp = Compress-GzipString $loremIp
$loremIp, $compressedLoremIp | Select-Object Length

Length
------
  8101
  4928

(Expand-GzipString $compressedLoremIp) -eq $loremIp # => # Should be True
```
- Compressing a File

```powershell
PS /> $temp = New-TemporaryFile
PS /> 'Hello world!' | Set-Content $temp
PS /> Compress-GzipFile $temp -DestinationPath test.gz
PS /> Remove-Item $temp
```

- Expanding a Gzip compressed File

```powershell
PS /> Get-Item test.gz | Expand-GzipFile

Hello world!

PS /> Remove-Item test.gz
```