function ConvertTo-ConsoleText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return ''
    }

    $text = [string]$Value
    $normalized = $text.Normalize([System.Text.NormalizationForm]::FormD)
    $builder = [System.Text.StringBuilder]::new()

    foreach ($char in $normalized.ToCharArray()) {
        $category = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($char)
        if ($category -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($char)
        }
    }

    $builder.ToString().
        Replace([char]0x2013, '-').
        Replace([char]0x2014, '-').
        Replace([char]0x2018, "'").
        Replace([char]0x2019, "'").
        Replace([char]0x201C, '"').
        Replace([char]0x201D, '"').
        Replace([char]0x00A0, ' ')
}
