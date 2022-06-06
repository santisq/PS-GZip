using namespace System
using namespace System.Text
using namespace System.IO
using namespace System.IO.Compression

function Expand-GzipFile {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$Path,
        [string]$Encoding = 'UTF8'
    )

    try {
        $Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
        $outStream = [MemoryStream]::new()
        $handle = [FileInfo]::new($Path).OpenRead()
        $gzip = [GZipStream]::new(
            $handle,
            [CompressionMode]::Decompress
        )
        $gzip.CopyTo($outStream)
        [Encoding]::$Encoding.GetString($outStream.ToArray())
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        ($gzip, $outStream, $handle).ForEach('Dispose')
    }
}
