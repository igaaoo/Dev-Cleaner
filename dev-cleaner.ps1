# Detecta idioma do sistema
$culture = [System.Globalization.CultureInfo]::InstalledUICulture.TwoLetterISOLanguageName
$isPT = $culture -eq 'pt'


function T($pt, $en) {
    if ($isPT) { return $pt } else { return $en }
}

# Função que busca pastas-alvo evitando acessar interiores
function BuscarPastasAlvo {
    param (
        [string]$rootPath,
        [string[]]$nomesAlvo
    )

    $resultado = @()

    function ScanFolder {
        param (
            [System.IO.DirectoryInfo]$pasta
        )

        foreach ($subdir in $pasta.GetDirectories()) {
            if ($nomesAlvo -contains $subdir.Name) {
                $resultado += $subdir
                continue
            }
            ScanFolder -pasta $subdir
        }
    }

    $dirInfo = Get-Item $rootPath
    ScanFolder -pasta $dirInfo
    return $resultado
}

# Função que filtra pastas aninhadas
function FiltrarPastasValidas {
    param (
        [array]$pastas
    )

    $pastasFiltradas = @()
    $pastasOrdenadas = $pastas | Sort-Object { $_.FullName.Length }

    foreach ($pasta in $pastasOrdenadas) {
        $estaAninhada = $false
        foreach ($selecionada in $pastasFiltradas) {
            if ($pasta.FullName.StartsWith($selecionada.FullName)) {
                $estaAninhada = $true
                break
            }
        }
        if (-not $estaAninhada) {
            $pastasFiltradas += $pasta
        }
    }

    return $pastasFiltradas
}

# Início
$inicio = Get-Date
$rootFolder = Get-Location
$pastasParaDeletar = @("node_modules", ".next", "dist", "build", "coverage")
$dataLimite = (Get-Date).AddDays(-7)

$pastasApagadas = @()
$tamanhoTotalLiberado = 0
$contadorTotal = 0

# Logo
Write-Host @"
  __  ____                ____ _                                 ____  
 / / |  _ \  _____   __  / ___| | ___  __ _ _ __   ___ _ __     / /\ \ 
/ /  | | | |/ _ \ \ / / | |   | |/ _ \/ _` | '_ \ / _ \ '__|   / /  \ \
\ \  | |_| |  __/\ V /  | |___| |  __/ (_| | | | |  __/ |     / /   / / 
 \_\ |____/ \___| \_/    \____|_|\___|\__,_|_| |_|\___|_|    /_/   /_/  
"@ -ForegroundColor Cyan

Write-Host ""
Write-Host "Autor: Igor Neves" -ForegroundColor Yellow
Write-Host "GitHub: https://github.com/igaaoo" -ForegroundColor Yellow
Write-Host ""
Write-Host "$(T 'Diretório atual' 'Current directory'): $($rootFolder.Path)" -ForegroundColor Yellow
Write-Host ""
Write-Host (T "Limpeza de projetos iniciada." "Project cleanup started.") -ForegroundColor DarkCyan
Write-Host (T "Pastas-alvo:" "Target folders:") -ForegroundColor Cyan

foreach ($pasta in $pastasParaDeletar) {
    Write-Host "   -> $pasta" -ForegroundColor Gray
    Start-Sleep -Milliseconds 80
}

Write-Host ""
Write-Host (T "Buscando pastas para apagar..." "Searching for folders to delete...") -ForegroundColor Green

$totalPastas = 0
$pastasTotaisParaApagar = @{ }

$todasEncontradas = BuscarPastasAlvo -rootPath $rootFolder -nomesAlvo $pastasParaDeletar
$filtradas = FiltrarPastasValidas -pastas $todasEncontradas

foreach ($pasta in $pastasParaDeletar) {
    $grupo = $filtradas | Where-Object { $_.Name -eq $pasta }
    $pastasTotaisParaApagar[$pasta] = $grupo
    $totalPastas += $grupo.Count
}

$current = 0

foreach ($pasta in $pastasTotaisParaApagar.Keys) {
    $pastasEncontradas = $pastasTotaisParaApagar[$pasta]

    foreach ($dir in $pastasEncontradas) {
        $current++
        $progresso = [math]::Round(($current / $totalPastas) * 100)
        Write-Progress -Activity (T "Limpando projetos..." "Cleaning projects...") -Status "$(T 'Apagando' 'Deleting') '$($dir.Name)'" -PercentComplete $progresso

        $projeto = $dir.Parent
        $modificadoEm = (Get-Item $projeto.FullName).LastWriteTime
        $dataFormatada = $modificadoEm.ToString("dd/MM/yyyy HH:mm:ss")
        $recente = $modificadoEm -gt $dataLimite

        $tamanho = (Get-ChildItem -Path $dir.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $tamanhoMB = [math]::Round($tamanho / 1MB, 2)

        if ($recente) {
            $pergunta = T "[!] Projeto '$($projeto.Name)' foi modificado em $dataFormatada. Apagar '$($dir.Name)' mesmo assim? (s/n)" "[!] Project '$($projeto.Name)' was modified on $dataFormatada. Delete '$($dir.Name)' anyway? (y/n)"
            $resposta = Read-Host $pergunta
            if (($isPT -and $resposta -ne 's') -or (-not $isPT -and $resposta -ne 'y')) {
                Write-Host "$(T '>> Pulando' '>> Skipping') $($dir.FullName)" -ForegroundColor DarkYellow
                continue
            }
        }

        try {
            Remove-Item -Path $dir.FullName -Recurse -Force
            Write-Host "[DEL] $($dir.FullName) — $tamanhoMB MB" -ForegroundColor Red
            $pastasApagadas += [PSCustomObject]@{
                Caminho = $dir.FullName
                TamanhoMB = $tamanhoMB
            }
            $tamanhoTotalLiberado += $tamanho
            $contadorTotal++
        } catch {
            Write-Warning "[ERRO] $(T 'Não foi possível apagar' 'Could not delete') $($dir.FullName): $_"
        }
    }
}

# Resumo
$fim = Get-Date
$duracao = $fim - $inicio
$tamanhoTotalMB = [math]::Round($tamanhoTotalLiberado / 1MB, 2)

Write-Host ""
Write-Host (T "Resumo da Limpeza" "Cleanup Summary") -ForegroundColor DarkCyan
Write-Host "-----------------------------"
Write-Host "$(T 'Tempo total' 'Total time'): $($duracao.ToString())"
Write-Host "$(T 'Pastas apagadas' 'Folders deleted'): $contadorTotal"
Write-Host "$(T 'Espaço liberado' 'Freed space'): $tamanhoTotalMB MB"
Write-Host "-----------------------------"

foreach ($item in $pastasApagadas) {
    Write-Host "-> $($item.Caminho) — $($item.TamanhoMB) MB" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host (T "Limpeza finalizada com sucesso!" "Cleanup completed successfully!") -ForegroundColor Green
Write-Host ""
Pause
