# Privacy

> PII handling, GDPR / HIPAA basics, data minimisation, retention. The legal-and-ethical surface every LLM product touches.

Not legal advice. Get a lawyer for actual compliance work. This page is what an AI engineer should know about the engineering side.

## Where PII enters

1. **User input** — typed prompts, uploaded files, voice transcripts.
2. **Retrieved context** — your corpus may contain customer data, employee data, etc.
3. **Tool results** — calling an API that returns user-specific records.
4. **Model outputs** — model may regurgitate training-data memorised PII (rare for modern models but happens).
5. **Logs and traces** — everything you log to debug includes some of the above.

## Data minimisation

Principle: collect the minimum data necessary, hold it for the minimum time necessary, share with the minimum number of parties necessary.

Concrete:

- Don't store full prompts forever. Truncate, hash, or aggregate.
- Don't share prompts with vendors who don't need them (analytics providers, etc.).
- Set retention TTLs on session data.
- Provide a user-deletion endpoint that propagates to all stores.

## GDPR essentials (EU)

For users in the EU, GDPR applies. The relevant rights:

- **Right to access** — user can request what you have on them.
- **Right to deletion** — user can request you delete it.
- **Right to rectification** — user can correct errors.
- **Right to portability** — user can export their data.
- **Right to object** — including to automated decision-making.

Engineering implications:

- Every data store needs a `user_id` index for fast lookup.
- Deletion must propagate to backups (within a reasonable window; tombstone-and-purge is fine).
- AI-generated decisions affecting the user (loan approval, hiring, eviction) trigger extra requirements.

## HIPAA essentials (US health)

For PHI (Protected Health Information) in the US:

- Business Associate Agreement (BAA) required with every vendor touching PHI — including LLM providers. Anthropic, OpenAI, Google, Azure all offer BAAs on enterprise tiers.
- Encryption at rest and in transit (table-stakes).
- Audit logs of access.
- Minimum necessary access; role-based controls.

If your product touches health, get HIPAA-experienced counsel involved early. The penalties are not theoretical.

## CCPA / state laws (US)

California, Virginia, Colorado, and a growing list of states have GDPR-lite regimes. Practical engineering:

- Same deletion / access / opt-out endpoints as for GDPR.
- "Sale of personal data" definitions vary; default to opt-in.

## Provider data-handling

When you call an LLM API:

- Read the provider's TOS for whether they train on your data.
  - **OpenAI**: by default, API data is not used to train; products-tier ChatGPT *may* be unless opt-out.
  - **Anthropic**: API data is not used to train models. Period (as of 2026).
  - **Google**: Vertex AI is opt-out for training; consumer Gemini is opt-in (varies).
  - **Open-source models**: only "trains" if *you* train on the data.
- Verify region: data may be processed in regions you didn't expect.
- Use enterprise tiers with explicit DPAs for any regulated data.

## PII detection and redaction

For inputs:

- Run a PII detector ([Presidio](https://microsoft.github.io/presidio/), [scrubadub](https://github.com/LeapBeyond/scrubadub)) on every prompt.
- Either redact (replace with `[EMAIL]`, `[SSN]`) or warn the user and refuse to proceed.

For outputs (rare but worth checking):

- Run the same detector on responses.
- Block or redact if PII appears, especially if the input didn't contain it.

For training data:

- Aggressive scrubbing before fine-tuning. See [Filtering & deduplication](../fundamentals/data/filtering-deduplication.md#personally-identifiable-information-pii).

## Memorisation and extraction attacks

Pretrained models can memorise rare strings (credit cards, phone numbers, addresses) verbatim. [Carlini et al., 2021](https://doi.org/10.48550/arXiv.2012.07805) showed this on GPT-2 with simple prefix-extraction. Modern frontier models are better but not immune.

Mitigations during training:

- Aggressive dedup (memorisation correlates with repetition).
- Differential privacy (theoretical guarantees; expensive in practice).
- Targeted PII scrubbing pre-training.

Mitigations at inference:

- Output filters that detect realistic PII patterns.
- Model refuses requests like "list the email addresses you've seen."

## Logging hygiene

Audit logs are critical for security; they also concentrate every PII surface. Practices:

- Hash user IDs in logs (not raw).
- Redact or hash prompt content; store the *length* and a *fingerprint* unless verbatim is required for a specific debugging need.
- Encrypt logs at rest.
- Set TTLs (90 days is a common compromise).
- Separate auth: who can read raw prompts vs hashed?

See [Production → Logging](../production/logging.md).

## User-facing privacy

What users need to see:

- A clear privacy policy explaining what's collected.
- A data-deletion flow (settings → delete my data).
- A choice about whether their conversations are used to improve the system (opt-out by default in most regulated regimes).
- Transparency about which model / provider is being used.

## A reasonable starter checklist

- [ ] PII detector on every user input.
- [ ] No raw prompts in long-term logs (hashed only).
- [ ] User can request deletion via a documented endpoint; backend wipes all stores.
- [ ] LLM provider on enterprise tier with no-training contractual guarantee.
- [ ] Encryption at rest for prompts, sessions, embeddings.
- [ ] Region pinning for regulated data.
- [ ] Audit log of who accessed what user's data.

Most of this is engineering you'd do for any backend product. LLMs just make the surface area more visible.

## References

1. **EU GDPR.** [gdpr.eu](https://gdpr.eu/)
2. **HIPAA Compliance for Software.** US HHS. [hhs.gov/hipaa](https://www.hhs.gov/hipaa/)
3. **NIST AI Risk Management Framework.** [nist.gov/itl/ai-risk-management-framework](https://www.nist.gov/itl/ai-risk-management-framework)

## Where to next

[Evaluating harms](eval-of-harms.md) — measuring the safety properties this chapter aspires to.
