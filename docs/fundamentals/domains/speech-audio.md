# Speech & audio

> ASR, TTS, voice cloning, music generation. The audio modality's arc from HMMs to transformer-based universal speech models.

## The eras

| Era | Defining methods |
| --- | --- |
| Classical | HMM-GMM acoustic models + n-gram language models |
| Deep ASR (2012–2017) | DNN-HMM hybrids; CTC; LAS attention models |
| End-to-end (2018–2022) | Transformers; conformer architectures |
| Foundation models (2022–) | Whisper, OWSM, NaturalSpeech; multimodal LLMs (GPT-4o voice) |

## Automatic Speech Recognition (ASR)

Speech audio → text.

### Whisper [Radford et al., 2023](https://arxiv.org/abs/2212.04356)[^whisper]

OpenAI's open-source transformer trained on 680k hours of multilingual + multitask audio. Robust to noise, accents, music; handles 99+ languages; cheap to run.

Modern production ASR baseline. Variants: WhisperX (with diarisation), Distil-Whisper (smaller), faster-whisper (CTranslate2 backend).

### Pre-Whisper architectures worth knowing

- **DeepSpeech** (Mozilla / Baidu) — early end-to-end CTC-based ASR.
- **wav2vec 2.0** ([Baevski et al., 2020](https://arxiv.org/abs/2006.11477))[^wav2vec2] — self-supervised speech pretraining.
- **HuBERT** — masked prediction on clustered audio units.
- **Conformer** ([Gulati et al., 2020](https://arxiv.org/abs/2005.08100))[^conformer] — convolution-augmented transformer; SOTA for many speech tasks.

## Text-to-Speech (TTS)

Text → natural-sounding speech.

- **Tacotron 2** ([Shen et al., 2018](https://arxiv.org/abs/1712.05884))[^tacotron] + WaveNet vocoder: the deep-learning baseline for years.
- **VITS** ([Kim et al., 2021](https://arxiv.org/abs/2106.06103))[^vits]: end-to-end; mel spectrogram + waveform jointly.
- **NaturalSpeech 3** (Microsoft): diffusion-based, high quality.
- **OpenAI Voice / ElevenLabs / Resemble / Cartesia**: hosted, near-human quality.

For ultra-low-latency conversational TTS: **Sonic** (Cartesia), **OpenAI TTS turbo** — under 200ms TTFT.

## Voice cloning

Generate speech in a target speaker's voice from a small sample.

- **Tortoise TTS** — early open-source.
- **XTTS** (Coqui) — open-source; multilingual.
- **VALL-E** (Microsoft) — zero-shot voice cloning from 3s sample.
- **ElevenLabs Voice Cloning** — commercial; high fidelity.

Misuse concerns are real: deepfake voice for fraud, harassment, political disinformation. Most providers require explicit consent or verification. See [Safety → Evaluating harms](../../safety/eval-of-harms.md).

## Diarisation

"Who spoke when?" — segment audio by speaker identity.

Tools: **pyannote**, **NeMo Speaker Diarisation**, integrated in WhisperX. Important for meeting transcription, broadcast analysis, multi-speaker dialogue.

## Music generation

- **Jukebox** (OpenAI, 2020): VQ-VAE + transformer; pioneering but slow.
- **MusicLM** (Google): text-to-music transformer.
- **Suno**, **Udio**: hosted, near-commercial quality.
- **Stable Audio**: latent diffusion for audio; open.

The state of the art in 2025–2026: full-song generation with vocals from a single prompt. Quality is approaching human-composed music for many genres.

## Audio classification

Tag audio with categories: instruments, environments, events.

- **AudioSet** (Google): 632-class audio ontology; primary benchmark.
- **PANNs** ([Kong et al., 2020](https://arxiv.org/abs/1912.10211))[^panns]: pretrained audio neural networks.
- **CLAP** ([Wu et al., 2023](https://arxiv.org/abs/2206.04769))[^clap]: contrastive language-audio pretraining; the CLIP for audio.

Used in: industrial monitoring, wildlife conservation (bird-song ID), content moderation, sound design.

## Native multimodal audio LLMs

The 2024+ wave: LLMs that natively process audio (input) and generate audio (output) without intermediate text:

- **GPT-4o** advanced voice mode.
- **Gemini 2.0** with native audio.
- **Moshi** (Kyutai) — full-duplex conversational AI.

Capabilities: low-latency conversation (~200ms), interruption handling, prosodic / emotional nuance preserved. Re-shapes the voice-AI product space.

See [Senior → Multimodal](../../senior/multimodal.md).

## Spectrograms and the audio representation choice

- **Raw waveform** — 16k–48k samples/second; high redundancy.
- **Mel spectrogram** — 2D representation: frequency × time; the standard input to most audio models.
- **MFCCs (Mel-frequency cepstral coefficients)** — classical compressed features.
- **Discrete audio tokens** — recent: quantise audio into a vocabulary (SoundStream, EnCodec); allows transformer-style processing.

Most modern audio models work on mel spectrograms or quantised audio tokens.

## Audio benchmarks

- **LibriSpeech** — ASR (English read speech).
- **CommonVoice** — multilingual ASR.
- **AudioSet** — audio tagging.
- **MUSDB** — music source separation.
- **VCTK**, **LJSpeech** — TTS.
- **NaturalConversation** — voice agents (relatively new).

## A pragmatic audio project checklist

For a new audio project:

1. **ASR**: try Whisper first. If quality / latency insufficient → consider commercial APIs (Deepgram, AssemblyAI).
2. **TTS**: try OpenAI TTS / ElevenLabs / Cartesia. For OSS: Coqui XTTS.
3. **Voice agents**: native multimodal (GPT-4o voice) if available; else ASR → LLM → TTS pipeline.
4. **Classification / tagging**: CLAP zero-shot.
5. **Generation** (music, sound effects): hosted (Suno, ElevenLabs) for quality; Stable Audio for OSS.

## References

[^whisper]: Radford A, Kim JW, Xu T, Brockman G, McLeavey C, Sutskever I. Robust Speech Recognition via Large-Scale Weak Supervision (Whisper). *ICML.* 2023. [arXiv:2212.04356](https://arxiv.org/abs/2212.04356)
[^wav2vec2]: Baevski A, Zhou Y, Mohamed A, Auli M. wav2vec 2.0. *NeurIPS.* 2020. [arXiv:2006.11477](https://arxiv.org/abs/2006.11477)
[^conformer]: Gulati A, Qin J, Chiu C-C, et al. Conformer: Convolution-augmented Transformer for Speech Recognition. *Interspeech.* 2020.
[^tacotron]: Shen J, Pang R, Weiss RJ, et al. Natural TTS Synthesis by Conditioning WaveNet on Mel Spectrogram Predictions (Tacotron 2). *ICASSP.* 2018.
[^vits]: Kim J, Kong J, Son J. Conditional Variational Autoencoder with Adversarial Learning for End-to-End Text-to-Speech (VITS). *ICML.* 2021.
[^panns]: Kong Q, Cao Y, Iqbal T, et al. PANNs: Large-Scale Pretrained Audio Neural Networks for Audio Pattern Recognition. *IEEE/ACM TASLP.* 2020.
[^clap]: Wu Y, Chen K, Zhang T, Hui Y, Berg-Kirkpatrick T, Dubnov S. Large-scale Contrastive Language-Audio Pretraining (CLAP). *ICASSP.* 2023.
7. **Huang X, Acero A, Hon H-W.** *Spoken Language Processing.* Prentice Hall; 2001. (Classical reference.)

## Where to next

[Recommender systems](recommender-systems.md) — a domain where deep learning supplements rather than replaces classical methods.
