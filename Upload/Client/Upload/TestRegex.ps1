$NINO_RegEx = '^.*((?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)(?:[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z])(?:\s*\d\s*){6}([A-D]|\s)).*$'

#[regex]::Match('abc123', '^a(.+)')
#'abc123' -match '^a(.+)'

$Matches = $null 
$isNino = "Hey I,m pete  WL686722B seriously " -match $NINO_RegEx

if ($isNino) {
    $Matches[1]
}

