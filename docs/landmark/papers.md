# Foundational papers

> The ~50 papers that shaped modern LLM engineering. Grouped by topic, with one-line summaries.

The papers below recur throughout the handbook. The cites here are abbreviated; full bibliography form is on the chapters that reference them.

## Architecture

1. **Attention Is All You Need** — Vaswani et al., 2017. [arXiv:1706.03762](https://doi.org/10.48550/arXiv.1706.03762). The transformer.
2. **GPT-3** — Brown et al., 2020. [arXiv:2005.14165](https://doi.org/10.48550/arXiv.2005.14165). Scale-up + in-context learning.
3. **LLaMA** — Touvron et al., 2023. [arXiv:2302.13971](https://doi.org/10.48550/arXiv.2302.13971). The open-weights baseline.
4. **Llama 3 Herd** — Grattafiori et al., 2024. [arXiv:2407.21783](https://doi.org/10.48550/arXiv.2407.21783). State of the art open recipe.
5. **DeepSeek-V3** — DeepSeek-AI, 2024. [arXiv:2412.19437](https://doi.org/10.48550/arXiv.2412.19437). Frontier-quality open MoE.
6. **GLU Variants Improve Transformer** — Shazeer, 2020. [arXiv:2002.05202](https://doi.org/10.48550/arXiv.2002.05202). SwiGLU.
7. **RMSNorm** — Zhang & Sennrich, 2019. [arXiv:1910.07467](https://doi.org/10.48550/arXiv.1910.07467).
8. **RoFormer (RoPE)** — Su et al., 2021. [arXiv:2104.09864](https://doi.org/10.48550/arXiv.2104.09864).
9. **GQA** — Ainslie et al., 2023. [arXiv:2305.13245](https://doi.org/10.48550/arXiv.2305.13245).
10. **FlashAttention** — Dao et al., 2022. [arXiv:2205.14135](https://doi.org/10.48550/arXiv.2205.14135). The memory-aware exact attention.
11. **FlashAttention-2** — Dao, 2023. [arXiv:2307.08691](https://doi.org/10.48550/arXiv.2307.08691).

## Scaling and pretraining

12. **Kaplan Scaling Laws** — Kaplan et al., 2020. [arXiv:2001.08361](https://doi.org/10.48550/arXiv.2001.08361).
13. **Chinchilla** — Hoffmann et al., 2022. [arXiv:2203.15556](https://doi.org/10.48550/arXiv.2203.15556). Compute-optimal training.
14. **AdamW** — Loshchilov & Hutter, 2019. [arXiv:1711.05101](https://doi.org/10.48550/arXiv.1711.05101).
15. **μP** — Yang et al., 2022. [arXiv:2203.03466](https://doi.org/10.48550/arXiv.2203.03466). Hyperparameter transfer.
16. **Emergent Abilities** — Wei et al., 2022. [arXiv:2206.07682](https://doi.org/10.48550/arXiv.2206.07682). (And the "mirage" rebuttal — Schaeffer et al., 2023, [arXiv:2304.15004](https://doi.org/10.48550/arXiv.2304.15004).)
17. **Deduplication Matters** — Lee et al., 2022. [aclanthology.org/2022.acl-long.577](https://doi.org/10.18653/v1/2022.acl-long.577).
18. **C4 / T5** — Raffel et al., 2020. [arXiv:1910.10683](https://doi.org/10.48550/arXiv.1910.10683).
19. **FineWeb** — Penedo et al., 2024. [arXiv:2406.17557](https://doi.org/10.48550/arXiv.2406.17557).
20. **DataComp-LM** — Li et al., 2024. [arXiv:2406.11794](https://doi.org/10.48550/arXiv.2406.11794).

## Post-training: SFT, RLHF, DPO, RL

21. **InstructGPT** — Ouyang et al., 2022. [arXiv:2203.02155](https://doi.org/10.48550/arXiv.2203.02155). RLHF for LMs.
22. **Anthropic HH-RLHF** — Bai et al., 2022. [arXiv:2204.05862](https://doi.org/10.48550/arXiv.2204.05862).
23. **Constitutional AI** — Bai et al., 2022. [arXiv:2212.08073](https://doi.org/10.48550/arXiv.2212.08073).
24. **PPO** — Schulman et al., 2017. [arXiv:1707.06347](https://doi.org/10.48550/arXiv.1707.06347).
25. **DPO** — Rafailov et al., 2023. [arXiv:2305.18290](https://doi.org/10.48550/arXiv.2305.18290).
26. **GRPO** (DeepSeekMath) — Shao et al., 2024. [arXiv:2402.03300](https://doi.org/10.48550/arXiv.2402.03300).
27. **DeepSeek-R1** — DeepSeek-AI, 2025. [arXiv:2501.12948](https://doi.org/10.48550/arXiv.2501.12948).
28. **LIMA** — Zhou et al., 2023. [arXiv:2305.11206](https://doi.org/10.48550/arXiv.2305.11206). Quality > quantity for SFT.
29. **LoRA** — Hu et al., 2022. [arXiv:2106.09685](https://doi.org/10.48550/arXiv.2106.09685).
30. **QLoRA** — Dettmers et al., 2023. [arXiv:2305.14314](https://doi.org/10.48550/arXiv.2305.14314).

## Reasoning and inference scaling

31. **Chain-of-Thought** — Wei et al., 2022. [arXiv:2201.11903](https://doi.org/10.48550/arXiv.2201.11903).
32. **Self-Consistency** — Wang et al., 2023. [arXiv:2203.11171](https://doi.org/10.48550/arXiv.2203.11171).
33. **Let's Verify Step by Step** — Lightman et al., 2023. [arXiv:2305.20050](https://doi.org/10.48550/arXiv.2305.20050). Process reward models.
34. **Scaling Test-Time Compute** — Snell et al., 2024. [arXiv:2408.03314](https://doi.org/10.48550/arXiv.2408.03314).

## Agents and tool use

35. **ReAct** — Yao et al., 2023. [arXiv:2210.03629](https://doi.org/10.48550/arXiv.2210.03629).
36. **Reflexion** — Shinn et al., 2023. [arXiv:2303.11366](https://doi.org/10.48550/arXiv.2303.11366).
37. **Toolformer** — Schick et al., 2023. [arXiv:2302.04761](https://doi.org/10.48550/arXiv.2302.04761).
38. **SWE-bench** — Jimenez et al., 2024. [arXiv:2310.06770](https://doi.org/10.48550/arXiv.2310.06770).

## RAG

39. **Original RAG** — Lewis et al., 2020. [arXiv:2005.11401](https://doi.org/10.48550/arXiv.2005.11401).
40. **HyDE** — Gao et al., 2023. [arXiv:2212.10496](https://doi.org/10.48550/arXiv.2212.10496).
41. **ColBERTv2** — Santhanam et al., 2022. [aclanthology.org/2022.naacl-main.272](https://doi.org/10.18653/v1/2022.naacl-main.272).
42. **GraphRAG** — Edge et al., 2024. [arXiv:2404.16130](https://doi.org/10.48550/arXiv.2404.16130).
43. **Lost in the Middle** — Liu et al., 2024. [arXiv:2307.03172](https://doi.org/10.48550/arXiv.2307.03172).

## Distributed and inference systems

44. **Megatron-LM** — Shoeybi et al., 2019. [arXiv:1909.08053](https://doi.org/10.48550/arXiv.1909.08053).
45. **ZeRO** — Rajbhandari et al., 2020. [doi:10.1109/SC41405.2020.00024](https://doi.org/10.1109/SC41405.2020.00024).
46. **FSDP** — Zhao et al., 2023. [doi:10.14778/3611540.3611569](https://doi.org/10.14778/3611540.3611569).
47. **PagedAttention / vLLM** — Kwon et al., 2023. [doi:10.1145/3600006.3613165](https://doi.org/10.1145/3600006.3613165).
48. **Speculative Decoding** — Leviathan et al., 2023. [arXiv:2211.17192](https://doi.org/10.48550/arXiv.2211.17192).

## Safety and evaluation

49. **Red-teaming LMs** — Ganguli et al., 2022. [arXiv:2209.07858](https://doi.org/10.48550/arXiv.2209.07858).
50. **Jailbreaking aligned LLMs** — Zou et al., 2023. [arXiv:2307.15043](https://doi.org/10.48550/arXiv.2307.15043).
51. **MMLU** — Hendrycks et al., 2021. [arXiv:2009.03300](https://doi.org/10.48550/arXiv.2009.03300).
52. **HELM** — Liang et al., 2023. [arXiv:2211.09110](https://doi.org/10.48550/arXiv.2211.09110).
53. **LiveBench** — White et al., 2024. [arXiv:2406.19314](https://doi.org/10.48550/arXiv.2406.19314).

## Multimodal

54. **CLIP** — Radford et al., 2021. [arXiv:2103.00020](https://doi.org/10.48550/arXiv.2103.00020).
55. **LLaVA** — Liu et al., 2023. [arXiv:2304.08485](https://doi.org/10.48550/arXiv.2304.08485).

## Mixture of experts

56. **Outrageously Large** — Shazeer et al., 2017. [arXiv:1701.06538](https://doi.org/10.48550/arXiv.1701.06538).
57. **Switch Transformer** — Fedus et al., 2022. [arXiv:2101.03961](https://doi.org/10.48550/arXiv.2101.03961).
58. **Mixtral** — Jiang et al., 2024. [arXiv:2401.04088](https://doi.org/10.48550/arXiv.2401.04088).

## Long context

59. **YaRN** — Peng et al., 2024. [arXiv:2309.00071](https://doi.org/10.48550/arXiv.2309.00071).
60. **Ring Attention** — Liu et al., 2024. [arXiv:2310.01889](https://doi.org/10.48550/arXiv.2310.01889).

## How to read this list

Read 5–10 per week with the [Reading & reproducing papers](../senior/reading-papers.md) discipline. Implement at least one per quarter. The list itself is not the goal — it's the substrate from which deeper understanding grows.

## Where to next

[Reference models](models.md) — the open and closed canon of LLMs.
