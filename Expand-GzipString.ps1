using namespace System
using namespace System.Text
using namespace System.IO
using namespace System.IO.Compression

function Expand-GzipString {
[cmdletbinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$String,
    [string]$Encoding = 'UTF8'
)

    try {
        $bytes = [Convert]::FromBase64String($String)
        $outStream = [MemoryStream]::new()
        $inStream = [MemoryStream]::new($bytes)
        $gzip = [GZipStream]::new(
            $inStream,
            [CompressionMode]::Decompress
        )
        $gzip.CopyTo($outStream)
        [Encoding]::$Encoding.GetString($outStream.ToArray())
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        ($gzip, $outStream, $inStream).ForEach({
            if($_ -is [IDisposable]) {
                $_.Dispose()
            }
        })
    }
}
