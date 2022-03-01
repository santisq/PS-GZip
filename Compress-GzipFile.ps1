using namespace System
using namespace System.Text
using namespace System.IO
using namespace System.IO.Compression

function Compress-GzipFile {
[cmdletbinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Path,
    [Parameter(Mandatory)]
    [string]$DestinationPath
)

    try {
        $compressed = [File]::Create($DestinationPath)
        [FileStream] $toCompress = [FileInfo]::new($Path).OpenRead()
        $gzip = [GZipStream]::new($compressed, [CompressionMode]::Compress)
        $toCompress.CopyTo($gzip)
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        ($gzip, $toCompress, $compressed).ForEach('Dispose')
    }
}
