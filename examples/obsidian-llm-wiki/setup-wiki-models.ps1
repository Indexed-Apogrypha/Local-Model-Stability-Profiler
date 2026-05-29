<#
.SYNOPSIS
    Build Ollama models tuned for the obsidian-llm-wiki ("Karpathy LLM Wiki") plugin.

.DESCRIPTION
    Pulls each base model and bakes in a long context window (num_ctx) plus
    recommended sampling, since the plugin never raises Ollama's ~4K default
    context itself.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\setup-wiki-models.ps1
    # builds the English-native picks: gemma-wiki + gemma-e4b-wiki + mistral-wiki

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\setup-wiki-models.ps1 -Models e4b
    # just the fast pick

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\setup-wiki-models.ps1 -Models gemma,e4b,mistral,qwen
    # also builds qwen3-wiki for A/B testing
#>
param(
    [ValidateSet("gemma", "e4b", "mistral", "qwen")]
    [string[]] $Models = @("gemma", "e4b", "mistral")
)

$ErrorActionPreference = "Stop"

$catalog = @{
    gemma   = @{ Base = "gemma3:12b";       File = "gemma-wiki.Modelfile";   Name = "gemma-wiki"     }
    e4b     = @{ Base = "gemma4:e4b";       File = "gemma4-e4b.Modelfile";   Name = "gemma-e4b-wiki" }
    mistral = @{ Base = "mistral-nemo:12b"; File = "mistral-wiki.Modelfile"; Name = "mistral-wiki"   }
    qwen    = @{ Base = "qwen3:14b";        File = "qwen3-wiki.Modelfile";   Name = "qwen3-wiki"     }
}

$kv = $env:OLLAMA_KV_CACHE_TYPE
if ($kv) {
    Write-Host "OLLAMA_KV_CACHE_TYPE = $kv (good - frees VRAM for context)" -ForegroundColor Cyan
} else {
    Write-Host "Tip: 'setx OLLAMA_KV_CACHE_TYPE q8_0' then restart Ollama to free VRAM for context." -ForegroundColor Yellow
}

foreach ($key in $Models) {
    $m = $catalog[$key]
    Write-Host "`n=== $($m.Name)  (base: $($m.Base)) ===" -ForegroundColor Green
    ollama pull $m.Base
    ollama create $m.Name -f (Join-Path $PSScriptRoot $m.File)
    Write-Host "Built $($m.Name):" -ForegroundColor Green
    ollama show $m.Name
}

Write-Host "`nDone. In Obsidian: Settings -> Karpathy LLM Wiki -> Provider = Ollama (Local) ->" -ForegroundColor Cyan
Write-Host "Model = one of the *-wiki models above, then REGENERATE pages made with the old model." -ForegroundColor Cyan
