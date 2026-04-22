$ErrorActionPreference = 'Stop'

$csvPath = 'C:\Users\Yul\Downloads\제목 없는 스프레드시트 - 시트1 (1).csv'
$jsonPath = 'C:\Users\Yul\Downloads\gohcalculator-default-rtdb-export (4).json'

$excludeNames = @(
  'T-2','귀족의 증표','나노 머신','레이드 기념 모자','롱 드롭 이어링','명예의 트로피','무자카의 보따리','백호의 팔찌','산타 모자','실버 체인 벨트','앤티크 모노클','연구용 클립보드','이무기 머리띠','이무기 용포장갑','이사장의 만년필','주작의 팔찌','중2병 봉인 안대','진모리 수면 안대','청룡의 팔찌','치의 곰돌이 인형','큐니 미니 선풍기','티타늄 무테 안경','폭발 직전의 콜라','프랑켄슈타인의 실험 약물','현무의 팔찌','화이트 스노글로브','수호신의 축복[미]'
)
$excludeSet = New-Object 'System.Collections.Generic.HashSet[string]'
$excludeNames | ForEach-Object { [void]$excludeSet.Add($_) }

function Parse-Num([string]$s) {
  if ($null -eq $s) { return $null }
  $t = $s.Trim()
  if ($t -eq '') { return $null }
  $t = $t -replace ',', ''
  $t = $t -replace '%', ''
  [double]$n = 0
  if ([double]::TryParse($t, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$n)) { return $n }
  if ([double]::TryParse($t, [ref]$n)) { return $n }
  return $null
}

function Num-ToStr([double]$n) {
  if ([Math]::Abs($n - [Math]::Round($n)) -lt 1e-9) { return ([int][Math]::Round($n)).ToString() }
  return $n.ToString('0.####', [System.Globalization.CultureInfo]::InvariantCulture)
}

$csvRows = Import-Csv -Path $csvPath
$groups = @{}
$currentName = ''
foreach ($r in $csvRows) {
  $name = $r.'액세서리 이름'
  if ($name -and $name.Trim() -ne '') { $currentName = $name.Trim() }
  if (-not $currentName) { continue }

  if (-not $groups.ContainsKey($currentName)) {
    $groups[$currentName] = New-Object System.Collections.ArrayList
  }

  $stageValues = @()
  foreach ($k in 1..9) {
    $stageValues += (Parse-Num ($r."$($k)강"))
  }

  $rowObj = [PSCustomObject]@{
    description = ($r.'설명' + '').Trim()
    stageValues = $stageValues
  }
  [void]$groups[$currentName].Add($rowObj)
}

$raw = Get-Content -Raw -Path $jsonPath
$json = $raw | ConvertFrom-Json
$acc = $json.accessories
$keys = @($acc.PSObject.Properties.Name)

$nameToKeys = @{}
foreach ($k in $keys) {
  $nm = $acc.$k.name
  if (-not $nm) { continue }
  if (-not $nameToKeys.ContainsKey($nm)) {
    $nameToKeys[$nm] = New-Object System.Collections.ArrayList
  }
  [void]$nameToKeys[$nm].Add($k)
}

$updated = 0
$skippedExcluded = 0
$skippedMissing = 0
$skippedDuplicate = 0
$skippedNoRows = 0
$skippedNoOptions = 0
$updatedNames = New-Object System.Collections.ArrayList

foreach ($name in $groups.Keys) {
  if ($excludeSet.Contains($name)) { $skippedExcluded++; continue }
  if (-not $nameToKeys.ContainsKey($name)) { $skippedMissing++; continue }

  $klist = $nameToKeys[$name]
  if ($klist.Count -ne 1) { $skippedDuplicate++; continue }

  $key = $klist[0]
  $item = $acc.$key
  $opts = @($item.options)
  if ($opts.Count -eq 0) { $skippedNoOptions++; continue }

  $rows = @($groups[$name] | Where-Object { @($_.stageValues | Where-Object { $null -ne $_ }).Count -gt 0 })
  if ($rows.Count -eq 0) { $skippedNoRows++; continue }

  $pairCount = [Math]::Min($opts.Count, $rows.Count)
  $bonusList = New-Object System.Collections.ArrayList

  for ($i = 0; $i -lt $pairCount; $i++) {
    $opt = $opts[$i]
    $row = $rows[$i]
    $sv = @($row.stageValues)
    $stageStr = @()

    foreach ($v in $sv) {
      if ($null -eq $v) { $stageStr += '0' } else { $stageStr += (Num-ToStr $v) }
    }

    if ($opts.Count -le 3 -and $null -ne $opt.optionValue) {
      $cur = Parse-Num ($opt.optionValue + '')
      $s9 = $sv[8]
      if ($null -ne $cur -and $null -ne $s9) {
        $base = $cur - $s9
        $opt.optionValue = (Num-ToStr $base)
      }
    }

    [void]$bonusList.Add([PSCustomObject]@{
      optionName = ($opt.optionName + '')
      stageValues = $stageStr
    })
  }

  if ($bonusList.Count -gt 0) {
    $item.enhancementStageBonus = @($bonusList)
    $updated++
    [void]$updatedNames.Add($name)
  }
}

$backup = $jsonPath + '.bak_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
Copy-Item -Path $jsonPath -Destination $backup -Force

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($jsonPath, ($json | ConvertTo-Json -Depth 100), $utf8NoBom)

Write-Output ("UPDATED={0}" -f $updated)
Write-Output ("SKIP_EXCLUDED={0}" -f $skippedExcluded)
Write-Output ("SKIP_MISSING={0}" -f $skippedMissing)
Write-Output ("SKIP_DUPLICATE={0}" -f $skippedDuplicate)
Write-Output ("SKIP_NOROWS={0}" -f $skippedNoRows)
Write-Output ("SKIP_NOOPTIONS={0}" -f $skippedNoOptions)
Write-Output ("BACKUP={0}" -f $backup)
Write-Output ("UPDATED_SAMPLE={0}" -f (($updatedNames | Select-Object -First 20) -join ', '))
