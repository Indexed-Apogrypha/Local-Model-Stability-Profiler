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

| Model | Base tag | Why | Notes |
| ----- | -------- | --- | ----- |
| **gemma-wiki** *(best quality)* | `gemma3:12b` | Google, English-native, clean prose, 128K ctx | runs fully on GPU |
| **gemma-e4b-wiki** *(fastest)* | `gemma4:e4b` | ~4.5B effective: near-26B reasoning at ~4B speed, 128K ctx | 2–4× faster than the 12Bs |
| **mistral-wiki** | `mistral-nemo:12b` | Lightest 12B, 128K ctx, Apache-2.0 | most context headroom |
| qwen3-wiki *(A/B only)* | `qwen3:14b` | Best JSON — but injects Chinese aliases | not for English vaults |

> ⚠️ **There is no `gemma4:12b`.** Gemma *4* on Ollama ships only `e2b`/`e4b`
> (small) and `26b`/`31b` (too big for 16GB). For a right-sized dense Gemma use
> **Gemma 3 12B** (`gemma3:12b`); for speed use **Gemma 4 E4B** (`gemma4:e4b`).

## Setup (Windows / PowerShell)

```powershell
# one-time: store the context KV cache compactly (frees VRAM), then restart Ollama
setx OLLAMA_KV_CACHE_TYPE q8_0

# from this folder — builds gemma-wiki + gemma-e4b-wiki + mistral-wiki
powershell -ExecutionPolicy Bypass -File .\setup-wiki-models.ps1
```

Or build the fast one by hand:

```powershell
ollama pull gemma4:e4b
ollama create gemma-e4b-wiki -f .\gemma4-e4b.Modelfile
ollama show gemma-e4b-wiki        # confirm: num_ctx 32768
```

## Point the plugin at it

Obsidian → Settings → **Karpathy LLM Wiki**:

- **Provider** = `Ollama (Local)` (no API key)
- **Model** = `gemma-e4b-wiki` (fast) or `gemma-wiki` (best quality)

Then **regenerate** any pages created with the old model — switching the model
is not retroactive.

## If generation feels slow

Work through these before assuming you need a bigger machine:

1. **Confirm it's on the GPU.** `ollama ps` should read `100% GPU`. Any `% CPU`
   means it spilled to system RAM (a huge slowdown) — lower `num_ctx` or use a
   smaller model.
2. **Use `gemma-e4b-wiki`.** A ~4.5B-effective model is 2–4× faster than a 12B,
   and because the plugin grounds generation in *your notes* (in-context), the
   quality gap on this task is small.
3. **Lower `num_ctx` while your wiki is young.** Prompt processing scales with
   context; 16384 (or 8192) is much faster, and you can raise it later as the
   wiki grows.
4. **Enable flash attention.** `setx OLLAMA_FLASH_ATTENTION 1`, then restart
   Ollama (pairs with the q8_0 KV cache).
5. **Lower the plugin's parallel page count** (default 3) if VRAM is tight.

## A/B with the profiler

These double as fixtures for **Local-Model-Stability-Profiler**: build several
(`-Models gemma,e4b,mistral,qwen`) and let the profiler rank them on your
hardware for both **speed** and **quality** — including a language-leakage check
that flags non-English output, so issues like Qwen's Chinese aliases get caught
automatically.
