# Ollama models for the Obsidian "LLM Wiki" plugin

Tuned `Modelfile`s + a setup script for running
[obsidian-llm-wiki](https://github.com/green-dalii/obsidian-llm-wiki)
("Karpathy LLM Wiki") against a **local Ollama** model.

Tested target: a single GPU with **~16GB VRAM**, an **English** vault.

## Why these configs exist

Two quirks of the plugin trip up a naive setup:

1. **It never raises Ollama's context window.** The plugin only sends `model`,
   `max_tokens`, `system`, and `messages` — so you're stuck at Ollama's ~4K
   default unless `num_ctx` is baked into the model. Every Modelfile here sets
   `num_ctx 32768`.
2. **It forces a "translation" alias on every page** (for cross-language
   duplicate detection). A Chinese model (Qwen) fills that slot with Chinese,
   so an English-only vault ends up with **Chinese aliases** even when
   *Wiki Output Language* is already set to English. The fix is to use an
   English-native model.

## Recommended models (16GB VRAM, English vault)

| Model              | Base tag           | Why                                                        | VRAM (Q4 + 32K ctx) |
| ------------------ | ------------------ | --------------------------------------------------------- | ------------------- |
| **gemma-wiki** *(default)* | `gemma3:12b`       | Google, English-native, clean structured prose, 128K ctx  | ~11 GB              |
| **mistral-wiki**   | `mistral-nemo:12b` | Lightest, 128K ctx, most headroom, Apache-2.0             | ~9 GB               |
| qwen3-wiki *(A/B only)*    | `qwen3:14b`        | Best JSON — but injects Chinese aliases on English vaults  | ~12 GB              |

> ⚠️ **There is no `gemma4:12b`.** Gemma *4* on Ollama ships only `e2b`/`e4b`
> (too small) and `26b`/`31b` (too big for 16GB). For a right-sized Gemma, use
> **Gemma 3 12B** (`gemma3:12b`).

## Setup (Windows / PowerShell)

```powershell
# one-time: store the context KV cache compactly (frees VRAM), then restart Ollama
setx OLLAMA_KV_CACHE_TYPE q8_0

# from this folder — builds gemma-wiki + mistral-wiki
powershell -ExecutionPolicy Bypass -File .\setup-wiki-models.ps1
```

Or build one by hand:

```powershell
ollama pull gemma3:12b
ollama create gemma-wiki -f .\gemma-wiki.Modelfile
ollama show gemma-wiki        # confirm: num_ctx 32768
```

## Point the plugin at it

Obsidian → Settings → **Karpathy LLM Wiki**:

- **Provider** = `Ollama (Local)` (no API key)
- **Model** = `gemma-wiki` (or `mistral-wiki`)

Then **regenerate** any pages created with the old model — switching the model
is not retroactive, so existing Chinese aliases stay until you rebuild those
pages.

## Verify it's healthy

```powershell
ollama run gemma-wiki "Reply with exactly: ready"
ollama ps      # PROCESSOR should read 100% GPU, CONTEXT 32768
```

## A/B with the profiler

These double as fixtures for **Local-Model-Stability-Profiler**: build all three
(`-Models gemma,mistral,qwen`) and let the profiler rank them on your hardware.
A natural test to add is a language-leakage check that flags non-English output,
so issues like Qwen's Chinese aliases get caught automatically.
