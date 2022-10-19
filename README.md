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

- An example using [Bacon Ipsum](https://baconipsum.com) API

```powershell
# Thanks https://baconipsum.com/ :D
$loremIp = Invoke-RestMethod 'https://baconipsum.com/api/?type=all-meat&paras=100&start-with-lorem=1&format=text'
$compressedLoremIp = Compress-GzipString $loremIp
@{ Expanded = $loremIp; Compressed = $compressedLoremIp }.GetEnumerator() |
  Select-Object @{ N='Type'; E={ $_.Key }}, @{ N='Length'; E={ $_.Value.Length }}

Type       Length
----       ------
Compressed  13624
Expanded    45033

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
