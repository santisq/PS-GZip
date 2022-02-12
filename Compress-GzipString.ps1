using namespace System
using namespace System.Text
using namespace System.IO
using namespace System.IO.Compression

function Compress-GzipString {
[cmdletbinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$String,
    [string]$Encoding = 'UTF8'
)

    try {
        $outStream = [MemoryStream]::new()
        $gzip = [GZipStream]::new(
            $outStream,
            [CompressionMode]::Compress,
            [CompressionLevel]::Optimal
        )
        $inStream = [MemoryStream]::new(
            [Encoding]::$Encoding.GetBytes($string)
        )
        $inStream.CopyTo($gzip)
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
    try {
        [Convert]::ToBase64String($outStream.ToArray())
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
