# Compress and Expand Strings in PowerShell using Gzip

### Description

Two little PowerShell functions to Compress and Expand strings using the [GZipStream Class](https://docs.microsoft.com/en-us/dotnet/api/system.io.compression.gzipstream).

### Parameters

| Parameter Name | Description |
| --- | --- |
| `-String` | The string to compress or expand |
| `-Encoding` | Character encoding for the input string. __Default is UTF8__ |
| `[<CommonParameters>]` | See [`about_CommonParameters`](https://go.microsoft.com/fwlink/?LinkID=113216) |

### Requirements

Requires PowerShell 5.1 and above.

### Usage

- `Compress-GzipString 'hello world!'` Compresses the input string and outputs a _Base64 Gzip compressed string_.
- `Expand-GzipString 'H4sIAAAAAAAAA8tIzcnJVyjPL8pJUQQAbcK0AwwAAAA='` Expands the _Base64 Gzip compressed string_ into a _string_.

### Example using Lorem Ipsum API

```
$loremIp = Invoke-RestMethod loripsum.net/api/10/long
$compressedLoremIp = Compress-GzipString $loremIp
$loremIp, $compressedLoremIp | Select-Object Length
(Expand-GzipString $compressedLoremIp) -eq $loremIp # => # Should be True
```
