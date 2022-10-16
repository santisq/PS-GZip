using namespace System.Text
using namespace System.IO
using namespace System.IO.Compression
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Add-Type -AssemblyName System.IO.Compression

class EncodingTransformation : ArgumentTransformationAttribute {
    [object] Transform([EngineIntrinsics] $EngineIntrinsics, [object] $InputData) {
        $outputData = switch($InputData) {
            { $_ -is [Encoding] } { $_ }

            { $_ -is [string] } {
                switch ($_) {
                    ASCII { [ASCIIEncoding]::new() }
                    BigEndianUnicode { [UnicodeEncoding]::new($true, $true) }
                    BigEndianUTF32 { [UTF32Encoding]::new($true, $true) }
                    ANSI {
                        $raw = Add-Type -Namespace Encoding -Name Native -PassThru -MemberDefinition '
                            [DllImport("Kernel32.dll")]
                            public static extern Int32 GetACP();
                        '
                        [Encoding]::GetEncoding($raw::GetACP())
                    }
                    OEM { [Console]::OutputEncoding }
                    Unicode { [UnicodeEncoding]::new() }
                    UTF8 { [UTF8Encoding]::new($false) }
                    UTF8BOM { [UTF8Encoding]::new($true) }
                    UTF8NoBOM { [UTF8Encoding]::new($false) }
                    UTF32 { [UTF32Encoding]::new() }
                    default { [Encoding]::GetEncoding($_) }
                }
            }

            { $_ -is [int] } { [Encoding]::GetEncoding($_) }

            default {
                throw [ArgumentTransformationMetadataException]::new(
                    "Could not convert input '$_' to a valid Encoding object."
                )
            }
        }

        return $outputData
    }
}

class EncodingCompleter : IArgumentCompleter {
    [string[]] $EncodingSet = @(
        'ascii'
        'bigendianutf32'
        'unicode'
        'utf8'
        'utf8NoBOM'
        'bigendianunicode'
        'oem'
        'utf7'
        'utf8BOM'
        'utf32'
        'ansi'
    )

    [IEnumerable[CompletionResult]] CompleteArgument (
        [string] $commandName,
        [string] $parameterName,
        [string] $wordToComplete,
        [CommandAst] $commandAst,
        [IDictionary] $fakeBoundParameters
    ) {
        [CompletionResult[]] $arguments = foreach($enc in $this.EncodingSet) {
            if($enc.StartsWith($wordToComplete)) {
                [CompletionResult]::new($enc)
            }
        }
        return $arguments
    }
}

function Compress-GzipFile {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $DestinationPath,

        [Parameter()]
        [CompressionLevel] $CompressionLevel = 'Optimal'
    )

    try {
        $Path            = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
        $DestinationPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($DestinationPath)
        $outStream       = [File]::Open($DestinationPath, [FileMode]::CreateNew)
        $inStream        = [File]::Open($Path, [FileMode]::Open)
        $gzip            = [GZipStream]::new($outStream, [CompressionMode]::Compress, $CompressionLevel)
        $inStream.CopyTo($gzip)
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        $gzip, $outStream, $inStream | ForEach-Object Dispose
    }
}

function Compress-GzipString {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $String,

        [Parameter()]
        [EncodingTransformation()]
        [ArgumentCompleter([EncodingCompleter])]
        [string] $Encoding = 'utf-8',

        [Parameter()]
        [CompressionLevel] $CompressionLevel = 'Optimal'
    )

    try {
        $enc       = [Encoding]::GetEncoding($Encoding)
        $outStream = [MemoryStream]::new()
        $gzip      = [GZipStream]::new($outStream, [CompressionMode]::Compress, $CompressionLevel)
        $inStream  = [MemoryStream]::new($enc.GetBytes($string))
        $inStream.CopyTo($gzip)
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        $gzip, $outStream, $inStream | ForEach-Object Dispose
    }

    try {
        [Convert]::ToBase64String($outStream.ToArray())
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}

function Expand-GzipFile {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string] $Path,

        [Parameter()]
        [EncodingTransformation()]
        [ArgumentCompleter([EncodingCompleter])]
        [string] $Encoding = 'utf8'
    )

    try {
        $Path      = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
        $enc       = [Encoding]::GetEncoding($Encoding)
        $outStream = [MemoryStream]::new()
        $inStream  = [File]::Open($Path, [FileMode]::Open)
        $gzip      = [GZipStream]::new($inStream, [CompressionMode]::Decompress)
        $gzip.CopyTo($outStream)
        $enc.GetString($outStream.ToArray())
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        $gzip, $outStream, $inStream | ForEach-Object Dispose
    }
}

function Expand-GzipString {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $String,

        [Parameter()]
        [EncodingTransformation()]
        [ArgumentCompleter([EncodingCompleter])]
        [string] $Encoding = 'utf8'
    )

    try {
        $enc       = [Encoding]::GetEncoding($Encoding)
        $bytes     = [Convert]::FromBase64String($String)
        $outStream = [MemoryStream]::new()
        $inStream  = [MemoryStream]::new($bytes)
        $gzip      = [GZipStream]::new($inStream, [CompressionMode]::Decompress)
        $gzip.CopyTo($outStream)
        $enc.GetString($outStream.ToArray())
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        $gzip, $outStream, $inStream | ForEach-Object Dispose
    }
}